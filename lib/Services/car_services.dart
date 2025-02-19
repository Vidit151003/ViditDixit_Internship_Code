import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letzrentnew/Services/http_services.dart';
import 'package:letzrentnew/Services/vendor_services/lowcars_services.dart';
import 'package:letzrentnew/Services/vendor_services/mychoize_services.dart';
import 'package:letzrentnew/Services/vendor_services/wowcar_services.dart';
import 'package:letzrentnew/Services/vendor_services/zoomCar_v6.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/models/car_model.dart';
import 'package:letzrentnew/models/document_model.dart';

import 'firebase_services.dart';

class CarServices {
  final firebase = FirebaseFirestore.instance;

  Future<List<CarModel>> getCars(DriveModel model) async {
    try {
      if (model.city.isEmpty) {
        throw Error.safeToString(
            'Cars are not currently available in the selected city.');
      }

      // Fetch vendors for the selected drive type
      final vendors = await getVendor(model.drive!);

      // Initialize an empty list of cars
      List<CarModel> carsData = [];

      // Different logic for fetching cars based on drive type
      switch (model.drive) {
        case DriveTypes.SD:
          carsData = await getSelfDriveCars(model, vendors, carsData);
          break;
        case DriveTypes.SUB:
          carsData = await getSubscriptionCars(model, carsData, vendors);
          break;
        case DriveTypes.RT:
        case DriveTypes.OW:
          carsData = await getOutStationCars(model, carsData, vendors);
          break;
        case DriveTypes.AT:
          carsData = await getAirportTransferCars(model, carsData, vendors);
          break;
        default:
          // Handle cases where hours are less than 8 or other default cases
          carsData = await _getCarsByCity(model, vendors);
      }

      return carsData;
    } catch (e) {
      // Handle error and log it for debugging
      print('Error fetching cars: $e');
      rethrow; // Optionally rethrow or return empty list based on your error handling strategy
    }
  }

  Future<List<CarModel>> _getCarsByCity(
      DriveModel model, Map<String, Vendor> vendors) async {
    try {
      final querySnapshot = await firebase
          .collection('cdcar${model.city.toLowerCase()}')
          .where('minhrs', isEqualTo: model.hrs < 8 ? 4 : null)
          .get();
      return parseCarData(querySnapshot, vendors, model);
    } catch (e) {
      print('Error fetching cars for city: $e');
      return [];
    }
  }

  Future<List<CarModel>> getAirportTransferCars(DriveModel model,
      List<CarModel> carsData, Map<String, Vendor> vendors) async {
    final cars = await firebase
        .collection('AirportTransfer')
        .doc(model.city.toLowerCase())
        .collection('Cars')
        .get();
    carsData = parseCarData(cars, vendors, model);
    return carsData;
  }

  Future<List<CarModel>> getOutStationCars(DriveModel model,
      List<CarModel> carsData, Map<String, Vendor> vendors) async {
    final cars = await firebase
        .collection('outstation${model.city.toLowerCase()}')
        .get();
    carsData = parseCarData(cars, vendors, model);
    return carsData;
  }

  Future<List<CarModel>> getSubscriptionCars(DriveModel model,
      List<CarModel> carsData, Map<String, Vendor> vendors) async {
    final List<Future<List<CarModel>>> apiCalls =
        getMonthlyApis(model, vendors);
    final List<List<CarModel>> response =
        await Future.wait(apiCalls.map((e) => e));
    return response.expand((element) => element).toList() ?? [];
  }

  Future<List<CarModel>> getSelfDriveCars(DriveModel model,
      Map<String, Vendor> vendors, List<CarModel> carsData) async {
    final List<Future<List<CarModel>>> apiCalls =
        getSelfDriveApis(model, vendors);
    final List<List<CarModel>> response =
        await Future.wait(apiCalls.map((e) => e));
    return response.expand((element) => element).toList() ?? [];
  }

  List<Future<List<CarModel>>> getMonthlyApis(
      DriveModel model, Map<String, Vendor> vendors) {
    final int hoursTillBooking =
        model.startDateTime.difference(DateTime.now()).inHours;
    final List<Future<List<CarModel>>> apiCalls = [];
    if (hoursTillBooking >= vendors[myChoize]!.minHrsTillBooking.sub) {
      apiCalls.add(MyChoizeServices.monthlyRental(model, vendors[myChoize]!));
    }
    if (vendors[karyana]!.api!.pu) {
      if (model.city.contains("Noida") ||
          model.city.contains("Gurugram") ||
          model.city.contains("Delhi") ||
          model.city.contains("Gwalior") ||
          model.city.contains("Ghaziabad")) {
        String city = "Delhi";
        if (model.city.contains("Gwalior")) {
          city = "Gwalior";
        }
        apiCalls.add(
            FirebaseServices.getKaryanaMonthly(model, vendors[karyana]!, city));
      }
    }
    HttpServices.getMonthlyRentalCars(model);
    if (vendors[zoomCar]!.isV6 &&
        hoursTillBooking >= vendors[zoomCar]!.minHrsTillBooking.sub) {
      apiCalls.add(
          ZoomCarServicesV6.zoomCar(model, 'normal', vendors[zoomCar]!)!
              .then((value) => value ?? []));
    }
    return apiCalls;
  }

  List<Future<List<CarModel>>> getSelfDriveApis(
      DriveModel model, Map<String, Vendor> vendors) {
    final int tripDurationInHours =
        model.endDateTime.difference(model.startDateTime).inHours;
    final int hoursTillBooking =
        model.startDateTime.difference(DateTime.now()).inHours;
    final List<Future<List<CarModel>>> apiCalls = [
      getSelfDriveFirebaseCars(model, vendors),
    ];
    if (vendors[carOnRent]!.api!.pu &&
        hoursTillBooking >= vendors[carOnRent]!.minHrsTillBooking.sd &&
        tripDurationInHours >= 24) {
      if (model.city.contains('Noida') ||
          model.city.contains('Indore') ||
          model.city.contains('Ghaziabad') ||
          model.city.contains('Meerut') ||
          model.city.contains('Modinagar') ||
          model.city.contains('Muradnagar'))
        apiCalls.add(FirebaseServices.getCarOnRent(
            model, tripDurationInHours, vendors[carOnRent]!));
    }
    if (vendors[hrx]!.api!.pu &&
        hoursTillBooking >= vendors[hrx]!.minHrsTillBooking.sd &&
        tripDurationInHours >= 24) {
      if (model.city.contains('Mumbai') || model.city.contains('Navi Mumbai'))
        apiCalls.add(
            FirebaseServices.getHrx(model, tripDurationInHours, vendors[hrx]!));
    }
    if (vendors[zt]!.api!.pu &&
        hoursTillBooking >= vendors[zt]!.minHrsTillBooking.sd &&
        tripDurationInHours >= 24) {
      if (delhiNCR.contains(model.city.toLowerCase()))
        apiCalls.add(
            FirebaseServices.getZt(model, tripDurationInHours, vendors[hrx]!));
    }
    if (vendors[zoomCar]!.api!.pu &&
        hoursTillBooking >= vendors[zoomCar]!.minHrsTillBooking.sd &&
        tripDurationInHours >= 8) {
      if (vendors[zoomCar]!.isV6) {
        apiCalls.add(
            ZoomCarServicesV6.zoomCar(model, 'normal', vendors[zoomCar]!)!
                .then((value) => value ?? []));
      }
    }
    if (vendors[karyana]!.api!.pu &&
        hoursTillBooking >= vendors[zoomCar]!.minHrsTillBooking.sd &&
        tripDurationInHours > 8) {
      if (model.city.contains("Noida") ||
          model.city.contains("Gurugram") ||
          model.city.contains("Gurgaon") ||
          model.city.contains("Delhi") ||
          model.city.contains("Gwalior")) {
        String city = "Delhi";
        if (model.city.contains("Gwalior")) {
          city = "Gwalior";
          apiCalls.add(FirebaseServices.getKaryana(
              model, tripDurationInHours, vendors[karyana]!, city, true));
        } else {
          apiCalls.add(FirebaseServices.getKaryana(model, tripDurationInHours,
              vendors[karyana]!, city, tripDurationInHours > 24));
        }
      }
    }
    if (vendors[myChoize]!.api!.pu &&
        tripDurationInHours >= 24 &&
        hoursTillBooking >= vendors[myChoize]!.minHrsTillBooking.sd) {
      apiCalls.add(MyChoizeServices.selfDrive(
          model, vendors[myChoize]!, tripDurationInHours));
    }
    if (vendors[kyp]!.api!.pu &&
        tripDurationInHours >= 24 &&
        hoursTillBooking >= vendors[kyp]!.minHrsTillBooking.sd) {
      if (model.city == 'Delhi' ||
          model.city == 'Noida' ||
          model.city == 'Gurugram') {
        apiCalls.add(
            FirebaseServices.getKyp(model, tripDurationInHours, vendors[kyp]!));
      }
    }
    if (vendors[wowCarz]!.api!.pu &&
        hoursTillBooking >= vendors[wowCarz]!.minHrsTillBooking.sd) {
      if (model.city == bengaluru || model.city == 'Bangalore') {
        apiCalls.add(WowCarServices.getWowCarSD(model, vendors[wowCarz]));
      }
    }
    if (vendors[lowCars]!.api!.pu &&
        hoursTillBooking >= vendors[lowCars]!.minHrsTillBooking.sd &&
        tripDurationInHours >= 12) {
      apiCalls.add(LowCarServices.getLowCars(model, vendors[lowCars]!, "BASE"));
      apiCalls
          .add(LowCarServices.getLowCars(model, vendors[lowCars]!, "MEDIUM"));
      apiCalls
          .add(LowCarServices.getLowCars(model, vendors[lowCars]!, "LARGE"));
    }
    return apiCalls;
  }

  Future<List<CarModel>> getMonthlyFirebaseCars(
      DriveModel model, Map<String, Vendor> vendors) async {
    final cars = await firebase
        .collection('carsubscription${model.city.toLowerCase()}')
        .get();
    return parseCarData(cars, vendors, model);
  }

  Future<List<CarModel>> getSelfDriveFirebaseCars(
      DriveModel model, Map<String, Vendor> vendors) async {
    final firebaseCars = await firebase
        .collection('car${model.city.toLowerCase()}')
        .where('drive', isEqualTo: 'sd')
        .get();
    return parseCarData(firebaseCars, vendors, model);
  }

  Future<List<CarModel>> getMonthlyWowCars(
      DriveModel model, Vendor vendor) async {
    final List<CarModel> apiCarList =
        await WowCarServices.getMonthlyRentalCars(vendor: vendor);
    return apiCarList;
  }

  Future<Map<String, Vendor>> getVendor(DriveTypes type) async {
    final Map<String, Vendor> vendors = {};
    final QuerySnapshot<Map<String, dynamic>> vendorData =
        await firebase.collection('carvendors').get();
    vendorData.docs.forEach((element) {
      final Vendor vendor = Vendor.fromJson(element.data(), type);
      vendors[vendor.name] = vendor;
    });
    return vendors;
  }

  List<CarModel> parseCarData(QuerySnapshot<Map<String, dynamic>> cars,
      Map<String, Vendor> vendorList, DriveModel model) {
    final List<CarModel> carList = [];
    cars.docs.forEach((element) {
      final data = element.data();
      carList.add(CarModel.fromJson(
        data,
        vendorList[data['vendor'].toLowerCase()]!,
        model.drive!,
        driveModel: model,
      ));
    });
    return carList;
  }

  // static Future<bool> zoomPaymentApiCalls(
  //     String bookingId, String name, String phone, int amount) async {
  //   final Map response =
  //       await ZoomCarServices.paymentCreationZoomCar(bookingId, amount);
  //   final zoomResponse = await ZoomCarServices.zoomCarUserDetails(
  //       bookingId, response['order_id'], response['id'], name, phone);
  //   if (zoomResponse == null || zoomResponse != true) {
  //     mixpanel.track('Zoom payment api failed', properties: {
  //       'name': name,
  //       'phone': phone,
  //       'api1Response': response,
  //       'api2Response': zoomResponse
  //     });
  //   }
  //   return (zoomResponse is bool) ? zoomResponse : false;
  // }

  static Future<bool> zoomPaymentApiCallsV6(
      String bookingId, String name, String phone, int amount) async {
    final Map response =
        await ZoomCarServicesV6.paymentCreationZoomCar(bookingId, amount);
    final zoomResponse = await ZoomCarServicesV6.zoomCarUserDetails(
        bookingId, response['order_id'], response['id'], name, phone);
    if (zoomResponse == null || zoomResponse != true) {
      mixpanel.track('Zoom payment api failed (V6)', properties: {
        'name': name,
        'phone': phone,
        'api1Response': response,
        'api2Response': zoomResponse
      });
    }
    return (zoomResponse is bool) ? zoomResponse : false;
  }

  static String getFuel(String name) {
    const String petrol = 'Petrol';
    const String diesel = 'Diesel';
    const String electric = 'Electric';
    const String both = '$petrol/$diesel';
    if (name.toUpperCase().contains(petrol.toUpperCase())) {
      return petrol;
    } else if (name.toUpperCase().contains(diesel.toUpperCase())) {
      return diesel;
    } else if (name.contains(electric)) {
      return electric;
    } else {
      return both;
    }
  }

  static String getFlightNumber(DriveModel model, String flightNumber) =>
      model.drive == DriveTypes.AT ? flightNumber : '';

  static String getDrive(DriveModel model) {
    return model.drive == DriveTypes.AT
        ? model.type
        : Vendor(
            advancePay: 0,
            name: '',
            imageUrl: '',
            currentRate: 0,
            discountRate: 0,
            securityDeposit: 0,
            subSecurityDeposit: 0,
            plateColor: '',
            rating: 0,
            offer: '',
            discountMap: {},
            taxRate: 0,
          ).getDrive(model.drive!);
  }

  static String termsAndConditions(String _vendor) {
    switch (_vendor) {
      case avis:
        return 'https://www.avis.co.in/avis-terms-and-conditions';
        break;
      case ems:
        return 'https://easymysavaari.com/terms-conditions.php';
        break;
      case myChoize:
        return 'https://www.mychoize.com/terms-and-conditions';
        break;
      case zoomCar:
        return 'https://www.zoomcar.com/zap-policies';
        break;
      case karyana:
        return "http://www.karayana.com/terms-&-conditions/page-54605847";
      default:
        return letzrentTandC;
        break;
    }
  }

  static String advancePayFunction(String _price, double advancePayPercentage) {
    final double price = double.parse(_price) * advancePayPercentage;
    return price.toStringAsFixed(0);
  }

  static DriveModel getDriveModel(DriveModel model, String flightNumber,
      double balanceAmount, DocumentModel documents, CarModel carModel) {
    final DriveModel tempModel = model;
    tempModel.flightNumber = CarServices.getFlightNumber(model, flightNumber);
    tempModel.balance = balanceAmount;
    tempModel.driveString = CarServices.getDrive(model);
    tempModel.documents = documents;
    return tempModel;
  }

  static getFreeKm(freeKm, int weekdayhr, int weekendhr, bool isApi) {
    if (isApi) {
      return freeKm;
    }
    final int finalFree = freeKm * (weekdayhr + weekendhr);
    return finalFree;
  }

  static String getDurationText(DriveTypes _drive, String _startDate,
      String _endDate, String _startTime, String _endTime, double distance) {
    switch (_drive) {
      case DriveTypes.WC:
        return '$_startDate $_startTime - $_endDate $_endTime';
        break;
      case DriveTypes.SD:
        return '$_startDate $_startTime - $_endDate $_endTime';
        break;
      case DriveTypes.SUB:
        return '$_startDate $_startTime - $_endDate $_endTime';
        break;
      case DriveTypes.RT:
        return "$distance KM Round Trip";
        break;
      case DriveTypes.AT:
        return '$_startDate $_startTime - $_endDate $_endTime';
        break;
      case DriveTypes.OW:
        return '$distance KM One-Way';
        break;
      default:
        return '';
        break;
    }
  }

  static int getRewardVoucherAmountCars(int amountPaid) {
    int reward = 0;
    //Between 500-1000
    if (amountPaid >= 750 && amountPaid <= 1500) {
      reward = 25;
    } else if (amountPaid >= 1500 && amountPaid < 3000) {
      reward = 50;
    } else if (amountPaid >= 3000 && amountPaid < 5000) {
      reward = 75;
    } else if (amountPaid >= 5000 && amountPaid < 10000) {
      reward = 100;
    } else if (amountPaid >= 10000 && amountPaid < 15000) {
      reward = 150;
    } else if (amountPaid >= 15000 && amountPaid < 25000) {
      reward = 200;
    } else if (amountPaid >= 25000 && amountPaid < 50000) {
      reward = 250;
    } else if (amountPaid >= 50000) {
      reward = 500;
    }
    return reward;
  }
}
