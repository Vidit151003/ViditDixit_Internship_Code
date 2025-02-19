import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:letzrentnew/Services/car_services.dart';
import 'package:letzrentnew/Services/vendor_services/lowcars_model.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/models/car_model.dart';
import 'package:letzrentnew/models/user_model.dart';

class LowCarServices {
  static const baseUrl = "https://lowcars.co.in/APIv2/";
  static const hash = "hash=97d48065ba3a966a7adfcc49a1b346f8";
  static const carSearch = "car_search.php?";
  static const citySearch = "getCityList.php?$hash";

  static Future<List<CarModel>> getLowCars(
      DriveModel model, Vendor vendor, String packag) async {
    try {
      final cityId = await getLowCarsCities(model.city);
      if (cityId.isEmpty) {
        return [];
      }
      final date = dateFormatter.parse(model.startDate);
      final start = lowcarsDate.format(date);
      final date2 = dateFormatter.parse(model.endDate);
      final end = lowcarsDate.format(date2);
      final startTime = formatTime(model.starttime);
      final endTime = formatTime(model.endtime);
      final startDate = "inputPickupDate=${start}%20$startTime";
      final endDate = "inputDropDate=${end}%20$endTime";
      final city = "city_id=${cityId.first?.locationId}";
      final package = "package=$packag";
      final params = "$startDate&$endDate&$package&$city&$hash";
      final response =
          await http.get(Uri.parse(baseUrl + carSearch + params)).timeout(
                sevenSeconds,
                onTimeout: () => throw ("Timed Out"),
              );
      final data = jsonDecode(response.body);
      final List<CarModel> cars = [];
      data.forEach((car) {
        final model = LowCarsModel.fromJson(car);
        cars.add(CarModel(
            name: '',
            fuel: '',
            transmission: '',
            apiFlag: true,
            imageUrl: '',
            finalPrice: model.offerPrice * vendor.currentRate * vendor.discountRate,
            finalDiscount: (model.offerPrice * vendor.currentRate).toDouble(),
            isSoldOut: model.available != 'yes',)
          ..name = model.carName
          ..type = model.carType
          ..apiFlag = true
          ..carId = model.carId
          ..carGroupId = cityId.first.locationId
          ..transmission = "Manual"
          ..fuel = CarServices.getFuel(model.fuelType)
          ..seats = model.seats
          ..imageUrl = "https://lowcars.co.in/${model.carPic}"
          ..pickUpAndDrop = ""
          ..finalPrice =
              model.offerPrice * vendor.currentRate * vendor.discountRate
          ..finalDiscount = (model.offerPrice * vendor.currentRate).toDouble()
          ..actualPrice = model.offerPrice.toDouble()
          ..freeKm = model.kmFree
          ..isSoldOut = model.available != 'yes'
          ..packageName = packag
          ..vendor = vendor);
      });
      return cars;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static String formatTime(String time) => time.replaceAll(" ", "%20");

  static Future<List> getLowCarsCities(String city) async {
    try {
      final response = await http.get(Uri.parse(baseUrl + citySearch)).timeout(
            sevenSeconds,
            onTimeout: () => throw ("Timed Out"),
          );
      final data = jsonDecode(response.body);
      final list = [];
      data.forEach((val) {
        final cities = LowCarsCityModel.fromJson(val);
        if (cities.cityName.contains(city.toUpperCase())) {
          list.add(PickupModel(pickupAddress: city, locationId: cities.id)
            ..pickupAddress = city
            ..locationId = cities.id);
        }
      });
      return list;
    } catch (e) {
      print(e);
    }
    return [];
  }

  static Future<List<PickupModel>> getPickUpLocation(
      DriveModel model, CarModel car) async {
    final date = dateFormatter.parse(model.startDate);
    final date2 = dateFormatter.parse(model.endDate);
    final fromDate = lowcarsDate.format(date);
    final toDate = lowcarsDate.format(date2);
    final cityId = car.carGroupId;
    final mode = car.carId;
    final startTime = formatTime(model.starttime);
    final endTime = formatTime(model.endtime);
    final url =
        'https://lowcars.co.in//APIv2/getBookingFleet.php?fromdate=${fromDate}%20$startTime&todate=${toDate}%20$endTime&car_model=${mode}&city_id=${cityId}&hash=b4ce732f3d7d5cc75130a4ba4a5545e3';
    final response = await http.get(Uri.parse(url)).timeout(
          sevenSeconds,
          onTimeout: () => throw ("Timed Out"),
        );
    final data = jsonDecode(response.body);
    final List<PickupModel> pickups = [];
    data.forEach((val) {
      pickups.add(PickupModel(
          pickupAddress: val['fleet_name'],
          locationId: val['fleet_id'],
          deliveryCharges: 0));
    });
    return pickups;
  }

  static Future createBooking(
      CarModel carModel, UserModel userModel, DriveModel model) async {
    final startTime =
        DateFormat("HH:mm:ss").format(timeFormat.parse(model.starttime));
    final endTime =
        DateFormat("HH:mm:ss").format(timeFormat.parse(model.endtime));

    final start = lowcarsDate2.format(dateFormatter.parse(model.startDate));
    final end = lowcarsDate2.format(dateFormatter.parse(model.endDate));

    final bookingData = {
      'provider': appName,
      'user_name': userModel.name,
      'user_phone': userModel.phoneNumber,
      'pickupdate': '$start $startTime',
      'dropdate': '$end $endTime',
      'car_id': carModel.carId.toString(),  // Ensure it's a string
      'fleet_id': carModel.selectedPickup.locationId.toString(),  // Ensure it's a string
      'package': carModel.packageName,
      'allowed_km': carModel.freeKm.toString(),  // Ensure it's a string
      'booking_charge': carModel.actualPrice.toString(),  // Ensure it's a string
    };

    try {
      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      final request = http.Request(
          'POST',
          Uri.parse(
              'https://lowcars.co.in/APIv2/providers/creatingBooking.php'));
      request.bodyFields = bookingData;
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
      mixpanel.track('Lowcars booking success', properties: bookingData);
    } catch (e) {
      mixpanel.track('Lowcar booking error', properties: bookingData);
    }
  }
}
