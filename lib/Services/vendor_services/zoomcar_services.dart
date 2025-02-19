// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:letzrentnew/providers/car_provider.dart';
// import 'package:letzrentnew/providers/home_provider.dart';

// import 'package:letzrentnew/Utils/constants.dart';
// import 'package:letzrentnew/models/car_model.dart';
// import 'package:provider/provider.dart';

// import '../auth_services.dart';
// import '../car_services.dart';

// class ZoomCarServices {
//   static String zoomCarUrl = '${zoomUrl}v1/search?';
//   static String getZoomTokenUrl = '${zoomUrl}authenticate/token';
//   static String getZoomBookingDetailsUrl = '${zoomUrl}v1/bookings/';
//   static String zoomCarUserTokenUrl = '${zoomUrl}v1/users/auth';
//   static String bookingCreation = '${zoomUrl}v1/bookings';
//   static String cityList = '${zoomUrl}v1/cities';
//   static String zoomCarPaymentCreation = '${zoomUrl}v1/payments';
//   static String zoomCarTerminalsUrl = '${zoomUrl}v1/airport_terminals';

//   static List<CarModel> getCarModelFromApi(
//       List cars, Vendor vendor, Map allLocations, List filters) {
//     final List<CarModel> carList = [];
//     cars.forEach((element) {
//       if (element['name'] != null) {
//         final List carKms = element['pricing'];
//         final String type = _getCarType(filters, element);
//         carKms.forEach((carkms) {
//           final double price = double.parse(carkms['amount'].toString());
//           final CarModel model = CarModel()
//             ..name = element['name']
//             ..seats = element['seater']
//             ..type = type
//             ..apiFlag = true
//             ..transmission = element['manual'] ? 'Manual' : 'Automatic'
//             ..imageUrl = element['url_large']
//             ..finalPrice = price * vendor.currentRate * vendor.discountRate
//             ..finalDiscount = price * vendor.currentRate
//             ..actualPrice = price
//             ..freeKm = carkms['kms']
//             ..fuel = CarServices.getFuel(element['name'])
//             ..carId = "${element['id']}"
//             ..pickups = _getPickups(element, allLocations)
//             ..vendor = vendor
//             ..pricingId = "${carkms['id']}"
//             ..extraKmCharge = carkms['excess_kms'];
//           carList.add(model);
//         });
//       }
//     });
//     return carList;
//   }

//   static List<PickupModel> _getPickups(
//       element, Map<dynamic, dynamic> allLocations) {
//     final List<PickupModel> pickUps = [];
//     element['locations'].forEach((location) {
//       final String locationId = location['id'];
//       final locationDistance = allLocations[locationId];
//       if (locationDistance != null) {
//         final PickupModel pickUpModel = PickupModel()
//           ..deliveryCharges = 0
//           ..locationId = locationId
//           ..distanceFromUser = locationDistance['distance_to_sort']
//           ..pickupAddress = locationDistance['address'];
//         pickUps.add(pickUpModel);
//       }
//     });
//     return pickUps;
//   }

//   static String _getCarType(List<dynamic> filters, element) {
//     try {
//       final String type = filters[element['filter'] - 1];
//       return type.trim();
//     } catch (e) {
//       return '';
//     }
//   }

//   static Future<Map<String, dynamic>> getSecurityDeposit(BuildContext context,
//       String city, String carId, String pricingId, String locationId) async {
//     final CarProvider provider =
//         Provider.of<CarProvider>(context, listen: false);
//     final HomeProvider location =
//         Provider.of<HomeProvider>(context, listen: false);
//     final int startDate = provider.startDateTime.millisecondsSinceEpoch;
//     final int endDate = provider.endDateTime.millisecondsSinceEpoch;
//     final String token = await getTokenHttps();
//     final String userToken = await getUserToken(token);
//     // if (token == null || userToken == null) {
//     //   return null;
//     // }
//     final String platform = Platform.isIOS ? 'IOS' : 'android';
//     final Map<String, String> headers = {
//       'Content-Type': 'application/json',
//       'Accept': '*/*',
//       'USER-TOKEN': userToken,
//       'platform': platform,
//       'x-api-key': zoomCarApiKey,
//       'Authorization': 'Bearer $token',
//     };
//     if (city.contains('Bengaluru')) {
//       city = 'Bangalore';
//     } else if (city == 'Dombivli' || city == 'Thane') {
//       city = 'Mumbai';
//     } else if (city == 'Gurugram' || city == 'Noida') {
//       city = 'Delhi';
//     }
//     final String body = jsonEncode({
//       "booking_params": {
//         "type": "normal",
//         "cargroup_id": carId,
//         "city": city,
//         "ends": endDate,
//         "fuel_included": false,
//         "lat": location.locationLatLng.latitude,
//         "lng": location.locationLatLng.longitude,
//         "pricing_id": pricingId,
//         "starts": startDate,
//         "location_id": locationId
//       }
//     });
//     String error;
//     try {
//       final http.Response response = await http
//           .post(Uri.parse(bookingCreation), body: body, headers: headers)
//           .timeout(timeOutDuration, onTimeout: () => null);
//       final data = jsonDecode(response.body);
//       final Map bookingData = data['booking'];
//       error = data['error_title'];
//       var bookingData2 = bookingData['fare']['break_up'];
//       final double securityDeposit =
//           bookingData2.length > 1 ? bookingData2[1]['amount'] : 0;
//       final String bookingId = bookingData['confirmation_key'];
//       final Map<String, dynamic> responseData = {
//         'securityDeposit': securityDeposit,
//         'booking_id': bookingId
//       };
//       return responseData;
//     } catch (e) {
//       mixpanel.track('Booking error',
//           properties: {'response': error, 'error': e.toString()});
//       return {'error': error};
//     }
//   }

//   static Future<Map<String, dynamic>> homeDeliveryBookingCreation(
//       BuildContext context,
//       String city,
//       String carId,
//       String pricingId,
//       String street1,
//       String street2,
//       String pinCode) async {
//     final CarProvider provider =
//         Provider.of<CarProvider>(context, listen: false);
//     final HomeProvider location =
//         Provider.of<HomeProvider>(context, listen: false);
//     final int startDate = provider.startDateTime.millisecondsSinceEpoch;
//     final int endDate = provider.endDateTime.millisecondsSinceEpoch;
//     final String token = await getTokenHttps();
//     final String userToken = await getUserToken(token);
//     final String platform = Platform.isIOS ? 'IOS' : 'android';

//     final Map<String, String> headers = {
//       'Content-Type': 'application/json',
//       'Accept': '*/*',
//       'USER-TOKEN': userToken,
//       'platform': platform,
//       'x-api-key': zoomCarApiKey,
//       'Authorization': 'Bearer $token',
//     };
//     if (city.contains('Bengaluru')) {
//       city = 'Bangalore';
//     }
//     final String body = json.encode({
//       "booking_params": {
//         "type": "hd",
//         "cargroup_id": carId,
//         //    "location_id": locationId,
//         "city": city,
//         "ends": endDate,
//         "fuel_included": false,
//         "hd_params": {
//           "address_lines": street1,
//           "landmark": street2,
//           "locality": street2,
//           "zipcode": pinCode
//         },
//         "lat": location.locationLatLng.latitude,
//         "lng": location.locationLatLng.longitude,
//         "pricing_id": pricingId,
//         "starts": startDate,
//       }
//     });
//     String error;
//     try {
//       final http.Response response = await http
//           .post(Uri.parse(bookingCreation), body: body, headers: headers)
//           .timeout(timeOutDuration, onTimeout: () => null);
//       final data = jsonDecode(response.body);
//       final Map bookingData = data['booking'];
//       error = data['error_title'];
//       final double securityDeposit =
//           bookingData['fare']['break_up'][1]['amount'];
//       final double hd_fee = bookingData['fare']['break_up'][2]['amount'];
//       final String bookingId = bookingData['confirmation_key'];
//       final Map<String, dynamic> responseData = {
//         'securityDeposit': securityDeposit,
//         'booking_id': bookingId,
//         'hd_fee': hd_fee
//       };
//       return responseData;
//     } catch (e) {
//       return {'error': error};
//     }
//   }

//   static Future<String> getUserToken(String token, {bool isRetry}) async {
//     try {
//       final User user = Auth().getCurrentUser();
//       final String uid = user.uid;
//       final Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': '*/*',
//         'x-api-key': zoomCarApiKey,
//         'Authorization': 'Bearer $token',
//       };
//       final Map body = {"user_hash_id": '$uid'};
//       final http.Response response = await http
//           .post(Uri.parse(zoomCarUserTokenUrl),
//               headers: headers, body: jsonEncode(body))
//           .timeout(timeOutDuration, onTimeout: () => null);

//       final Map data = jsonDecode(response.body);
//       final String userToken = data['user_token'];
//       if (userToken == null && (isRetry ?? true)) {
//         final x = await retryUserTokenFunction(token, 5);
//         return x;
//       } else
//         return userToken;
//     } catch (e) {
//       print(e);
//       final x = await retryUserTokenFunction(token, 5);
//       return x;
//     }
//   }

//   static Future<Map> paymentCreationZoomCar(
//       String bookingId, int amount) async {
//     try {
//       final Map<String, dynamic> body = {
//         'booking_id': bookingId,
//         'amount': amount
//       };
//       final String token = await getTokenHttps();
//       final String userToken = await getUserToken(token);
//       final Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'x-api-key': zoomCarApiKey,
//         'USER-TOKEN': userToken,
//         'Authorization': 'Bearer $token',
//       };

//       final http.Response response = await http.post(
//           Uri.parse(zoomCarPaymentCreation),
//           headers: headers,
//           body: json.encode(body));
//       final Map data = jsonDecode(response.body);
//       return data;
//     } catch (e) {
//       return {'error': e.toString()};
//     }
//   }

//   static Future zoomCarUserDetails(String bookingId, String orderId,
//       String paymentCreationId, String name, String phone) async {
//     try {
//       final String body = json.encode({
//         'booking_id': bookingId,
//         'order_id': orderId,
//         'status': 1,
//         'user_details': {'name': name, 'phone': '$phone'}
//       });
//       final String token = await getTokenHttps();
//       final String userToken = await getUserToken(token);
//       final Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'x-api-key': zoomCarApiKey,
//         'USER-TOKEN': userToken,
//         'Authorization': 'Bearer $token',
//       };
//       final String uri = '$zoomCarPaymentCreation/$paymentCreationId';
//       final http.Response response =
//           await http.put(Uri.parse(uri), headers: headers, body: body);
//       final Map data = jsonDecode(response.body);
//       if (data['status'] != 1) {
//         throw {'Response': data, 'Request': body};
//       }
//       return data['status'] == 1;
//     } catch (e) {
//       final Map errorMap = {
//         'Error': e.toString(),
//         'BookingId': bookingId,
//         'Name': name,
//         'Phone': phone
//       };
//       log(errorMap.toString());
//       return errorMap;
//     }
//   }

//   static Future<List<CarModel>> zoomCar(
//       DriveModel model, String typeZoom, Vendor vendor,
//       {bool isRetry}) async {
//     try {
//       final String startDate =
//           dateFormatter.parse(model.startDate).toString().substring(0, 10);
//       final String endDate =
//           dateFormatter.parse(model.endDate).toString().substring(0, 10);
//       final String startTime =
//           TimeOfDay.fromDateTime(timeFormatter.parse(model.starttime))
//               .toString()
//               .replaceAll(RegExp("[(a-z, A-Z)]"), '');
//       final String endTime =
//           TimeOfDay.fromDateTime(timeFormatter.parse(model.endtime))
//               .toString()
//               .replaceAll(RegExp("[(a-z, A-Z)]"), '');
//       final String from = '$startDate $startTime';
//       final String to = '$endDate $endTime';
//       final String parameters = 'starts=$from&ends=$to';
//       final String lat = 'lat=${model.mapLatLng.latitude}';
//       final String lng = 'lng=${model.mapLatLng.longitude}';
//       final String latLng = '$lat&$lng';
//       final String type = 'type=$typeZoom';
//       const String fuel = 'fuel_bracket=no_fuel';
//       final String token = await getTokenHttps();
//       String city = model.city;
//       if (city == bengaluru) {
//         city = 'Bangalore';
//       } else if (city == 'Dombivli' || city == 'Thane') {
//         city = 'Mumbai';
//       } else if (city == 'Gurgaon' || city == 'Noida' || city == 'Ghaziabad') {
//         city = 'Delhi';
//       }
//       final Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': '*/*',
//         'x-api-key': zoomCarApiKey,
//         'Authorization': 'Bearer $token',
//       };
//       final String url =
//           '${zoomCarUrl}city=$city&$parameters&$latLng&$type&$fuel&d_city$city&d_$lat&d_$lng';
//       final http.Response response = await http
//           .get(Uri.parse(url), headers: headers)
//           .timeout(timeOutDuration, onTimeout: () => null);
//       if (response?.body == null && (isRetry ?? true)) {
//         return await retryZoomCar(4, model, typeZoom, vendor);
//       } else {
//         final data = jsonDecode(response.body);
//          return getZoomCarFromType(typeZoom, data, vendor);
//       }
//     } catch (e) {
//       log(e.toString());
//       return [];
//     }
//   }

//   static List<CarModel> getZoomCarFromType(
//       String typeZoom, data, Vendor vendor) {
//     final Map locations = data['locations_map'];
//     final String filters = data['alert']['filter_text'];
//     final List filterText = filters.split(',');
//     if (typeZoom == 'hd') {
//       final List cars = data['cars'];
//       return getZoomCarHomeDelivery(cars, vendor, filterText);
//     } else {
//       final List cars = data['result'][0]['cars'];
//       return getCarModelFromApi(cars, vendor, locations, filterText);
//     }
//   }

//   static Future<String> getTokenHttps({bool isRetry}) async {
//     try {
//       final Map<String, String> body = {"grant_type": "client_credentials"};
//       final String basicAuth =
//           'Basic ${base64Encode(utf8.encode('$zoomCarId:$zoomCarPassword'))}';
//       final Map<String, String> headers = {
//         'authorization': basicAuth,
//         'Content-Type': 'application/json'
//       };
//       final http.Response response = await http
//           .post(Uri.parse(getZoomTokenUrl),
//               headers: headers, body: jsonEncode(body))
//           .timeout(timeOutDuration, onTimeout: () => null);

//       final Map data = jsonDecode(response.body);
//       final String token = data['access_token'];

//       if (token == null && (isRetry ?? true)) {
//         final x = await retryFunction(10);
//         return x;
//       } else
//         return token;
//     } catch (e) {
//       return null;
//     }
//   }

//   static Future<String> retryFunction(int retry) async {
//     for (int i = 0; i < retry; i++) {
//       print('cars retry function $i');
//       await Future.delayed(Duration(milliseconds: 500));
//       final token = await getTokenHttps(isRetry: false);
//       if (token != null) {
//         return token;
//       }
//     }
//     return null;
//   }

//   static Future<String> retryUserTokenFunction(String tokenn, int retry) async {
//     for (int i = 0; i < retry; i++) {
//       print('User Token retry function $i');
//       final token = await getUserToken(tokenn, isRetry: false);
//       if (token != null) {
//         return token;
//       }
//     }
//     return null;
//   }

//   static Future<List<CarModel>> retryZoomCar(
//       int retry, DriveModel model, String typeZoom, Vendor vendor) async {
//     for (int i = 0; i < retry; i++) {
//       print('retry function $i');
//       final token = await zoomCar(model, typeZoom, vendor, isRetry: false);
//       if (token != null) {
//         return token;
//       }
//     }
//     return null;
//   }

//   static List<CarModel> getZoomCarHomeDelivery(
//       List cars, Vendor vendor, List filters) {
//     final List<CarModel> carList = [];
//     cars.forEach((element) {
//       if (element['name'] != null) {
//         final List carKms = element['pricings'] ?? [];
//         final String type = _getCarType(filters, element);
//         final List element2 = element['location_id'];

//         final int locationId = element2.isNotEmpty ? element2[0] : 0;
//         carKms.forEach((carkms) {
//           final double price = double.parse(carkms['amount'].toString());
//           final CarModel model = CarModel()
//             ..name = element['name']
//             ..seats = element['seater']
//             ..type = type
//             ..apiFlag = true
//             ..transmission = element['manual'] ? 'Manual' : 'Automatic'
//             ..imageUrl = element['url_large']
//             ..finalPrice = price * vendor.currentRate * vendor.discountRate
//             ..finalDiscount = price * vendor.currentRate
//             ..actualPrice = price
//             ..freeKm = carkms['kms']
//             ..fuel = CarServices.getFuel(element['name'])
//             ..carId = "${element['id']}"
//             ..pickUpAndDrop = homeDelivery
//             ..locationId = '$locationId'
//             ..vendor = vendor
//             ..pricingId = "${carkms['id']}"
//             ..extraKmCharge = carkms['excess_kms'];
//           carList.add(model);
//         });
//       }
//     });
//     return carList;
//   }
// }
