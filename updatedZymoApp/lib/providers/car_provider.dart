import 'package:flutter/material.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:place_picker/place_picker.dart';

class CarProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaymentloading = false;
  bool get isPaymentLoading => _isPaymentloading;

  late double _initialPrice;
  double get initialPrice => _initialPrice;

  bool _codeApplied = false;
  bool get codeApplied => _codeApplied;

  double _discountPrice = 0;
  double get discountPrice => _discountPrice;

  late String _voucherId;
  String get voucherId => _voucherId;
  static final now = DateTime.now();
  DateTime _startDate = now.add(Duration(days: 2));
  DateTime get startDate => _startDate;
  DateTime _endDate = DateTime.now().add(Duration(days: 4));
  DateTime get endDate => _endDate;
  TimeOfDay _startTime = TimeOfDay(hour: 12, minute: 00);
  TimeOfDay get startTime => _startTime;
  TimeOfDay _endTime = TimeOfDay(hour: 12, minute: 00);
  TimeOfDay get endTime => _endTime;

  DriveTypes cdType = DriveTypes.AT;
  AirportTransferTypes atType = AirportTransferTypes.pickup;

  static const kInitialPosition = LatLng(-33.8567844, 151.213108);
  DateTime get startDateTime => DateTime(startDate.year, startDate.month,
      startDate.day, startTime.hour, startTime.minute);
  DateTime get endDateTime => DateTime(
      endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);

  late String _destinationLocation;
  String get destinationLocation => _destinationLocation;
  late LatLng _destinationLatLng;
  LatLng get destinationLatLng => _destinationLatLng;
  int getWeekdays() {
    int weekDays = 0;
    DateTime tempDate = startDateTime;

    while (tempDate.isBefore(endDateTime)) {
      if (tempDate.weekday != DateTime.friday &&
          tempDate.weekday != DateTime.saturday &&
          tempDate.weekday != DateTime.sunday) {
        weekDays++;
      }
      tempDate = tempDate.add(const Duration(days: 1));
    }
    return weekDays;
  }

  int getWeekends() {
    int weekends = 0;
    DateTime tempDate = startDateTime;

    while (tempDate.isBefore(endDateTime)) {
      if (tempDate.weekday == DateTime.friday ||
          tempDate.weekday == DateTime.saturday ||
          tempDate.weekday == DateTime.sunday) {
        weekends++;
      }
      tempDate = tempDate.add(const Duration(days: 1));
    }
    return weekends;
  }

  int getWeekendHours() {
    int weekendHours = 0;
    DateTime tempDate = startDateTime;

    while (tempDate.isBefore(endDateTime)) {
      if (tempDate.weekday == DateTime.friday ||
          tempDate.weekday == DateTime.saturday ||
          tempDate.weekday == DateTime.sunday) {
        final Duration x = endDateTime.difference(tempDate);
        if (x.inHours > 24) {
          weekendHours += 24;
        } else {
          weekendHours += x.inHours;
        }
      }
      tempDate = tempDate.add(const Duration(days: 1));
    }
    // weekendHours -= getRemainingHours(finalEndDate, finalEndDate);
    return weekendHours;
  }

  int getWeekDayHours() {
    int weekdayHours = 0;
    DateTime tempDate = startDateTime;

    while (tempDate.isBefore(endDateTime)) {
      if (tempDate.weekday != DateTime.friday &&
          tempDate.weekday != DateTime.saturday &&
          tempDate.weekday != DateTime.sunday) {
        final Duration x = endDateTime.difference(tempDate);
        if (x.inHours > 24) {
          weekdayHours += 24;
        } else {
          weekdayHours += x.inHours;
        }
      }
      tempDate = tempDate.add(const Duration(days: 1));
    }
    return weekdayHours;
  }

  void setVoucherId(String id) {
    _voucherId = id ?? '';
  }

  void setInitialPrice(double price) {
    _initialPrice = price;
    _initialPrice - _discountPrice;
    }

  void resetDiscountApplied() {
    _codeApplied = false;
    setDiscountTonull();
    notifyListeners();
  }

  void setDiscountTonull() {
    _discountPrice = 0;
  }

  void promoCodeApply(double discount) {
    _initialPrice -= discount;
    _discountPrice = discount;
    _codeApplied = true;
    notifyListeners();
  }

  void setStartAndEndDate(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setStartTime(TimeOfDay start) {
    _startTime = start;
    notifyListeners();
  }

  void setEndTime(TimeOfDay end) {
    _endTime = end;
    notifyListeners();
  }

  List<int> getRemainingDuration(
      DateTime start, DateTime end, TimeOfDay endT, TimeOfDay startT) {
    final int remainingHours = getRemainingHours(endT, startT);
    final int remainingDay = getRemainingDays(end, start, remainingHours);

    return [remainingDay, remainingHours.abs()];
  }

  int getRemainingDays(DateTime end, DateTime start, int remainingHours) {
    int remainingDay = end.difference(start).inDays;
    if (remainingHours < 0) {
      remainingDay -= 1;
    }
    if (remainingDay.isNegative) {
      return 0;
    }
    return remainingDay;
  }

  int getRemainingHours(TimeOfDay endT, TimeOfDay startT) {
    int remainingHours = endT.hour - startT.hour;
    if (remainingHours.isNegative) {
      remainingHours += 24;
      remainingHours *= -1;
    }
    return remainingHours;
  }

  String getTripDuration() {
    final List<int> duration =
        getRemainingDuration(_startDate, _endDate, _endTime, _startTime);
    final String dayString = duration[0] == 1 ? 'Day' : 'Days';
    final String hourString = duration[1] == 1 ? 'Hour' : 'Hours';
    final String days = duration[0] == 0 ? '' : '${duration[0]} $dayString';
    final String hours =
        duration[1] == 0 ? '' : ' ${duration[1]} $hourString';
    final String durationString = days + hours;
    return durationString;
    }

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void setCdType(DriveTypes type) {
    cdType = type;
    notifyListeners();
  }

  void setAtType(AirportTransferTypes type) {
    atType = type;
    notifyListeners();
  }

  void setDestinationLocation(LocationResult pickedLocation) {
    if (pickedLocation.formattedAddress != null) {
      _destinationLocation = pickedLocation.formattedAddress!;
      _destinationLatLng = pickedLocation.latLng!;
      notifyListeners();
    }
  }

  void startPayment() {
    _isPaymentloading = true;
    notifyListeners();
  }

  void endPayment() {
    _isPaymentloading = false;
    notifyListeners();
  }
}
