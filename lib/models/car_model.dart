import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/models/car_logic.dart';
import 'package:letzrentnew/models/document_model.dart';
import 'package:letzrentnew/models/mychoize_model.dart';

import '../Services/car_services.dart';

class DriveModel {
  late double balance;
  late int terminalId;
  late String driveString;
  late DocumentModel documents;
  late String bookingId;
  late String flightNumber;
  late DriveTypes? drive;
  late int hrs;
  late String startDate;
  late String endDate;
  late String city;
  late String starttime;
  late String endtime;
  late String mapLocation;
  late String remainingDuration;
  late double distanceOs;
  late LatLng mapLatLng;
  late int weekdayhr;
  late int weekendhr;
  late int weekends;
  late int weekdays;
  late String type;
  late List carGrouping;
  late DateTime startDateTime;
  late DateTime endDateTime;

  DriveModel(
      { this.drive,
      required this.mapLatLng,
      required this.distanceOs,
      required this.hrs,
      required this.startDate,
      required this.endDate,
      required this.city,
      required this.starttime,
      required this.endtime,
      required this.mapLocation,
      required this.remainingDuration,
      required this.type,
      required this.weekdays,
      required this.terminalId,
      required this.weekends,
      required this.weekendhr,
      required this.weekdayhr});

  DriveModel.fromJson(Map<String, dynamic> json) {
    drive = json['drive'];
    mapLatLng = json['mapLatLng'];
    hrs = json['hrs'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    city = json['city'];
    starttime = json['starttime'];
    endtime = json['endtime'];
    mapLocation = json['mapLocation'];
    remainingDuration = json['remainingDays'];
    distanceOs = json['distance'];
    weekdays = json['weekdays'];
    weekends = json['weekends'];
    weekdayhr = json['weekdayhr'] ?? 0;
    weekendhr = json['weekendhr'] ?? 0;
    type = json['type'];
  }
}

class CarModel {
  late var name;
  late var imageUrl;
  late List<String> multiImages;
  late var seats;
  late int rate;
  late var fuel;
  late var transmission;
  late String type;
  late int price;
  late var freeKm;
  late String ratingText;
  late String kmsDriven;
  late String carRatingText;
  late double carRating;
  late int ratePerKm;
  late int ratePerHr;
  late double weekdayperhr;
  late double weekendperhr;
  late double weekdayprice;
  late double weekendprice;
  late var finalDiscount;
  late double actualPrice;
  late var finalPrice;
  late String drive;
  late var extraKmCharge;
  late int extraHrCharge;
  late String vendorName;
  late String pickUpAndDrop;
  late String locationId;
  late List<PickupModel> pickups;
  late var toll;
  late int minHrs;
  late int driverCharges;
  late Vendor vendor;
  late int deliveryCharges;
  late bool apiFlag;
  late String pricingId;
  late String carId;
  late String carGroupId;
  late String package;
  late bool isSoldOut;
  late String packageName;
  late MyChoizeModel myChoizeModel;
  late PickupModel selectedPickup;

  CarModel(
      {this.name,
        this.fuel,
      this.transmission,
      required this.apiFlag,
      this.seats,
      this.imageUrl,
      this.freeKm,
      this.finalPrice,
      this.finalDiscount,
      this.isSoldOut=false,
      this.extraKmCharge});

  static String getFreeKm(DriveModel model, CarModel carModel) {
    String freekms='';
    if (model.drive == DriveTypes.WC) {
      freekms = "${model.hrs * 10} KMs FREE";
    } else if (model.drive == DriveTypes.RT || model.drive == DriveTypes.OW) {
      freekms = "${model.distanceOs} KMs";
    } else if (model.drive == DriveTypes.SD) {
      if (carModel.freeKm == null) {
        freekms = "Unlimited KMs";
      } else if (carModel.freeKm is String &&
          carModel.freeKm.toLowerCase().contains('unlimited')) {
        freekms = "Unlimited KMs";
      } else {
        freekms =
            "${CarServices.getFreeKm(carModel.freeKm, model.weekdayhr, model.weekendhr, carModel.apiFlag)} KMs FREE";
      }
    } else if (model.drive == DriveTypes.AT) {
      freekms = 'Includes ${carModel.freeKm} KMs';
    } else {
      if (freekms.toLowerCase().contains('free')) {
        freekms = '${carModel.freeKm}';
      } else
        freekms = '${carModel.freeKm} Free KMs';
    }

    return freekms;
  }

  CarModel.fromJson(
      Map<String, dynamic> json, Vendor tempVendor, DriveTypes driveType,
      {required DriveModel? driveModel, bool isApi=false}) {
    if (driveType == DriveTypes.OW) {
      if (tempVendor.advancePay == 0) {
        return;
      }
    }
    if (driveType == DriveTypes.SD) {
      final bool? is24 = driveModel?.startDateTime
          .subtract(Duration(hours: 24))
          .isAfter(DateTime.now());
      final int? tripDurationInHours =
          driveModel?.endDateTime.difference(driveModel.startDateTime).inHours;
      if ((tempVendor.name == myChoize || tempVendor.name == avis) &&
          ((tripDurationInHours! < 24) || !is24!)) {
        return;
      }
    }
    isSoldOut = json['isSoldOut'];
    apiFlag = isApi ?? false;
    vendor = tempVendor;
    name = json['name'];
    imageUrl = json['imageurl'] ?? json['imageUrl'];
    seats = json['seats'];
    fuel = json['fuel'];
    vendorName =
        json['vendor'] is String ? json['vendor'] : json['vendor']['name'];
    rate = json['rate'];
    transmission = json['transmission'] ?? 'Manual';
    price = json['price'] is double ? json['price'].toInt() : json['price'];
    freeKm = json['Free Km'] ?? json['freeKm'];
    type = json['type'];
    ratePerKm = json['ratePerKm'];
    ratePerHr = json['rateperhr'];
    toll = json['toll'];
    weekdayperhr = double.tryParse(json['weekdayperhr'].toString()) ?? 0;
    weekendperhr = double.tryParse(json['weekendperhr'].toString()) ?? 0;
    weekdayprice = double.tryParse(json['weekdayprice'].toString()) ?? 0;
    weekendprice = double.tryParse(json['weekendprice'].toString()) ?? 0;
    extraKmCharge = json['Extra Km Charge'] ?? json['extraKmCharge'];
    pickUpAndDrop = json['Pick/Drop Location'] ?? json['pickupLocation'];
    driverCharges = json['driverCharges'];
    minHrs = json['minhrs'];
    drive = json['drive'];
    pickups = (json['pickupLocations'] != null
        ? (json['pickupLocations'] as List).map((k) {
            return PickupModel.fromJson(k);
          }).toList()
        : null)!;

    switch (driveType) {
      case DriveTypes.WC:
        finalDiscount = CarLogic.getFinalDiscountCd(
            vendor, price, ratePerHr, driveModel!.hrs) as double;
        finalPrice =
            CarLogic.getFinalPriceCd(vendor, price, ratePerHr, driveModel.hrs);
        break;
      case DriveTypes.SD:
        finalDiscount = CarLogic.getFinalDiscountSD(
            vendor,
            weekdayprice,
            weekendprice,
            driveModel!.weekendhr,
            driveModel!.weekdayhr,
            weekendperhr,
            weekdayperhr,
            driveModel.weekdays,
            driveModel.weekends,
            apiFlag,
            price)!;
        finalPrice = CarLogic.getFinalPriceSD(
          vendor,
          weekdayprice,
          weekendprice,
          driveModel.weekendhr,
          driveModel.weekdayhr,
          weekendperhr,
          weekdayperhr,
          driveModel.weekdays,
          driveModel.weekends,
          price,
          apiFlag,
        );
        break;
      case DriveTypes.SUB:
        finalDiscount = CarLogic.getFinalDiscountSd(vendor, price) as double;
        finalPrice = CarLogic.getFinalPriceSd(vendor, price);
        break;
      case DriveTypes.RT:
        finalDiscount = CarLogic.getFinalDiscountOs(vendor,
            distance: driveModel!.distanceOs,
            hours: driveModel.hrs,
            ratePerKm: ratePerKm,
            driverCharges: driverCharges);
        finalPrice = CarLogic.getFinalPriceOs(vendor, driveModel.hrs, ratePerKm,
            driveModel.distanceOs, driverCharges);
        break;
      case DriveTypes.AT:
        finalDiscount = CarLogic.getFinalDiscountAt(vendor, price) as double;
        finalPrice = CarLogic.getFinalPriceAt(vendor, price);
        break;
      case DriveTypes.OW:
        finalDiscount = CarLogic.getFinalDiscountOs(vendor,
            distance: driveModel!.distanceOs,
            hours: driveModel.hrs,
            ratePerKm: ratePerKm,
            driverCharges: driverCharges);
        finalPrice = CarLogic.getFinalPriceOs(vendor, driveModel.hrs, ratePerKm,
            driveModel.distanceOs, driverCharges);
        break;
    }
  }
}

class Vendor {
  late  String name;
  late String promoCode;
  late String imageUrl;
  late double rating;
  late num currentRate;
  late double discountRate;
  late num taxRate;
  late double securityDeposit;
  late double subSecurityDeposit;
  late double advancePay;
  late String offer;
  late Api? api;
  late String plateColor;
  late MinHrsTillBooking minHrsTillBooking;
  late bool isV6;
  late Map discountMap;
  Vendor(
      {required this.name,
      required this.imageUrl,
      required this.currentRate,
      required this.discountRate,
      required this.securityDeposit,
      required this.subSecurityDeposit,
      required this.advancePay,
      required this.plateColor,
      required this.rating,
      required this.offer,
      required this.discountMap,
      this.api,
      required this.taxRate});
  Vendor.fromJson(Map<String, dynamic> json, DriveTypes type) {
    isV6 = json['isV6'] ?? false;
    final String drive = getDrive(type);
    discountMap = json['DiscountMap'] ?? {};
    api = Api.fromJson(json['Api']);
    offer = json['Offer'];
    name = json['vendor'] ?? json['name'];
    imageUrl = json['Imageurl'] ?? json['imageUrl'];
    plateColor = json['plateColor'];
    advancePay =
        json['advancePay'] ?? double.tryParse(json['BookingAmount'] ?? '') ?? 0;
    currentRate =
        json['currentRate'] ?? double.tryParse(json['Currentrate$drive'] ?? '');
    discountRate =
        json['discountRate'] ?? double.tryParse(json['Discount$drive'] ?? '');
    taxRate = json['taxRate'] ?? double.tryParse(json['Tax$drive'] ?? '');
    rating = double.parse(json['rating'].toString()) ?? 3;
    minHrsTillBooking = MinHrsTillBooking.fromJson(json['minHrsTillBooking']);
    promoCode = json['promoCode'];
    if (type == DriveTypes.SD || type == DriveTypes.SUB) {
      securityDeposit = double.tryParse(json['Securitydeposit'] ?? '') ?? 0;
      subSecurityDeposit = double.tryParse(json['subSecurityDeposit'] ?? '')!;
    } else {
      securityDeposit = 0;
    }
  }
  String getDrive(DriveTypes type) {
    switch (type) {
      case DriveTypes.WC:
        return 'Cd';
        break;
      case DriveTypes.SD:
        return 'Sd';
        break;
      case DriveTypes.SUB:
        return 'subscription';
        break;
      case DriveTypes.RT:
        return 'Os';
        break;
      case DriveTypes.AT:
        return 'At';
        break;
      case DriveTypes.OW:
        return 'Ow';
        break;
      default:
        return '';
    }
  }
}

class Api {
  late bool pu;
  late bool hd;

  Api.fromJson(Map<String, dynamic> json) {
    pu = json['PU'];
    hd = json['HD'];
    }
}

class MinHrsTillBooking {
  late double sd;
  late double sub;

  MinHrsTillBooking.fromJson(Map<String, dynamic> json) {
    sd = getDouble(json['sd']) ?? 12;
    sub = getDouble(json['sub']) ?? 24;
    }
  double getDouble(val) {
    if (val is double) {
      return val;
    } else if (val is int) {
      return val.toDouble();
    } else if (val is String) {
      return double.tryParse(val) ?? 12;
    } else {
      return 12;
    }
  }
}

class PickupModel {
  late String pickupAddress;
  late var deliveryCharges;
  late var locationId;
  late double distanceFromUser;

  PickupModel({required this.pickupAddress, this.deliveryCharges, this.locationId});

  PickupModel.fromJson(Map json) {
    pickupAddress = json['HubAddress'] ?? json['location'];
    deliveryCharges =
        json['price'] ?? int.tryParse(json['DeliveryCharge']) ?? 0;
    locationId = '${json['LocationKey']}';
    }
}
