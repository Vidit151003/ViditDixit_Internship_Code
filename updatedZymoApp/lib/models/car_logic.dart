import 'car_model.dart';

class CarLogic {
  static num getFinalDiscountCd(
      Vendor vendor, int price, int ratePerHr, int hours) {
    final num finalPrice = ((price * 4) + (ratePerHr * (hours - 4))) *
        (1 + vendor.taxRate) *
        (vendor.currentRate);
    return finalPrice;
  }

  static double getFinalPriceCd(
      Vendor vendor, int price, int ratePerHr, int hours) {
    final double finalPrice = ((price * 4) + (ratePerHr * (hours - 4))) *
        (1 + vendor.taxRate) *
        (vendor.currentRate) *
        vendor.discountRate;
    return finalPrice;
  }

  static double? getFinalDiscountSD(
      Vendor vendor,
      double weekdayprice,
      double weekendprice,
      int weekendhr,
      int weekdayhr,
      double weekendperhr,
      double weekdayperhr,
      int weekdays,
      int weekends,
      bool isApi,
      int price) {
    double? finalDiscount;

    if (isApi) {
      finalDiscount = getFinalDiscountSd(vendor, price) as double?;
    } else {
      if (weekdayperhr == 0) {
        finalDiscount =
            ((weekdayprice * weekdays) + (weekendprice * weekends)) *
                (1 + vendor.taxRate) *
                vendor.currentRate;
      } else {
        finalDiscount =
            ((weekdayperhr * weekdayhr) + (weekendperhr * weekendhr)) *
                (1 + vendor.taxRate) *
                vendor.currentRate;
      }
    }
    return finalDiscount;
  }

  static double getFinalPriceSD(
      Vendor vendor,
      double weekdayprice,
      double weekendprice,
      int weekendhr,
      int weekdayhr,
      double weekendperhr,
      double weekdayperhr,
      int weekdays,
      int weekends,
      int price,
      bool isApi) {
    double finalPrice;

    if (isApi) {
      finalPrice = getFinalPriceSd(vendor, price);
    } else {
      if (weekdayperhr == 0) {
        finalPrice = ((weekdayprice * weekdays) + (weekendprice * weekends)) *
            (1 + vendor.taxRate) *
            vendor.currentRate *
            vendor.discountRate;
      } else {
        finalPrice = ((weekdayperhr * weekdayhr) + (weekendperhr * weekendhr)) *
            (1 + vendor.taxRate) *
            vendor.currentRate *
            vendor.discountRate;
      }
    }
    return finalPrice;
  }

  static num getFinalDiscountSd(Vendor vendor, int price) {
    final num finalPrice = price * (1 + vendor.taxRate) * vendor.currentRate;
    return finalPrice;
  }

  static double getFinalPriceSd(Vendor vendor, int price) {
    final double finalPrice =
        price * (1 + vendor.taxRate * vendor.currentRate) * vendor.discountRate;
    return finalPrice;
  }

  static double getFinalDiscountOs(Vendor vendor,
      {required int hours, required int ratePerKm, required double distance, required int driverCharges}) {
    final double finalDiscount = ((ratePerKm * distance) +
            (hours / 12).ceil() * (driverCharges ?? 250)) *
        (1 + vendor.taxRate) *
        vendor.currentRate;
    return finalDiscount;
  }

  static double getFinalPriceOs(Vendor vendor, int hours, int ratePerKm,
      double distance, int driverCharges) {
    final double finalDiscount = ((ratePerKm * distance) +
            (hours / 12).ceil() * (driverCharges ?? 250)) *
        (1 + vendor.taxRate) *
        (vendor.currentRate) *
        vendor.discountRate;
    return finalDiscount;
  }

  static num getFinalDiscountAt(Vendor vendor, int price) {
    final num finalDiscount =
        price * (vendor.currentRate) * (1 + vendor.taxRate);
    return finalDiscount;
  }

  static double getFinalPriceAt(Vendor vendor, int price) {
    final double finalPrice =
        (price * vendor.currentRate * vendor.discountRate) *
            (1 + vendor.taxRate);
    return finalPrice;
  }
}
