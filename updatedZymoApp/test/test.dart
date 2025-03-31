import 'package:flutter_test/flutter_test.dart';
import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/Utils/constants.dart';

void main() {
  group('Production Test', () {
    test('Production Environment Test', () {
      expect(currentEnv, Environment.Prod);
    });
    test('Zoom API Environment Test', () {
      expect(zoomProd, true);
    });
    test('MyChoize API Environment Test', () {
      expect(myChoizeProd, true);
    });
  });
}
