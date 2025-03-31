import 'dart:convert';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:letzrentnew/Services/http_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/functions.dart';
import 'package:letzrentnew/models/car_model.dart';
import 'package:letzrentnew/providers/car_provider.dart';
import 'package:letzrentnew/providers/home_provider.dart';
import 'package:letzrentnew/widgets/Cars/car_view.dart';
import 'package:provider/provider.dart';

import 'firebase_services.dart';

class CarFunctions {
  late DateTime _selectedDate;

  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 00);

  late DateTime _endDate;

  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 00);

  late final DateTime now;
  late final DateTime oneYearFromNow;

  void onSelectedStartDate(DateTime args) {
    _selectedDate = args;
  }

  void onSelectedEndDate(DateTime args) {
    _endDate = args;
  }

  void startTimePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 0.4.sh,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text('Start time',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: DateTime.fromMillisecondsSinceEpoch(
                              1616826600000),
                          minuteInterval: 30,
                          onDateTimeChanged: (val) {
                            _startTime =
                                TimeOfDay(hour: val.hour, minute: val.minute);
                          }),
                    ),
                    AppButton(
                      screenWidth: 1.sw,
                      screenHeight: 1.sh,
                      title: 'Done',
                      function: () {
                        Provider.of<CarProvider>(context, listen: false)
                            .setStartTime(_startTime);
                        Navigator.of(context).pop();
                      },
                      textSize: 15,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            ));
  }

  void endTimePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 0.4.sh,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text('End time',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: DateTime.fromMillisecondsSinceEpoch(
                              1616826600000),
                          minuteInterval: 30,
                          onDateTimeChanged: (val) {
                            _endTime =
                                TimeOfDay(hour: val.hour, minute: val.minute);
                            Provider.of<CarProvider>(context, listen: false)
                                .setEndTime(_endTime);
                          }),
                    ),
                    AppButton(
                      screenWidth: 1.sw,
                      screenHeight: 1.sh,
                      title: 'Done',
                      function: () {
                        Provider.of<CarProvider>(context, listen: false)
                            .setEndTime(_endTime);
                        Navigator.of(context).pop();
                      },
                      textSize: 15,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            ));
  }

  Future<void> startDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: oneYearFromNow,
      builder: (context, child) =>
          child ?? const SizedBox(), // Ensure child is not null
    );

    if (picked != null) {
      _selectedDate = picked; // Update _selectedDate
      onSelectedStartDate(picked);

      Provider.of<CarProvider>(context, listen: false)
          .setStartAndEndDate(_selectedDate, _endDate); // Pass both arguments
    }
  }

  Future<void> endDatePicker(BuildContext context) async {
    if (_selectedDate == null) {
      // Prevents end date picker from opening if start date isn't set
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _selectedDate ?? now,
      firstDate: _selectedDate!,
      // Ensure _selectedDate is not null
      lastDate: oneYearFromNow,
      builder: (context, child) =>
          child ?? const SizedBox(), // Ensure child is not null
    );

    if (picked != null) {
      _endDate = picked; // Update _endDate
      onSelectedEndDate(picked);

      Provider.of<CarProvider>(context, listen: false)
          .setStartAndEndDate(_selectedDate, _endDate); // Pass both arguments
    }
  }

  bool validateMonthlyRental(BuildContext context, CarProvider provider,
      {required int minimumBookingDuration}) {
    bool isValid = false;
    const hours2 = 8;
    if (provider.startDateTime
        .isBefore(DateTime.now().add(const Duration(hours: hours2)))) {
      warningPopUp(
          context, oops, 'Bookings only available $hours2 hours in advance.');
    } else {
      isValid = true;
    }
    return isValid;
  }

  static bool validateSelfDrive(
    BuildContext context,
    CarProvider provider,
  ) {
    var advanceHours = 2;
    bool isValid = false;
    if (provider.startDateTime.isAfter(provider.endDateTime)) {
      warningPopUp(context, oops, 'Start date cannot be after end date');
    } else if (provider.startDateTime
        .isBefore(DateTime.now().add(Duration(hours: advanceHours)))) {
      warningPopUp(context, oops,
          'Bookings only available $advanceHours hours in advance.');
    } else if (provider.startDateTime
        .add(Duration(hours: 8))
        .isAfter(provider.endDateTime)) {
      warningPopUp(context, oops, 'Minimum booking duration of ${8} hours');
    } else {
      isValid = true;
    }
    return isValid;
  }

  static Future<String> getCity(String type, String location) async {
    List cities = [];
    String city = '';
    await FirebaseServices()
        .getCarCity(type)
        .then((value) => cities = value['cities']);
    if (location.contains('Maharashtra')) {
      city = 'Mumbai';
    } else if (location.contains('Bangalore')) {
      city = bengaluru;
    } else if (location.contains('Mysuru')) {
      city = 'Mysore';
    } else if (city == 'Telangana') {
      city = 'Hyderabad';
    } else if (location.contains('Ghaziabad') ||
        location.contains('Noida') ||
        location.contains('Gurugram')) {
      city = 'Delhi';
    }
    cities.forEach((element) {
      if (location.contains(element)) {
        city = element ?? '';
      }
      ;
    });
    return city;
  }

  static Future<void> selfDriveNavigate(BuildContext context) async {
    final CarProvider provider =
        Provider.of<CarProvider>(context, listen: false);
    provider.startLoading();

    try {
      final bool isValid = validateSelfDrive(
        context,
        provider,
      );
      if (!isValid) {
        return;
      }
      final HomeProvider locationProvider =
          Provider.of<HomeProvider>(context, listen: false);
      final String city = await getCity('sd', locationProvider.location)
          .timeout(timeOutDuration);
      final List carGrouping = await getCarGroups().timeout(timeOutDuration);
      final String duration = provider.getTripDuration();
      final DriveModel model = DriveModel(
        city: city,
        type: '',
        drive: DriveTypes.SD,
        endDate: dateFormatter.format(provider.endDateTime),
        endtime: provider.endTime.format(context),
        mapLatLng: locationProvider.locationLatLng,
        distanceOs: 0,
        hrs: 0,
        startDate: dateFormatter.format(provider.startDateTime),
        starttime: provider.startTime.format(context),
        mapLocation: locationProvider.location,
        remainingDuration: duration,
        weekdays: provider.getWeekdays(),
        terminalId: 0,
        weekends: provider.getWeekends(),
        weekendhr: provider.getWeekendHours(),
        weekdayhr: provider.getWeekDayHours(),
      )
        ..drive = DriveTypes.SD
        ..startDate = dateFormatter.format(provider.startDateTime)
        ..endDate = dateFormatter.format(provider.endDateTime)
        ..endtime = provider.endTime.format(context)
        ..starttime = provider.startTime.format(context)
        ..weekdays = provider.getWeekdays()
        ..weekends = provider.getWeekends()
        ..weekdayhr = provider.getWeekDayHours()
        ..weekendhr = provider.getWeekendHours()
        ..mapLocation = locationProvider.location
        ..mapLatLng = locationProvider.locationLatLng
        ..remainingDuration = duration
        ..city = city
        ..startDateTime = provider.startDateTime
        ..endDateTime = provider.endDateTime
        ..carGrouping = carGrouping;
      await locationProvider.setRecentSearch(duration, model.startDate,
          model.starttime, model.endDate, model.endtime);
      await CommonFunctions.navigateTo(
          context,
          CarsView(
            model: model,
          ));
    } catch (e) {
      warningPopUp(
          context, 'Oops!', 'Something went wrong. Please try again. $e');
    } finally {
      provider.stopLoading();
    }
  }

  Future<void> monthlyRentalNavigate(BuildContext context) async {
    final CarProvider provider =
        Provider.of<CarProvider>(context, listen: false);
    provider.startLoading();
    final HomeProvider locationProvider =
        Provider.of<HomeProvider>(context, listen: false);

    final bool isValid = validateMonthlyRental(
      context,
      provider,
      minimumBookingDuration: 30,
    );

    try {
      if (!isValid) return;

      // Ensure startDateTime is set before using it
      if (provider.startDateTime == null) {
        throw Exception("Start date is not selected.");
      }

      provider.setEndTime(provider.startTime);
      provider.setStartAndEndDate(
        provider.startDateTime,
        provider.startDateTime.add(const Duration(days: 30)),
      );

      final List<dynamic> carGrouping = await getCarGroups();
      final String city =
          await getCity('subscription', locationProvider.location);

      final DriveModel model = DriveModel(
        city: city,
        type: '',
        drive: DriveTypes.SUB,
        endDate: dateFormatter.format(provider.endDateTime),
        endtime: provider.endTime.format(context),
        mapLatLng: locationProvider.locationLatLng,
        distanceOs: 0,
        hrs: 0,
        startDate: dateFormatter.format(provider.startDateTime),
        starttime: provider.startTime.format(context),
        mapLocation: locationProvider.location,
        remainingDuration: '30 Days',
        weekdays: provider.getWeekdays(),
        terminalId: 0,
        weekends: provider.getWeekends(),
        weekendhr: provider.getWeekendHours(),
        weekdayhr: provider.getWeekDayHours(),
      )
        ..drive = DriveTypes.SUB
        ..carGrouping = carGrouping
        ..startDate = dateFormatter.format(provider.startDateTime)
        ..endDate = dateFormatter.format(provider.endDateTime)
        ..startDateTime = provider.startDateTime
        ..endDateTime = provider.endDateTime
        ..starttime = provider.startTime.format(context)
        ..weekdays = provider.getWeekdays()
        ..weekends = provider.getWeekends()
        ..weekdayhr = provider.getWeekDayHours()
        ..weekendhr = provider.getWeekendHours()
        ..mapLocation = locationProvider.location
        ..mapLatLng = locationProvider.locationLatLng
        ..remainingDuration = '30 Days'
        ..city = city
        ..endtime = provider.endTime.format(context);

      await CommonFunctions.navigateTo(context, CarsView(model: model));
    } catch (e, stackTrace) {
      // Log error for debugging
      debugPrint("Error in monthlyRentalNavigate: $e\n$stackTrace");
      warningPopUp(
          context, 'Oops!', 'Something went wrong. Please try again.\n$e');
    } finally {
      provider.stopLoading();
    }
  }

  Future<void> outstationFunction(HomeProvider locationProvider,
      CarProvider provider, BuildContext context) async {
    final bool isValid = validateSelfDrive(
      context,
      provider,
    );
    if (!isValid) {
      return;
    }
    final String city = await getCity('os', locationProvider.location);
    final List carGrouping = await getCarGroups();
    final double distance = await getDistance(locationProvider.locationLatLng,
        provider.destinationLatLng, provider.cdType);
    final int hrs =
        provider.endDateTime.difference(provider.startDateTime).inHours;
    final DriveModel model = DriveModel(
        city: city,
        drive: provider.cdType,
        startDate: dateFormatter.format(provider.startDateTime),
        endDate: dateFormatter.format(provider.endDateTime),
        starttime: provider.startTime.format(context).toString(),
        endtime: provider.endTime.format(context).toString(),
        mapLatLng: locationProvider.locationLatLng,
        mapLocation: locationProvider.location,
        distanceOs: distance,
        hrs: hrs,
        remainingDuration: provider.getTripDuration(),
        type: '',
        weekdays: 0,
        terminalId: 0,
        weekends: 0,
        weekendhr: 0,
        weekdayhr: 0)
      ..drive = provider.cdType
      ..carGrouping = carGrouping
      ..city = city
      ..startDate = dateFormatter.format(provider.startDateTime)
      ..endDate = dateFormatter.format(provider.endDateTime)
      ..starttime = provider.startTime.format(context).toString()
      ..endtime = provider.endTime.format(context).toString()
      ..mapLocation = locationProvider.location
      ..mapLatLng = locationProvider.locationLatLng
      ..remainingDuration = provider.getTripDuration()
      ..hrs = hrs
      ..distanceOs = distance;
    await CommonFunctions.navigateTo(context, CarsView(model: model));
  }

  static Future<void> withinCityFunction(HomeProvider locationProvider,
      CarProvider provider, BuildContext context) async {
    final bool isValid = validateSelfDrive(
      context,
      provider,
    );
    if (!isValid) {
      return;
    }
    final int hrs =
        provider.endDateTime.difference(provider.startDateTime).inHours;
    final String city = await getCity('cd', locationProvider.location);
    final List carGrouping = await getCarGroups();
    final DriveModel model = DriveModel(
        drive: DriveTypes.WC,
        city: city,
        startDate: dateFormatter.format(provider.startDateTime),
        endDate: dateFormatter.format(provider.endDateTime),
        starttime: provider.startTime.format(context).toString(),
        endtime: provider.endTime.format(context).toString(),
        mapLatLng: locationProvider.locationLatLng,
        distanceOs: 0,
        hrs: hrs,
        mapLocation: locationProvider.location,
        remainingDuration: provider.getTripDuration(),
        type: '',
        weekdays: 0,
        terminalId: 0,
        weekends: 0,
        weekendhr: 0,
        weekdayhr: 0)
      ..drive = DriveTypes.WC
      ..city = city
      ..carGrouping = carGrouping
      ..startDate = dateFormatter.format(provider.startDateTime)
      ..endDate = dateFormatter.format(provider.endDateTime)
      ..starttime = provider.startTime.format(context).toString()
      ..endtime = provider.endTime.format(context).toString()
      ..mapLocation = locationProvider.location
      ..mapLatLng = locationProvider.locationLatLng
      ..hrs = hrs
      ..remainingDuration = provider.getTripDuration();

    await CommonFunctions.navigateTo(context, CarsView(model: model));
  }

  Future cdType(CarProvider provider, HomeProvider locationProvider,
      BuildContext context) async {
    switch (provider.cdType) {
      case DriveTypes.RT:
        await outstationFunction(locationProvider, provider, context);
        break;
      case DriveTypes.OW:
        await outstationFunction(locationProvider, provider, context);
        break;
      case DriveTypes.AT:
        break;

      case DriveTypes.WC:
        await withinCityFunction(locationProvider, provider, context);
        break;
      case DriveTypes.SD:
        break;
      case DriveTypes.SUB:
        break;
    }
  }

  Future<String> getTripDetails(LatLng user, LatLng destination) {
    return HttpServices.getDistance(user, destination)
        .then((Response response) {
      String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        res =
            "{\"status\":$statusCode,\"message\":\"error\",\"response\":$res}";
        throw Exception(res);
      }
      try {
        final String _distance = const JsonDecoder()
                .convert(res)["routes"][0]["legs"][0]["distance"]['text']
                .toString() ??
            'No distance';

        return _distance;
      } catch (e) {
        throw Exception(res);
      }
    });
  }

  Future<double> getDistance(
      LatLng user, LatLng destination, DriveTypes type) async {
    final String _distance = await getTripDetails(user, destination);
    final double minDistance = type == DriveTypes.RT ? 250 : 150;
    final int times = type == DriveTypes.RT ? 2 : 1;
    final int length = _distance.toString().length;
    double distance = double.parse(
            _distance.toString().substring(0, length - 2).replaceAll(',', '')) *
        times;
    if (distance < minDistance) {
      distance = minDistance;
    }
    return distance;
  }

  static Future<List<dynamic>> getCarGroups() async {
    final DocumentSnapshot<Object?> doc =
        await FirebaseServices().getCarGroupingNames();

    if (!doc.exists || doc.data() == null) {
      return []; // Return an empty list if the document is missing
    }

    final data = doc.data() as Map<String, dynamic>?; // Ensure type safety
    final List<dynamic>? carData = data?['Keyword'] as List<dynamic>?;

    return carData ?? []; // Return an empty list if 'Keyword' is null
  }
}
