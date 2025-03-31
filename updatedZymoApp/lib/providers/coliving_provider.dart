import 'package:flutter/material.dart';

class ColivingProvider with ChangeNotifier {
  final List<String> _locationList = [];
  List<String> get locationList => _locationList;
  bool _showTile = true;
  bool get showTile => _showTile;

  void addLocationItem(List<String> itemList) {
    if (_locationList.isEmpty) {
      itemList.forEach((element) {
        if (!_locationList.contains(element)) {
          _locationList.add(element);
        }
      });

      notifyListeners();
    }
  }

  void clearLocations() {
    locationList.clear();
  }

  void dontShowTile() {
    _showTile = false;
    notifyListeners();
  }
}
