import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/models/car_model.dart';
import 'package:letzrentnew/models/user_model.dart';

import 'auth_services.dart';

class FirebaseServices {
  User? get user => Auth().getCurrentUser();
  final FirebaseFirestore firebase = FirebaseFirestore.instance;

  Future<bool> addReferralVouchers(
      String referralUid, String uid, int amount) async {
    final String date = dateFormatter.format(DateTime.now());
    mixpanel.track('Referral Complete', properties: {'uid': uid});
    final Map<String, dynamic> voucherData = {
      'validFor': 'any',
      'amount': amount,
      'validFrom': date
    };
    await firebase
        .collection(users)
        .doc(uid)
        .collection('vouchers')
        .doc(referralUid)
        .set(voucherData);
    await firebase
        .collection(users)
        .doc(referralUid)
        .collection('vouchers')
        .doc(uid)
        .set(voucherData);
    return true;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getBanner() async {
    return firebase.collection('ZymoBannerImages').doc('images').get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCategory(
      String title) async {
    return firebase.collection('CategoriesImages').doc(title).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getBrands() async {
    return firebase.collection('BrandImages').doc('images').get();
  }

  Future<Map<String, dynamic>?> getVoucherAmount() async {
    final data = await firebase.collection('BrandImages').doc('voucher').get();
    return data.data();
  }

  Future<void> setUserDetails(String uid, String name, String email,
      {required String phone}) async {
    await firebase
        .collection(users)
        .doc(uid)
        .set({'name': name, 'email': email, 'phone': phone});
  }

  Future<void> updateUserDetails(Map<String, dynamic> map) async {
    try {
      // Ensure the user.uid is available
      if (user?.uid != null) {
        await firebase.collection('users').doc(user!.uid).update(map);
      } else {
        throw 'User UID is null';
      }
    } catch (e) {
      // Handle any errors that might occur
      print('Error updating user details: $e');
      // Optionally, you can show a snackbar or return an error message
    }
  }

  Future<UserModel?> getUserDetails(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> data =
          await firebase.collection('carsuserData').doc(uid).get();

      if (data.exists && data.data() != null) {
        // Safely cast the data to a Map and pass it to the UserModel fromJson constructor
        final UserModel user = UserModel.fromJson(data.data()!);
        return user;
      } else {
        // Return null if the document doesn't exist or the data is null
        return null;
      }
    } catch (e) {
      // Handle any potential errors
      print('Error fetching user details: $e');
      return null;
    }
  }

  Future addNewVoucher(int amount, BuildContext context,
      {required DateTime validFromDateTime,
      //required bool indicator,
      required DateTime validTillDateTime}) async {
    final String? uid = user?.uid;
    final DateTime time = DateTime.now();
    final String voucherId = uid! + time.toString();
    final String validFrom = dateFormatter.format(validFromDateTime ?? time);
    final String? validTill = validTillDateTime != null
        ? dateFormatter.format(validTillDateTime)
        : null;

    const String validFor = 'any';
    final Map<String, dynamic> data = {
      'validTill': validTill,
      'amount': amount,
      'validFrom': validFrom,
      'id': voucherId,
      'validFor': validFor
    };
    await firebase
        .collection(users)
        .doc(uid)
        .collection('vouchers')
        .doc(voucherId)
        .set(data);
  }

  Future<void> addUserDocument(String documentName, String url) async {
    await firebase.collection(users).doc(user?.uid).update({
      documentName: url,
    });
  }

  Future<void> setUserFCMToken(String fcmToken) async {
    final Map<String, dynamic> data = {
      'token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await firebase
        .collection(users)
        .doc(user?.uid)
        .collection('tokens')
        .doc(user?.uid)
        .set(data);
  }

  Future<bool> cancelOrder(String documentId) async {
    mixpanel.track('Order cancelled by user',
        properties: {'User': user.toString()});
    try {
      await firebase
          .collection(carsPaymentSuccessDetails)
          .doc(documentId)
          .update({'Cancelled': true, 'CancellationDate': DateTime.now()});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> carAddPaymentSuccessData(Map<String, dynamic> data) async {
    await firebase.collection(carsPaymentSuccessDetails).add(data);
  }

  Future<QuerySnapshot> getOffers() async {
    return firebase.collection('Offers').get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserVouchers() async {
    return firebase
        .collection(users)
        .doc(user?.uid)
        .collection('vouchers')
        .get();
  }

  Future<void> addDataToFirestore(Map<String, dynamic> data) async {
    await firebase.collection('carsuserData').doc(user?.uid).set(data);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getDocuments() {
    return firebase.collection(users).doc(user?.uid).snapshots();
  }

  Future<void> updatePromoCode(String promoCode) async {
    if (promoCode.isNotEmpty) {
      await firebase.collection('promocode').doc(promoCode).update({
        '${user?.uid}': 'used',
      });
    }
  }

  Future updateUserVoucher(String voucherId) async {
    if (voucherId.isNotEmpty) {
      await firebase
          .collection(users)
          .doc(user?.uid)
          .collection('vouchers')
          .doc(voucherId)
          .delete();
    }
  }

  Future<UserModel> getUserData() async {
    final data = await firebase.collection(users).doc(user?.uid).get();
    return UserModel.fromJson(data.data()!);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCarCity(String type) async {
    return await firebase.collection('CarCities').doc(type).get();
  }

  Future<DocumentSnapshot> getCarGroupingNames() async {
    return await firebase.collection('CarClubbing').doc('Car Keyword').get();
  }

  Future<void> rateVendor(String vendor, String carname, int rating,
      String comment, String bookingId) async {
    final data = {
      'Vendor': vendor,
      'Car': carname,
      'Rating': rating,
      'Comment': comment,
      'User ID': user?.uid
    };
    await firebase.collection('User Ratings').doc(bookingId).set(data);
  }

  Future<Map> getCancellationData() async {
    final doc =
        await firebase.collection('CarClubbing').doc('cancellationtext').get();
    return doc.data()!;
  }

  Future<bool> submitCancellationRequest(
      String bookingId,
      String screenshotLink,
      String additionalInfo,
      String email,
      String documentId) async {
    try {
      final data = {
        'Booking ID': bookingId,
        'User ID': user?.uid,
        'Screenshot Link': screenshotLink,
        'Additional Information': additionalInfo,
        'Email': email,
        'Timestamp': DateTime.now()
      };
      await firebase.collection('Cancellation Requests').add(data);
      await cancelOrder(documentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitRefundRequest(String bookingId, String screenshotLink,
      String additionalInfo, String email, String documentId) async {
    try {
      final data = {
        'Booking ID': bookingId,
        'User ID': user?.uid,
        'Screenshot Link': screenshotLink,
        'Additional Information': additionalInfo,
        'Email': email,
        'Timestamp': DateTime.now()
      };
      await firebase.collection('Refund Requests').add(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getRentPayData() async {
    const String s = '0';
    return firebase.collection('RentPay').doc(s).get();
  }

  Future<void> setRentPayUserData(Map<String, dynamic> data) async {
    try {
      if (user?.uid != null) {
        await firebase.collection('payrentuserData').doc(user!.uid).set(data);
      } else {
        throw 'User UID is null';
      }
    } catch (e) {
      // Log the error for debugging purposes
      print('Error setting rent pay user data: $e');
      // Optionally, show a snackbar or return an error message to the user
    }
  }

  Future<void> addRentPaySuccessData(Map<String, dynamic> data) async {
    try {
      await firebase.collection('RentPayPaymentSuccessDetails').add(data);
    } catch (e) {
      // Log the error for debugging purposes
      print('Error adding rent pay success data: $e');
      // Optionally, show a snackbar or return an error message to the user
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPromoAmount(
      String promoCode) async {
    final DocumentSnapshot<Map<String, dynamic>> couponData =
        await firebase.collection('promocode').doc(promoCode).get();
    return couponData;
  }

  Future getCities() async {
    return await firebase.collection('CarCities').doc('sd').get();
  }

  static Future<List<CarModel>> getCarOnRent(
      DriveModel model, int tripDurationInHours, Vendor vendor) async {
    final firebaseCars = await FirebaseFirestore.instance
        .collection('testCollection')
        .where('vendor', isEqualTo: 'carOnRent')
        .get();
    return firebaseCars.docs.map((e) {
      final Map data = e.data();
      final unlimitedKms = data['Unlimited KM'];
      final price = unlimitedKms ?? data['price'];
      final CarModel carModel = CarModel(
          apiFlag: true,
          name: data['name'],
          fuel: data['fuel'],
          transmission: data['Transmission'],
          imageUrl: data['imageUrl'],
          finalPrice: (price / 24) *
              tripDurationInHours *
              vendor.currentRate *
              vendor.discountRate,
          finalDiscount:
              (price / 24) * tripDurationInHours * vendor.currentRate)
        ..extraKmCharge = data['extraKmCharge']
        ..extraHrCharge = data['rateperhr']
        ..freeKm = unlimitedKms == null
            ? (250 / 24 * tripDurationInHours).toInt()
            : null
        ..isSoldOut = data['isSoldOut']
        ..fuel = data['fuel']
        ..pickUpAndDrop = data['pickupLocation']
        ..pickups = coR
        ..imageUrl = data['imageUrl']
        ..name = data['name']
        ..transmission = data['Transmission']
        ..seats = data['seats']
        ..vendor = vendor
        ..finalDiscount =
            (price / 24) * tripDurationInHours * vendor.currentRate
        ..finalPrice = (price / 24) *
            tripDurationInHours *
            vendor.currentRate *
            vendor.discountRate;
      return carModel;
    }).toList();
  }

  static Future<List<CarModel>> getKyp(
      DriveModel model, int tripDurationInHours, Vendor vendor) async {
    final firebaseCars = await FirebaseFirestore.instance
        .collection('testKyp')
        // .where('vendor', isEqualTo: kyp)
        .get();
    return firebaseCars.docs.map((e) {
      final Map data = e.data();
      final unlimitedKms = num.parse(data['Unlimited kM ']);
      final price = unlimitedKms ?? data['Price (Package1)'];
      final CarModel carModel = CarModel(
          apiFlag: true,
          name: data['Car Name'],
          fuel: data['Fuel Type'],
          transmission: data['Transmission'],
          imageUrl: data['imageUrl'] ??
              'https://cdn.dribbble.com/users/372814/screenshots/14189965/car-loading-animation.gif',
          finalPrice: (price / 24) *
              tripDurationInHours *
              vendor.currentRate *
              vendor.discountRate,
          finalDiscount:
              (price / 24) * tripDurationInHours * vendor.currentRate)
        ..extraKmCharge = data['Extra Km Rate']
        ..extraHrCharge = data['Extra Hr Rate']
        ..freeKm = unlimitedKms ?? (250 / 24 * tripDurationInHours).toInt()
        ..isSoldOut = data['isSoldOut']
        ..fuel = data['Fuel Type']
        ..pickUpAndDrop = data['Pick-Up location']
        ..pickups = [
          PickupModel(
              pickupAddress: data['Pick-Up location'],
              deliveryCharges: 0,
              locationId: ''),
          PickupModel(
              pickupAddress: homeDelivery,
              deliveryCharges: data['Home Delivery Charges'],
              locationId: ''),
        ]
        ..imageUrl = data['imageUrl'] ??
            'https://cdn.dribbble.com/users/372814/screenshots/14189965/car-loading-animation.gif'
        ..name = data['Car Name']
        ..transmission = data['Transmission']
        ..seats = data['seats']
        ..vendor = vendor
        ..apiFlag = true
        ..selectedPickup
        ..finalDiscount =
            (price / 24) * tripDurationInHours * vendor.currentRate
        ..finalPrice = (price / 24) *
            tripDurationInHours *
            vendor.currentRate *
            vendor.discountRate;
      return carModel;
    }).toList();
  }

  static Future<List<CarModel>> getHrx(
      DriveModel model, int tripDurationInHours, Vendor vendor) async {
    final firebaseCars =
        await FirebaseFirestore.instance.collection('testHrxCars').get();
    return firebaseCars.docs.map((e) {
      final Map data = e.data();
      final unlimitedKms = data['Unlimited KM'];
      final price = unlimitedKms ?? data['price'];
      final CarModel carModel = CarModel(apiFlag: true)
        ..extraKmCharge = data['extraKmCharge']
        ..extraHrCharge = data['rateperhr']
        ..freeKm = (250 / 24 * tripDurationInHours).toInt()
        ..isSoldOut = data['isSoldOut']
        ..fuel = data['fuel']
        ..pickUpAndDrop = data['pickup/ drop location']
        ..imageUrl = data['imageUrl']
        ..name = data['name']
        ..transmission = data['Transmission']
        ..seats = data['seats']
        ..vendor = vendor
        ..finalDiscount =
            (price / 24) * tripDurationInHours * vendor.currentRate
        ..finalPrice = (price / 24) *
            tripDurationInHours *
            vendor.currentRate *
            vendor.discountRate;
      return carModel;
    }).toList();
  }

  static Future<List<CarModel>> getZt(
      DriveModel model, int tripDurationInHours, Vendor vendor) async {
    final firebaseCars = await FirebaseFirestore.instance
        .collection('testZt')
        .doc("Delhi")
        .collection("Cars")
        .get();
    return firebaseCars.docs.map((e) {
      final Map data = e.data();
      final unlimitedKms = data['Unlimited kM'];
      final int price =
          int.parse((data['Price (Package1)']).replaceAll("per day", ""));
      vendor.securityDeposit = (data["Security Deposit"] as int).toDouble();
      final CarModel carModel = CarModel(apiFlag: true)
        ..extraKmCharge = data['Extra Hm Rate']
        ..extraHrCharge = data['Extra Hr Rate']
        ..freeKm = (250 / 24 * tripDurationInHours).toInt()
        ..isSoldOut = data['isSoldOut']
        ..fuel = data['Fuel Type']
        ..pickUpAndDrop = data['Pick-Up location']
        ..imageUrl = data['imageUrl']
        ..name = data['Car Name']
        ..transmission = data['Transmission']
        ..seats = data['seats']
        ..vendor = vendor
        ..finalDiscount =
            (price / 24) * tripDurationInHours * vendor.currentRate
        ..finalPrice = (price / 24) *
            tripDurationInHours *
            vendor.currentRate *
            vendor.discountRate;
      return carModel;
    }).toList();
  }

  static Future<List<CarModel>> getKaryana(
      DriveModel model,
      int tripDurationInHours,
      Vendor vendor,
      String city,
      bool isAbove24Hours) async {
    QuerySnapshot<Map<String, dynamic>> firebaseCars;
    if (isAbove24Hours) {
      firebaseCars = await FirebaseFirestore.instance
          .collection('testKaaryana')
          .doc(city)
          .collection("Cars")
          .get();
    } else {
      firebaseCars = await FirebaseFirestore.instance
          .collection('testKaaryana')
          .doc(city)
          .collection("CarsBelow24")
          .get();
    }
    return firebaseCars.docs.map((e) {
      final Map data = e.data();
      final perHourRate =
          isAbove24Hours ? (data['price'] / 24) : data["below24HourRate"];
      vendor.securityDeposit =
          data["Security Deposit"] ?? vendor.securityDeposit;
      final deliveryCharges = data["Home Delivery Charges"];
      final pickups = [
        PickupModel(pickupAddress: data['pickup/ drop location'] ?? data["Pick-up location"])
          ..pickupAddress =
              data['pickup/ drop location'] ?? data["Pick-up location"]
          ..deliveryCharges = 0,
        PickupModel(pickupAddress: "Delivery & Pickup")
          ..pickupAddress = "Delivery & Pickup"
          ..deliveryCharges = getRate(model),
      ];
      final CarModel carModel = CarModel(apiFlag: true)
        ..extraKmCharge = data['Extra Km Rate']
        ..extraHrCharge = data['Extra Hr rate']
        ..freeKm = isAbove24Hours
            ? (data["freeKms"] / 24 * tripDurationInHours).toInt()
            : 6 * tripDurationInHours
        ..isSoldOut = data['isSoldOut']
        ..fuel = data['Fuel Type']
        ..pickUpAndDrop =
            data['pickup/ drop location'] ?? data["Pick-up location"]
        ..imageUrl = data["imageUrl"] ?? data['ImageUrl']
        ..type = data["Type"]
        ..name = data['Car Name']
        ..transmission = data['Transmission']
        ..deliveryCharges = deliveryCharges
        ..pickups = pickups
        ..seats = data['seats']
        ..vendor = vendor
        ..finalDiscount = perHourRate * tripDurationInHours * vendor.currentRate
        ..finalPrice = perHourRate *
            tripDurationInHours *
            vendor.currentRate *
            vendor.discountRate;
      return carModel;
    }).toList();
  }

  static Future<List<CarModel>> getKaryanaMonthly(
      DriveModel model, Vendor vendor, String city) async {
    QuerySnapshot<Map<String, dynamic>> firebaseCars = await FirebaseFirestore
        .instance
        .collection('testKaaryana')
        .doc(city)
        .collection("Monthly")
        .get();

    return firebaseCars.docs.map((e) {
      final Map data = e.data();
      final monthlyRate = data["Monthly Rates"];
      vendor.securityDeposit =
          data["Security Deposit"] ?? vendor.securityDeposit;
      final deliveryCharges = data["Home Delivery Charges"];
      final pickups = [
        PickupModel(pickupAddress: data['Pick up'])
          ..pickupAddress = data['Pick up']
          ..deliveryCharges = 0,
        PickupModel(pickupAddress: "Delivery & Pickup")
          ..pickupAddress = "Delivery & Pickup"
          ..deliveryCharges = getRate(model),
      ];
      final CarModel carModel = CarModel(apiFlag: true)
        ..extraKmCharge = data['Extra Km Rate']
        ..extraHrCharge = data['Extra Hr rate']
        ..freeKm = data["Monthly KM"]
        ..isSoldOut = data['isSoldOut']
        ..fuel = data['Fuel']
        ..pickUpAndDrop = data['Pick up'] ?? data["Pick-up location"]
        ..imageUrl = data["imageUrl"] ?? data['ImageUrl']
        ..type = data["Type"]
        ..name = data['Car Name']
        ..transmission = data['Transmission']
        ..deliveryCharges = deliveryCharges
        ..pickups = pickups
        ..seats = data['seats']
        ..vendor = vendor
        ..finalDiscount = monthlyRate * vendor.currentRate
        ..finalPrice = monthlyRate * vendor.currentRate * vendor.discountRate;
      return carModel;
    }).toList();
  }

  Future<Map<String, dynamic>?> getUpdateInfo() async {
    final doc =
        await firebase.collection('UpdateInformation').doc('updateInfo').get();
    return doc.data();
  }

  Future<void> addUserData(Map<String, dynamic> json) async {
    await firebase.collection(users).doc(user?.uid).update(json);
  }

  static num getRate(DriveModel model) {
    int rate = 0;
    if (model.endDateTime.hour > 6 && model.endDateTime.hour < 22) {
      rate += 750;
    } else {
      rate += 1000;
    }
    if (model.endDateTime.hour > 6 && model.startDateTime.hour < 22) {
      rate += 750;
    } else {
      rate += 1000;
    }
    return rate;
  }
}
