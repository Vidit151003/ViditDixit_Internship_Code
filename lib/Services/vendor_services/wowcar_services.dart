import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/extensions.dart';
import 'package:letzrentnew/models/car_model.dart';

class WowCarServices {
  static const String baseUrl =
      'https://us-central1-letzrent-5f5a3.cloudfunctions.net/customFunction';
  static const String wowCarsMonthlyUrl =
      'https://wowcarz.in/api/lentsrent/getsubscriptionrental';
  static const String wowCarsSelfDriveUrl =
      'https://wowcarz.in/api/lentsrent/getDailyRental?';
  //https://wowcarz.rocketfleet.in/api/lentsrent/getDailyRental?from=2022-06-25T18:30&to=2022-06-26T15:30

  static Future<List<CarModel>> getMonthlyRentalCars({required Vendor vendor}) async {
    final List<CarModel> list = [];
    try {
      final http.Response response = await http
          .get(Uri.parse(wowCarsMonthlyUrl))
          .timeout(timeOutDuration,);

      final List data = jsonDecode(response.body);
      data.forEach((element) {
        vendor.securityDeposit = vendor.subSecurityDeposit;
        list.add(CarModel.fromJson(element, vendor, DriveTypes.SUB, driveModel: null, ));
      });
      return list;
    } catch (e) {
      return list;
    }
  }

  static Future<List<CarModel>> getWowCarSD(DriveModel model, Vendor? vendor,) async {
    final List<CarModel> list = [];
    try {
      final String startDate =
          dateFormatter.parse(model.startDate).toString().substring(0, 10);
      final String endDate =
          dateFormatter.parse(model.endDate).toString().substring(0, 10);

      DateTime parse = timeFormat.parse(model.starttime);
      final String startTime = TimeOfDay.fromDateTime(parse)
          .toString()
          .replaceAll(RegExp("[(a-z, A-Z)]"), '');
      final String endTime = TimeOfDay.fromDateTime(timeFormat.parse(model.endtime))
          .toString()
          .replaceAll(RegExp("[(a-z, A-Z)]"), '');

      final String from = '${startDate}T$startTime';
      final String to = '${endDate}T$endTime';
      final String parameters = 'from=$from&to=$to';
      final http.Response response = await http
          .get(Uri.parse(wowCarsSelfDriveUrl + parameters))
          .timeout(timeOutDuration,);

      final List data = jsonDecode(response.body);
      data.forEach((element) {
        vendor?.securityDeposit;
        final CarModel carModel = CarModel(name:'${element['name']}',
          seats:element['seats'],

          apiFlag:true,
          transmission:element['transmission'],
          imageUrl:element['imageurl'],
          finalPrice:
          element['price'] * vendor?.currentRate * vendor?.discountRate,
          finalDiscount:element['price'] * vendor?.currentRate,

          freeKm:element['freeKm'],
          fuel:(element['fuel'] as String).firstLetterUpper(),
          extraKmCharge :element['extraKmCharge'],)
        ..pickups= deliveryWow
        ..pickUpAndDrop= element['Pick/Drop Location']
        ..vendor= vendor!
        ..actualPrice=(element['price'] as int).toDouble()
        ..type= element['type'];
        list.add(carModel);
      });
    } catch (e) {
      print(e);
    }
    return list;
  }
}
