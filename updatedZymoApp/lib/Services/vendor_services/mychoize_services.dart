import 'dart:convert';

import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/extensions.dart';
import 'package:letzrentnew/models/car_model.dart';
import 'package:letzrentnew/models/mychoize_model.dart';
import 'package:http/http.dart' as http;
import 'package:letzrentnew/models/user_model.dart';

class MyChoizeServices {
  static List<CarModel> getCarModelMyChoize(
      List<MyChoizeModel> cars, Vendor vendor, List<PickupModel> pickups) {
    final List<CarModel> carList = [];
    cars.forEach((element) {
      if (!element.isSoldOut) {
        final double price = double.parse(element.totalExpCharge.toString());
        final CarModel model = CarModel(name: '',
          fuel: '',
          transmission: '',
          apiFlag: true,
          imageUrl: '',
          finalPrice:price * vendor.currentRate * vendor.discountRate,
          finalDiscount: price * vendor.currentRate,
          isSoldOut: element.isSoldOut,)
          ..isSoldOut = element.isSoldOut
          ..name = element.brandName
          ..seats = element.seatingCapacity
          ..type = element.vTRSUVFlag == 'N' ? '' : 'SUV'
          ..apiFlag = true
          ..transmission = element.transMissionType
          ..imageUrl = element.vehicleBrandImageName
          ..finalPrice = price * vendor.currentRate * vendor.discountRate
          ..finalDiscount = price * vendor.currentRate
          ..actualPrice = price
          ..freeKm = element.rateBasisDesc
          ..fuel = element.fuelType
          ..pickUpAndDrop = element.locationName
          ..pickups = pickups
          ..vendor = vendor
          ..myChoizeModel = element
          ..extraKmCharge = element.exKMRate;
        carList.add(model);
      }
    });
    return carList;
  }

  static Future<int> getCityKey(String cityName) async {
    // const String getCityUrl = myChoizeTestUrl + 'listingservice/GetCityList';
    // final http.Response response = await http.get(Uri.parse(getCityUrl));
    final List data = [
      {"CityCode": "UDP", "CityDescription": "UDAIPUR", "CityKey": 365},
      {"CityCode": "AMR", "CityDescription": "AMRITSAR", "CityKey": 370},
      {"CityCode": "LDH", "CityDescription": "LUDHIANA", "CityKey": 375},
      {"CityCode": "LUC", "CityDescription": "LUCKNOW", "CityKey": 388},
      {"CityCode": "BHL", "CityDescription": "BHOPAL", "CityKey": 389},
      {"CityCode": "IND", "CityDescription": "INDORE", "CityKey": 390},
      {"CityCode": "DEH", "CityDescription": "DEHRADUN", "CityKey": 392},
      {"CityCode": "GOA", "CityDescription": "GOA", "CityKey": 393},
      {"CityCode": "SUR", "CityDescription": "SURAT", "CityKey": 451},
      {"CityCode": "MUM", "CityDescription": "MUMBAI", "CityKey": 345},
      {"CityCode": "DEL", "CityDescription": "DELHI-NCR", "CityKey": 346},
      {"CityCode": "BLR", "CityDescription": "BENGALURU", "CityKey": 348},
      {"CityCode": "KOL", "CityDescription": "KOLKATA", "CityKey": 349},
      {"CityCode": "CHA", "CityDescription": "CHANDIGARH", "CityKey": 351},
      {"CityCode": "AHD", "CityDescription": "AHMEDABAD", "CityKey": 355},
      {"CityCode": "VAD", "CityDescription": "VADODARA", "CityKey": 356},
      {"CityCode": "CHN", "CityDescription": "CHENNAI", "CityKey": 358},
      {"CityCode": "PUN", "CityDescription": "PUNE", "CityKey": 359},
      {"CityCode": "HYD", "CityDescription": "HYDERABAD", "CityKey": 362},
      {"CityCode": "JAI", "CityDescription": "JAIPUR", "CityKey": 363},
      {"CityCode": "JDP", "CityDescription": "JODHPUR", "CityKey": 364},
    ];

    late int cityKey;
    //   if (data != null && data['CityList'].isNotEmpty) {
      final name = cityName.toUpperCase();

    data.forEach((city) {
      if (city['CityDescription'].contains(name)) {
        cityKey = city['CityKey'];
      }
      //  });
    });
    if (delhiNCR.contains(name.toLowerCase())) {
      return 346;
    }
    if (name == "THANE" || name == "MIRA BHAYANDAR"){
      return 345;
    }
    return cityKey;
  }

  static Future<List<CarModel>> selfDrive(
      DriveModel model, Vendor vendor, int tripDurationHours) async {
    final int cityKey = await getCityKey(model.city);

    // Use explicit type casting for the results of Future.wait
    final List<dynamic> response = await Future.wait([
      getSd(model, vendor, cityKey, tripDurationHours),
      getPickupLocations(
        cityKey,
        model.startDateTime.millisecondsSinceEpoch,
        model.endDateTime.millisecondsSinceEpoch,
      ),
    ]);

    // Explicitly cast the results to the expected types
    final List<MyChoizeModel> cars = response[0] as List<MyChoizeModel>;
    final List<PickupModel> pickups = response[1] as List<PickupModel>;

    return getCarModelMyChoize(cars, vendor, pickups);
  }


  static Future<List<CarModel>> monthlyRental(
      DriveModel model, Vendor vendor) async {
    final int cityKey = await getCityKey(model.city);
    final response = await Future.wait([
      getSub(model, vendor, cityKey),
      getPickupLocations(cityKey, model.startDateTime.millisecondsSinceEpoch,
          model.endDateTime.millisecondsSinceEpoch,
          isFree: true)
    ]);
    final List<MyChoizeModel> cars = response[0] as List<MyChoizeModel>;
    final List<PickupModel> pickups = response[1] as List<PickupModel>;

    return getCarModelMyChoize(cars, vendor, pickups);
    }

  static Future<List<MyChoizeModel>> getSd(DriveModel model, Vendor vendor,
      int cityKey, int tripDurationHours) async {
    const String url = '${myChoizeUrl}BookingService/SearchBookingNewList';
    final List<MyChoizeModel> cars = [];
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    try {
      final String body = json.encode({
        "LocationKey": 0,
        "CustomerSecurityToken": myChoizeKey,
        "RentalType": "D",
        "DropDate": "/Date(${model.endDateTime.millisecondsSinceEpoch}+0530)/",
        "GearType": "",
        "CustomerType": myChoizeUserName,
        "PickDate":
            "/Date(${model.startDateTime.millisecondsSinceEpoch}+0530)/",
        "VehcileType": "",
        "FuelType": "",
        "PageSize": 50,
        "CityKey": cityKey,
        "PageNo": 1,
        "SecurityToken": ""
      });

      final http.Response response = await http
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(timeOutDuration, );
      final Map data = jsonDecode(response.body);
      data['SearchBookingModel'].forEach((car) {
        final myChoizeModel = MyChoizeModel.fromJson(car);
        if (myChoizeModel.rateBasis != 'MLK' &&
            myChoizeModel.brandName.isTrulyNotEmpty()) {
          myChoizeModel.rateBasisDesc =
              getMyChoizePackage(myChoizeModel.rateBasis, tripDurationHours);
          cars.add(myChoizeModel);
        }
      });
    } catch (e) {
      print(e);
    }
    return cars;
  }

  static Future<List<MyChoizeModel>> getSub(
      DriveModel model, Vendor vendor, int cityKey) async {
    const String url = '${myChoizeUrl}BookingService/SearchBookingNewList';
    final List<MyChoizeModel> cars = [];
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    try {
      final String body = json.encode({
        "LocationKey": 0,
        "CustomerSecurityToken": myChoizeKey,
        "RentalType": "D",
        "DropDate": "/Date(${model.endDateTime.millisecondsSinceEpoch}+0530)/",
        "GearType": "",
        "CustomerType": myChoizeUserName,
        "PickDate":
            "/Date(${model.startDateTime.millisecondsSinceEpoch}+0530)/",
        "VehcileType": "",
        "FuelType": "",
        "PageSize": 50,
        "CityKey": cityKey,
        "PageNo": 1,
        "SecurityToken": ""
      });

      final http.Response response = await http
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(timeOutDuration, );
      final Map data = jsonDecode(response.body);
      print(data);
      data['SearchBookingModel'].forEach((car) {
        final myChoizeModel = MyChoizeModel.fromJson(car);
        if (myChoizeModel.rateBasis == 'MLK' &&
            myChoizeModel.brandName.isTrulyNotEmpty()) {
          myChoizeModel.rateBasisDesc = "3,600 KMs Free";
          cars.add(myChoizeModel);
        }
      });
    } catch (e) {
      print(e);
    }
    return cars;
  }

  static Future<List<PickupModel>> getPickupLocations(
      int cityKey, int startDate, int endDate,
      {isFree = false}) async {
    final List<PickupModel> pickups = [];
    try {
      const String getLocation = myChoizeUrl + 'listingservice/GetLocationList';

      final body = json.encode({
        "CityKey": cityKey,
        "DropoffDateTime": "/Date($startDate+0530)/",
        "PickupDateTime": "/Date($endDate+0530)/"
      });
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      final http.Response response = await http
          .post(Uri.parse(getLocation), body: body, headers: headers)
          .timeout(timeOutDuration, );
      // final http.Response response2 = await http
      //     .get(Uri.parse(
      //         'https://www.mychoize.com/apis/sublocation?cityKey=$cityKey'))
      //     .timeout(timeOutDuration, onTimeout: () => null);

      final data = json.decode(response.body);
      // final data2 = json.decode(response2.body)['data'];

      // final airports = data2['airport_location'].map((e) => e['Key']).toList();
      // final hubs = (data2['hub_location']).map((e) => e['Key']).toList();
      // final nearby = (data2['near_by_location']).map((e) => e['Key']).toList();
      // final doorstep = data2['doorstep_location'].map((e) => e['Key']).toList();

      data['BranchesPickupLocationList'].forEach((pickup) {
        if (pickup['EnableFlag'] == 1) {
          final pickupModel = PickupModel.fromJson(pickup);

          // if (airports.contains(pickupModel.locationId)) {
          //   data2['txt_label_name'];
          // }
          // data2['hub_location'].forEach((k) {
          // if (k['Key'] == pickupModel.locationId) {
          pickupModel.deliveryCharges = pickupModel.deliveryCharges * 2;
          if (isFree) {
            pickupModel.deliveryCharges = 0;
          }
          pickups.add(pickupModel);
          // }
          // });
        }
      });
    } catch (e) {
      print(e);
    }
    return pickups;
  }

  static String getMyChoizePackage(String rateBasis, int tripDurationHours) {
    int val = 120;
    switch (rateBasis) {
      case 'DR':
        val = -1;
        break;
      case 'FF':
        val = 120;
        break;
      case 'MP':
        val = 300;
        break;

      default:
    }
    if (val == -1) {
      return 'Unlimited';
    }
    final package = (val / 24) * tripDurationHours;
    return '${package.toInt()}';
  }

  static Future createBooking(CarModel carModel, DriveModel model,
      UserModel userModel, String finalAmount) async {
    final user = await getUser(userModel);
    await createMyChoizeBooking(carModel, model, userModel, finalAmount);
  }

  static Future<String>   getUser(UserModel userModel) async {
    final url = "BookingService/GetUserInfo";
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ASP.NET_SessionId=sspo41ydr11xj2eoyrpzgor4'
    };
    final body = json.encode({
      "BookingTypeFlag": "D",
      "CustomerSecurityToken": "LetzRent@321",
      "CutomerType": "LETZRENT",
      "Password": "password",
      "LoginIDType": "Mobile",
      "UserCode": "LR",
      "UserEmail": "${userModel.email}",
      "UserMobile": "${userModel.phoneNumber}",
      "UserName": "${userModel.name}"
    });
    final http.Response response = await http
        .post(Uri.parse(myChoizeUrl + url), body: body, headers: headers)
        .timeout(timeOutDuration,);
    print(response.body);
    return response.body;
  }

  static Future createMyChoizeBooking(CarModel carModel, DriveModel model,
      UserModel userModel, String finalAmount) async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ASP.NET_SessionId=sspo41ydr11xj2eoyrpzgor4'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://app.mychoize.com/Orix.ThirdPartyLive/BookingService/CreateBooking'));
    final body1 = {
      "CustomerType": "$myChoizeUserName",
      "CustomerSecurityToken": "$myChoizeKey",
      "Email": userModel.email,
      "LocationKey": carModel.myChoizeModel.locationKey,
      "DropDate": "\/Date(${model.endDateTime.millisecondsSinceEpoch}+0530)\/",
      "FuelType": carModel.myChoizeModel.fuelTypeCode,
      "TotalDiscountAmt": "0",
      "UnitChrg": "2099",
      "SecurityToken": "BEjguN2SNiAtL2fBE7z3yQ==",
      "PremuimRate": "0",
      "iOSUUID": "06B2F918-ED71-41A5-A23A-56E0F5355658",
      "AdditionalService": "",
      "AddServiceChrg": "0",
      "RentalType": "D",
      "DropChrg": "0",
      "HolidayDays": "",
      "CGTaxAmount": "0",
      "UserCode": userModel.uid,
      "PickAddress": carModel.pickUpAndDrop,
      "MinChrg": "${carModel.myChoizeModel.totalExpCharge}",
      "HolidayRate": "${carModel.myChoizeModel.totalExpCharge}",
      "LicanseKey2": "0",
      "IMEI_1": "",
      "AdditionalCouponKey": 0,
      "SourceType": "M",
      "UserName": userModel.name,
      "PremuimUnits": "",
      "FreeUnits": "",
      "LicanseKey": "0",
      "CouponKey": 0,
      "PassportKey": "0",
      "TotalAmt": "${carModel.myChoizeModel.totalExpCharge}",
      "TransmissionType": carModel.myChoizeModel.transMissionTypeCode,
      "GroupKey": carModel.myChoizeModel.groupKey,
      "BrandKey": carModel.myChoizeModel.brandKey,
      "BrandGroundLength": carModel.myChoizeModel.brandGroundLength,
      "DropAddress": carModel.pickUpAndDrop,
      "SecurityAmt": carModel.vendor.securityDeposit,
      "RFTEngineCapacity": "${carModel.myChoizeModel.rFTEngineCapacity}",
      "VTRSUVFlag": carModel.myChoizeModel.vTRSUVFlag,
      "VTRHybridFlag": carModel.myChoizeModel.vTRHybridFlag,
      "SeatingCapacity": "${carModel.myChoizeModel.seatingCapacity}",
      "PickDate":
          "\/Date(${model.startDateTime.millisecondsSinceEpoch}+0530)\/",
      "DropRegionKey": int.parse(carModel.selectedPickup.locationId),
      "LuggageCapacity": carModel.myChoizeModel.luggageCapacity,
      "GetBookingDetails": [
        {
          "rc_actual_return_date": model.startDateTime.toString(),
          "rc_stax_key": 0,
          "rc_base_amount": "2099",
          "rc_calc_method": "R",
          "rc_res_open_state_code": "",
          "rc_mode": "F",
          "rc_start_date": model.startDate.toString(),
          "rc_charges_key": -8463642,
          "rc_exchange_rate": "1",
          "rc_res_key": 0,
          "rc_rate": "2099",
          "rc_cust_state_code": "",
          "rc_currency_key": "INR",
          "rc_monthly_rate": "0",
          "rc_daily_rate": "0",
          "rc_weekly_rate": "0",
          "rc_expected_return_date": "01-Jan-0001 00:00:00",
          "rc_tax_code": "",
          "rc_activity_key": 10855,
          "rsetd_key_1": 0,
          "rc_local_amount": "2099",
          "rsetd_key_2": 0,
          "rc_notes": "",
          "rc_entry_mode": "A",
          "rc_quantity": 1
        },
        {
          "rc_notes": "",
          "rc_entry_mode": "A",
          "rsetd_key_2": 0,
          "rc_weekly_rate": "0",
          "rc_charges_key": -8463644,
          "rc_activity_key": 10820,
          "rc_monthly_rate": "0",
          "rc_daily_rate": "0",
          "rc_local_amount": "293.86",
          "rc_expected_return_date": "01-Jan-0001 00:00:00",
          "rc_res_key": 0,
          "rc_tax_code": "CG_SDCD_6",
          "rc_calc_method": "T",
          "rc_start_date": model.startDate.toString(),
          "rc_base_amount": "293.86",
          "rc_res_open_state_code": "HR",
          "rc_quantity": 0,
          "rc_actual_return_date": model.startDateTime.toString(),
          "rc_exchange_rate": "1",
          "rc_currency_key": "INR",
          "rc_rate": "14",
          "rsetd_key_1": 0,
          "rc_cust_state_code": "",
          "rc_mode": "F",
          "rc_stax_key": 917
        },
        {
          "rc_activity_key": 10820,
          "rc_expected_return_date": "01-Jan-0001 00:00:00",
          "rc_daily_rate": "0",
          "rc_rate": "14",
          "rc_calc_method": "T",
          "rc_res_key": 0,
          "rc_entry_mode": "A",
          "rsetd_key_2": 0,
          "rc_res_open_state_code": "HR",
          "rc_charges_key": -8463643,
          "rc_mode": "F",
          "rc_start_date": model.startDate.toString(),
          "rsetd_key_1": 0,
          "rc_tax_code": "SG_SDCD_6",
          "rc_currency_key": "INR",
          "rc_notes": "",
          "rc_local_amount": "293.86",
          "rc_actual_return_date": model.startDateTime.toString(),
          "rc_weekly_rate": "0",
          "rc_base_amount": "293.86",
          "rc_stax_key": 948,
          "rc_quantity": 0,
          "rc_cust_state_code": "",
          "rc_exchange_rate": "1",
          "rc_monthly_rate": "0"
        }
      ],
      "IGTaxAmount": "0",
      "TariffKey": carModel.myChoizeModel.tariffKey,
      "PickChrg": "0",
      "Password": "",
      "DLBase64Image": "",
      "RegularUnits": "1 Day(s) ",
      "actualdrop": "${myChoizeDate.format(model.endDateTime)}",
      "PassportBase64Image": "",
      "VATAmt": "293.86",
      "DLBase64Image_2": "",
      "TotalTax": "587.72",
      "actualpick": "${myChoizeDate.format(model.startDateTime)}",
      "RegularRate": "2099",
      "STAmount": "0",
      "EBDDiscount": "0",
      "IMEI_2": "",
      "ContactNo": userModel.phoneNumber,
      "BrandLength": carModel.myChoizeModel.brandLength,
      "PickRegionKey": int.parse(carModel.selectedPickup.locationId),
    };

    request.body = json.encode(body1);
    request.headers.addAll(headers);

    http.StreamedResponse responsee = await request.send();

    if (responsee.statusCode == 200) {
      print(await responsee.stream.bytesToString());
    } else {
      print(responsee.reasonPhrase);
    }
    return;
  }

  static getRentalType(DriveModel model) {
    if (model.drive == DriveTypes.SUB) {
      return 'MLK';
    } else {
      return 'D';
    }
  }
}
