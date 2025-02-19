import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/models/car_model.dart';

import '../Utils/constants.dart';

class HttpServices {
  static const firebaseUrl =
      'https://us-central1-letzrent-5f5a3.cloudfunctions.net/httpFunctions/';
  static Future<http.Response> getDistance(
      LatLng user, LatLng destination) async {
    final distanceUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${user.latitude},${user.longitude}&destination=${destination.latitude},${destination.longitude}${"&key=$GoogleApiKey"}";

    return http
        .get(Uri.parse(distanceUrl))
        .timeout(timeOutDuration,);
  }

  static Future<String> cashFree(String orderId, int orderAmount) async {
    const String getTokenUrl = '${firebaseUrl}cashFreeToken';

    const Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map body = {
      "orderId": orderId,
      "orderAmount": orderAmount,
      "orderCurrency": "INR"
    };
    final Response response = await http.post(Uri.parse(getTokenUrl),
        headers: headers, body: jsonEncode(body));
    final Map data = jsonDecode(response.body);
    print(data);
    return data['cftoken'];
  }

  static Future<String> sendWhatsapp(String phone, String message) async {
    const String getTokenUrl = '${firebaseUrl}sendWhatsapp';

    const Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map body = {"phone": phone, "message": message};
    final Response response = await http.post(Uri.parse(getTokenUrl),
        headers: headers, body: jsonEncode(body));
    final Map data = jsonDecode(response.body);
    print(data);
    return data['cftoken'];
  }

  static Future<bool> cancelBooking(String bookingId, String uid) async {
    try {
      const String getTokenUrl = '${firebaseUrl}cancelZoomBooking';

      const Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      final Map body = {
        "bookingId": bookingId,
        "uid": uid,
      };
      final Response response = await http.post(Uri.parse(getTokenUrl),
          headers: headers, body: jsonEncode(body));
      final Map data = jsonDecode(response.body);
      print(data);
      if (!data['status']) {
        mixpanel.track('Zoom Cancellation Request API Failed',
            properties: {'BookingId': bookingId, 'Error': 'false returned'});
      }
    } catch (e) {
      mixpanel.track('Zoom Cancellation Request API Failed',
          properties: {'BookingId': bookingId, 'Error': e.toString()});
      return false;
    }
    return true;
  }

  // static Future<bool> createMyChoizeBooking(Map bodyMap) async {
  //
  //   try {
  //     const String getTokenUrl = '${firebaseUrl}createMyChoize';
  //     const Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //     };
  //     final Map body = bodyMap;
  //     final Response response = await http.post(Uri.parse(getTokenUrl),
  //         headers: headers, body: jsonEncode(body));
  //     final Map data = jsonDecode(response.body);
  //     print(data);
  //     if (!data['status']) {
  //       mixpanel.track('MyChoize API Request Failed', properties: {
  //         'BookingId': bodyMap['bookingId'],
  //         'Error': 'false returned'
  //       });
  //     }
  //   } catch (e) {
  //     mixpanel.track('MyChoize API Cancellation Request Failed', properties: {
  //       'BookingId': bodyMap['bookingId'],
  //       'Error': e.toString()
  //     });
  //     return false;
  //   }
  //   return true;
  // }

  static Future<List<CarModel>> getMonthlyRentalCars(DriveModel model) async {
    final List<CarModel> cars = [];
    // try {
    const String getTokenUrl = '${firebaseUrl}getMonthlyRentalCars';

    const Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final String startDate =
        dateFormatter.parse(model.startDate).toString().substring(0, 10);
    final String endDate =
        dateFormatter.parse(model.endDate).toString().substring(0, 10);
    //"6:00 AM"
    final String startTime =
        TimeOfDay.fromDateTime(timeFormat.parse(model.starttime))
            .toString()
            .replaceAll(RegExp("[(a-z, A-Z)]"), '');
    final String endTime =
        TimeOfDay.fromDateTime(timeFormat.parse(model.endtime))
            .toString()
            .replaceAll(RegExp("[(a-z, A-Z)]"), '');
    final Map body = {
      "startDate": startDate,
      "startTime": startTime,
      "endDate": endDate,
      "endTime": endTime,
      "city": model.city
    };
    final Response response = await http.post(Uri.parse(getTokenUrl),
        headers: headers, body: jsonEncode(body));
    final data = jsonDecode(response.body);
    print(data);
    data.forEach((element) {
      if (element == null) {
        return;
      }
      final price = element['price'];
      final Vendor vendor = Vendor.fromJson(element['vendor'], model.drive!);
      final CarModel carModel = CarModel(apiFlag: true)
        ..name = element['name']
        ..seats = element['seat']
        ..type = element['type']
        ..apiFlag = true
        ..isSoldOut = element['isSoldOut'] ?? false
        ..transmission = element['Transmission'] ?? 'Manual'
        ..imageUrl = element['imageUrl']
        ..finalPrice = price * vendor.currentRate * vendor.discountRate
        ..finalDiscount = price * vendor.currentRate
        ..freeKm = element['freeKm']
        ..fuel = element['fuel'] ?? 'Petrol'
        ..carId = "${element['id']}"
        ..pickups = (element['pickupLocations'] as List).map((k) {
          return PickupModel.fromJson(k);
        }).toList()
        ..vendor = vendor
        ..extraKmCharge = element['extraKmCharge'];
      cars.add(carModel);
    });
    return cars;
  }

  static Future<LatLng?> getLatLng(String location) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$location&sensor=true&key=$GoogleApiKey';
      // final distanceUrl =
      //     "https://maps.googleapis.com/maps/api/directions/json?origin=${user.latitude},${user.longitude}&destination=${destination.latitude},${destination.longitude}${"&key=$GoogleApiKey"}";

      final response = await http
          .get(Uri.parse(url))
          .timeout(timeOutDuration,);
      final data = jsonDecode(response.body);

      final coordinates = data['results'][0]['geometry']['location'];
      return LatLng(coordinates['lat'], coordinates['lng']);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
