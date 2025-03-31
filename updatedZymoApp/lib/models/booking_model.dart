import 'package:letzrentnew/models/document_model.dart';

class BookingModel {
  late String promoCodeUsed;
  late String email;
  late String endTime;
  late String transmission;
  late String packageSelected;
  late String pickupLocation;
  late double discountAppliedByUser;
  late String flightNumber;
  late String startDate;
  late String price;
  late String paymentId;
  late String zipcode;
  late String drive;
  late String dateOfBirth;
  late String street2;
  late String street1;
  late String firstName;
  late String startTime;
  late String deliveryType;
  late String mapLocation;
  late String vendor;
  late String city;
  late String carImage;
  late String carName;
  late String endDate;
  late Map refundData;
  late bool isCancelled;
  late String bookingId;
  late String timeStamp;
  late int dateOfBooking;
  late String userId;
  late DocumentModel documents;
  late String phoneNumber;
  late String lastName;
  late var balance;

  BookingModel(
      {required this.promoCodeUsed,
      required this.email,
      required this.endTime,
      required this.transmission,
      required this.packageSelected,
      required this.pickupLocation,
      required this.discountAppliedByUser,
      required this.flightNumber,
      required this.startDate,
      required this.price,
      required this.paymentId,
      required this.zipcode,
      required this.drive,
      required this.dateOfBirth,
      required this.street2,
      this.street1 ='',
      required this.firstName,
      required this.startTime,
      required this.deliveryType,
      required this.mapLocation,
      required this.vendor,
      required this.city,
      required this.carImage,
      required this.carName,
      required this.endDate,
      required this.bookingId,
      required this.timeStamp,
      required this.dateOfBooking,
      required this.userId,
      required this.documents,
      required this.phoneNumber,
      required this.lastName,
      this.balance});

  BookingModel.fromJson(Map<String, dynamic> json) {
    promoCodeUsed = json['Promo Code Used'];
    email = json['Email'];
    endTime = json['EndTime'];
    transmission = json['Transmission'];
    packageSelected = json['Package Selected'];
    pickupLocation = json['Pickup Location'];
    discountAppliedByUser = json['Discount applied by user'];
    flightNumber = json['Flight number'];
    startDate = json['StartDate'];
    price = json['price'];
    paymentId = json['paymentId'];
    zipcode = json['Zipcode'];
    drive = json['Drive'];
    dateOfBirth = json['DateOfBirth'];
    street2 = json['Street2'];
    street1 = json['Street1'];
    firstName = json['FirstName'];
    startTime = json['StartTime'];
    deliveryType = json['deliveryType'];
    mapLocation = json['MapLocation'];
    vendor = json['Vendor'];
    city = json['City'];
    carImage = json['CarImage'];
    carName = json['CarName'];
    endDate = json['EndDate'];
    bookingId = json['bookingId'];
    timeStamp = json['TimeStamp'];
    dateOfBooking = json['DateOfBooking'];
    isCancelled = json['Cancelled'];
    userId = json['UserId'];
    documents = DocumentModel.fromJson(json['Documents']);
    phoneNumber = json['PhoneNumber'];
    lastName = json['LastName'];
    balance = json['Balance'];
    refundData = json['RefundData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Promo Code Used'] = this.promoCodeUsed;
    data['Email'] = this.email;
    data['EndTime'] = this.endTime;
    data['Transmission'] = this.transmission;
    data['Package Selected'] = this.packageSelected;
    data['Pickup Location'] = this.pickupLocation;
    data['Discount applied by user'] = this.discountAppliedByUser;
    data['Flight number'] = this.flightNumber;
    data['StartDate'] = this.startDate;
    data['price'] = this.price;
    data['paymentId'] = this.paymentId;
    data['Zipcode'] = this.zipcode;
    data['Drive'] = this.drive;
    data['DateOfBirth'] = this.dateOfBirth;
    data['Street2'] = this.street2;
    data['Street1'] = this.street1;
    data['FirstName'] = this.firstName;
    data['StartTime'] = this.startTime;
    data['deliveryType'] = this.deliveryType;
    data['MapLocation'] = this.mapLocation;
    data['Vendor'] = this.vendor;
    data['City'] = this.city;
    data['CarImage'] = this.carImage;
    data['CarName'] = this.carName;
    data['EndDate'] = this.endDate;
    data['bookingId'] = this.bookingId;
    data['TimeStamp'] = this.timeStamp;
    data['DateOfBooking'] = this.dateOfBooking;
    data['UserId'] = this.userId;
    data['Documents'] = this.documents;
    data['PhoneNumber'] = this.phoneNumber;
    data['LastName'] = this.lastName;
    data['Balance'] = this.balance;
    return data;
  }
}
