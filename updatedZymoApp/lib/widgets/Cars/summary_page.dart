import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letzrentnew/Services/car_services.dart';
import 'package:letzrentnew/Services/firebase_services.dart';
import 'package:letzrentnew/Services/vendor_services/lowcars_services.dart';
import 'package:letzrentnew/Services/vendor_services/zoomCar_v6.dart';


import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/extensions.dart';
import 'package:letzrentnew/models/car_model.dart';
import 'package:letzrentnew/models/user_model.dart';
import 'package:letzrentnew/Utils/widgets.dart';
import 'package:letzrentnew/providers/car_provider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'payment_fail.dart';
import 'payment_success.dart';

class SummaryPage extends StatefulWidget {
  final CarModel carModel;
  final DriveModel model;
  final UserModel userModel;

  const SummaryPage({super.key, required this.carModel, required this.model, required this.userModel});
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final TextEditingController promoCodeController = TextEditingController();
  final _form = GlobalKey<FormState>();
  late Razorpay _razorpay;
  var options;
  final FirebaseServices firebaseServices = FirebaseServices();

  Future payData(String totalAmount) async {
    options = {
      'key': RazorPayKey,
      'amount': double.parse(totalAmount) * 100,
      'name': appName,
      'description': 'Payment',
      'prefill': {
        'contact': widget.userModel.phoneNumber,
        'email': widget.userModel.email
      },
      'external': {
        'wallets': 'paytm',
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
      mixpanel.track('Payment error', properties: {'error': e});
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final DateTime now = DateTime.now();
    final int dateNow = now.millisecondsSinceEpoch;
    final promoprovider = Provider.of<CarProvider>(context, listen: false);
    final String price = promoprovider.initialPrice.toInt().toStringAsFixed(2);

    // final id = '${widget.userModel.name}${now.month}${now.day}${now.hour}';
    // creta121510
    final pickUpAndDrop2 = getLocation();
    final Map<String, dynamic> data = {
      'price': price,
      'actualPrice': widget.carModel.actualPrice,
      'paymentId': response.paymentId,
      'Street1': widget.userModel.street1,
      'Street2': widget.userModel.street2,
      'City': widget.userModel.city,
      'Zipcode': widget.userModel.zipcode,
      'FirstName': widget.userModel.name,
      'Email': widget.userModel.email.trim(),
      'PhoneNumber': widget.userModel.phoneNumber,
      'DateOfBirth': widget.userModel.dob,
      'UserId': widget.userModel.uid,
      'Vendor': widget.carModel.vendor.name,
      'StartDate': widget.model.startDate,
      'EndDate': widget.model.endDate,
      'MapLocation': widget.model.mapLocation,
      'StartTime': widget.model.starttime,
      'EndTime': widget.model.endtime,
      'CarName': widget.carModel.name,
      'Drive': widget.model.driveString,
      'bookingId': bookingId,
      'Balance': widget.model.balance.toStringAsFixed(0),
      'CarImage': widget.carModel.imageUrl,
      'DateOfBooking': dateNow,
      'deliveryType': pickUpAndDrop2,
      'Discount applied by user': promoprovider.discountPrice,
      'Package Selected': widget.carModel.package,
      'Pickup Location': widget.carModel.pickUpAndDrop,
      'Promo Code Used': promoCodeController.text,
      'Transmission': widget.carModel.transmission,
      'TimeStamp': dateFormatter.format(now),
      'SecurityDeposit': securityDeposit,
      'Documents': widget.model.documents.toJson()
    };

    try {
      await uploadBooking(data);
    } catch (error) {
      print(error.toString());
      mixpanel.track('Error on payment page',
          properties: {'data': data, 'error': error.toString()});
    }
    final int rewardAmount = CarServices.getRewardVoucherAmountCars(
        (double.parse(data['price']) - securityDeposit).toInt());
    postPaymentFunction(now, data, promoprovider, rewardAmount);
    Navigator.of(context).pushNamedAndRemoveUntil(
        SuccessPage.routeName, (r) => false,
        arguments: rewardAmount);
    promoprovider.endPayment();
    _razorpay.clear();
    // Do something when payment succeeds
  }

  String getLocation() {
    final lowerCase = widget.carModel.pickUpAndDrop.toLowerCase();
    if (lowerCase.contains('delivery') || lowerCase.contains('airport')) {
      return 'Delivery';
    } else {
      return 'Self-Pickup';
    }
  }

  void postPaymentFunction(DateTime now, Map<String, dynamic> data,
      CarProvider promoprovider, int rewardAmount) {
    try {
      mixpanel.track('${data['Drive']} Payment confirmed', properties: data);
      firebaseServices.updateUserVoucher(promoprovider.voucherId);
      firebaseServices.updatePromoCode(promoCodeController.text);

      promoprovider.resetDiscountApplied();

      if (rewardAmount > 0) {
        firebaseServices.addNewVoucher(rewardAmount, context,
            validFromDateTime: now.add(const Duration(days: 7)),
            validTillDateTime: now.add(const Duration(days: 90)),);
      }
      mixpanel
          .getPeople()
          .trackCharge(double.parse(data['price']), properties: {
        'Voucher Amount Rewarded': rewardAmount,
        'Name': '${widget.userModel.name}',
        'Phone': widget.userModel.phoneNumber
      });
      mixpanel.flush();
    } catch (e) {
      mixpanel.track('Cancelled on payment page',
          properties: {'data': data, 'error': e});
    }
  }

  Future<void> uploadBooking(Map<String, dynamic> data) async {
    await firebaseServices.carAddPaymentSuccessData(data);

    if (widget.carModel.vendor.name == lowCars) {
      await LowCarServices.createBooking(
          widget.carModel, widget.userModel, widget.model);
    } else if (widget.carModel.vendor.name == zoomCar) {
        final bool res = await CarServices.zoomPaymentApiCallsV6(
            bookingId,
            '${widget.userModel.name}',
            '${widget.userModel.phoneNumber}',
            ((widget.carModel.actualPrice) + (deliveryCharges)).toInt());
        if (!res) {
          mixpanel.track('Zoom payment api failed (V6)', properties: {});
        }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("payment has error00000000000000000000000000000000000000");
    // Do something when payment fails
    final CarProvider promoprovider =
        Provider.of<CarProvider>(context, listen: false);
    promoprovider.resetDiscountApplied();
    promoprovider.endPayment();
    Navigator.of(context).pushNamed(FailedPage.routeName, arguments: {
      'response': response,
    });
    _razorpay.clear();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("payment has externalWallet33333333333333333333333333");

  }

  @override
  void initState() {
    super.initState();
    if (widget.carModel.vendor.name != zoomCar) trackEvent();
  }

  late String bookingId;
  late double securityDeposit;
  late int deliveryCharges;
  bool promoLoading = false;

  @override
  Widget build(BuildContext context) {
    final bool isZoomCar = widget.carModel.vendor.name == zoomCar;

    return Consumer<CarProvider>(
      builder: (BuildContext context, value, _) => PopScope(
        onPopInvoked: (bool didPop) async {
          if (!didPop) {
            // Prompt the user with an exit confirmation popup.
            // exitConfirmationPopUp should return a Future<bool>.
            bool? shouldPop = await exitConfirmationPopUp(context, value);
            if (shouldPop?? true) {
              // Allow the pop action to proceed by calling Navigator.pop.
              Navigator.of(context).pop();
            }
            // If shouldPop is false, do nothing (prevent the pop action).
          }
          // If didPop is true, the pop action has already occurred.
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Confirm Booking'),
            flexibleSpace: appBarGradient, // Make sure this is defined somewhere
          ),
          body: value.isPaymentLoading
              ? loadingWidget() // Make sure loadingWidget() is defined
              : summaryWidget(isZoomCar, context, value), // Make sure summaryWidget() is defined
        ),
      ),
    );
  }
    Column loadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        spinkit,
        SizedBox(height: .01.sh),
        Text('Please wait. Do not close this page.', style: largeStyle)
      ],
    );
  }

  Widget summaryWidget(
      bool isZoomCar, BuildContext contex, CarProvider promoprovider) {
    return FutureBuilder<Map<String, dynamic>>(
        future: getZoomCharges(isZoomCar, contex),
        builder: (context, snapshot) {
          if (isZoomCar && !snapshot.hasData) {
            return const Center(
              child: spinkit,
            );
          }
          securityDeposit = widget.carModel.vendor.securityDeposit;
          if (isZoomCar) {
            setZoomCharges(snapshot, promoprovider);
          }
          final rewardVoucherAmountCars =
              CarServices.getRewardVoucherAmountCars(
                  promoprovider.initialPrice.toInt() - securityDeposit.toInt());
          if (!promoprovider.codeApplied) {
            Future.delayed(Duration(milliseconds: 500), () {
              if (widget.carModel.vendor.promoCode.isTrulyNotEmpty())
                promoMain(widget.carModel.vendor.promoCode,
                    dontShowError: true);
            });
          }
          return SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8))),
                  width: 1.sw,
                  height: .15.sh,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12),
                    child: Column(children: <Widget>[
                      CarDetailsWidget(
                        bookingId: bookingId,
                        carModel: widget.carModel,
                      ),
                      SizedBox(height: .01.sh),
                      TripDetailsWidget(
                          model: widget.model, carModel: widget.carModel),
                      SizedBox(height: .01.sh),
                      UserDetailsWidget(
                        showAddress: (widget.model.drive == DriveTypes.SD ||
                                widget.model.drive == DriveTypes.SUB)
                            ? (widget.carModel.pickUpAndDrop
                                    .contains(homeDelivery))
                            : false,
                        userModel: widget.userModel,
                      ),
                      if (isZoomCar)
                        Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                      height: .03.sh,
                                      child: CachedNetworkImage(
                                          imageUrl:
                                              widget.carModel.vendor.imageUrl)),
                                  SizedBox(
                                    height: .02.sh,
                                  ),
                                  Text(
                                      'Sign into ZoomCar using your number ${widget.userModel.phoneNumber} to view your booking.',
                                      textAlign: TextAlign.center,
                                      style: titleStyle),
                                ],
                              ),
                            )),
                      SizedBox(
                        height: .02.sh,
                      ),
                      if (widget.carModel.vendor.name == zoomCar) ...[
                        Card(
                            color: appColor,
                            elevation: 2,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text("Please Note",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                          'As per ZoomCar policy you will have to upload your driving license and Aadhaar card on the ZoomCar app. \n\nIf you already have a ZoomCar profile use the same mobile number registered with Zoomcar. \n(Creation of second profile is not allowed by Zoomcar).',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ))),
                        SizedBox(
                          height: .02.sh,
                        ),
                      ],
                      FareWidget(
                        securityDeposit: securityDeposit,
                        deliveryCharges:
                            deliveryCharges ?? widget.carModel.deliveryCharges,
                        carModel: widget.carModel,
                        promoprovider: promoprovider,
                        advancePayBalance: widget.model.balance,
                      ),
                      RewardVoucherWidget(
                          text: rewardVoucherAmountCars > 0
                              ? 'On completion of this order, you will receive a voucher of $rupeeSign${rewardVoucherAmountCars.toStringAsFixed(0)}'
                              : 'Have an order value of ${rupeeSign}750 and above to get free vouchers!'),
                      const Divider(color: Colors.transparent),
                      if (promoprovider.initialPrice < minTransactionValue)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                              'Promo codes applicable for bookings above ${rupeeSign}$minTransactionValueß'),
                        )
                      else
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: const Text('APPLY PROMO CODE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Form(
                                key: _form,
                                child: TextFormField(
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: InputDecoration(
                                    labelText: 'Enter Promo Code',
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    )),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Enter Promo Code';
                                    }
                                    return null;
                                  },
                                  controller: promoCodeController,
                                ),
                              ),
                            ),
                            if (promoLoading)
                              spinkit
                            else
                              AppButton(
                                screenHeight: .8.sh,
                                screenWidth: .7.sw,
                                function: promoprovider.codeApplied
                                    ? () => buildShowDialog(context, oops,
                                        'Only one promo code or voucher can be applied at a time.')
                                    : () => promoCodeFunction(
                                          promoCodeController.text,
                                        ),
                                textSize: 16,
                                title: 'Apply', color: Colors.black,
                              ),
                            const Divider(
                              color: Colors.transparent,
                            ),
                            VoucherIndicator(
                              function: () =>
                                  showVouchers(context, 'cars').then(
                                (value) => setState(() {}),
                              ),
                              isApplied: promoprovider.codeApplied,
                            )
                          ],
                        ),
                      SizedBox(
                        height: .02.sh,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: AppButton(
                          screenHeight: 1.sh,
                          function: () async =>
                              // MyChoizeServices.createBooking(
                              //     widget.carModel,
                              //     widget.model,
                              //     widget.userModel,
                              //     promoprovider.initialPrice
                              //         .toInt()
                              //         .toStringAsFixed(2))
                              await paymentMethod(promoprovider, context)
                          // await LowCarServices.createBooking(
                          //     widget.carModel, widget.userModel, widget.model)
                          //    kDebugMode?
                          // CarServices.zoomPaymentApiCallsV6(
                          //     bookingId,
                          //     '${widget.userModel.name}',
                          //     '${widget.userModel.phoneNumber}',
                          //     ((widget.carModel.actualPrice) +
                          //             (deliveryCharges ?? 0))
                          //         .toInt())
                          // :
                          // null
                          ,
                          title: 'Book & Pay', textSize: 12, color: Colors.black,
                        ),
                      ),
                    ])),
              ],
            ),
          );
        });
  }

  Future <void> paymentMethod(CarProvider promoprovider, BuildContext context) async {
    promoprovider.startPayment();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    final String price = promoprovider.initialPrice.toInt().toStringAsFixed(2);
    await payData(price);
  }

  void setZoomCharges(
      AsyncSnapshot<Map<String, dynamic>> snapshot, CarProvider promoprovider) {
    securityDeposit = snapshot.data?['securityDeposit'] ??
        widget.carModel.vendor.securityDeposit;
    deliveryCharges = snapshot.data?['hd_fee'] ?? 0;
    bookingId = snapshot.data?['booking_id'];
    widget.carModel.pickUpAndDrop = snapshot.data?['location'];
    widget.carModel.actualPrice = snapshot.data?['actualPrice'];
    promoprovider.setInitialPrice(deliveryCharges +
        securityDeposit +
        widget.carModel.finalPrice -
        (promoprovider.discountPrice ?? 0));
    trackEvent();
  }

  Future<Map<String, dynamic>>? getZoomCharges(
      bool isZoomCar, BuildContext contex) {
    if (isZoomCar && bookingId == null) {
     // return ZoomCarServicesV6.getSecurityDeposit(
         // context,
          widget.model.city;
          widget.carModel.carId;
          widget.carModel.pricingId;
          widget.carModel.locationId;
          widget.carModel.carGroupId;
    //} else {
      return null;
    }
  }

  Future<bool?> exitConfirmationPopUp(
      BuildContext context, CarProvider promoProvider) {
    return showModalBottomSheet<bool>(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) => SizedBox(
              height: .28.sh,
              width: 1.sw,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('Are you sure you want to cancel?',
                        style: headingStyle),
                    //    RichText(
                    // text:    TextSpan(
                    //   children: [
                    //     TextSpan(
                    //       text:
                    //     )
                    //   ]
                    // )
                    //     "\n\n\n\n Contact us if you're facing any issues:",
                    //     style: headingStyle, : null,
                    //   ),
                    // callUsWidget(),
                    Text("We may not be able to hold this booking."),
                    Text("Prices are dynamic and may increase. "),
                    // Text("We may not be able to hold this booking."),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: .25.sw,
                            height: .05.sh,
                            child: FloatingActionButton.extended(
                                backgroundColor: greyColor,
                                label: const Text(
                                  'Go back',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900),
                                ),
                                onPressed: () =>
                                    goBackFunction(context, promoProvider))),
                        // SizedBox(
                        //     width: .25.sw,
                        //     height: .05.sh,
                        //     child: FloatingActionButton.extended(
                        //       backgroundColor: greyColor,
                        //       label: const Text(
                        //         'Continue Booking',
                        //         style: TextStyle(
                        //             color: Colors.black,
                        //             fontWeight: FontWeight.w900),
                        //       ),
                        //       onPressed: () =>
                        //           () => () => Navigator.pop(context, false),
                        //     )),
                        // AppButton(
                        //     screenWidth: 1.12.sw,
                        //     screenHeight: 1.sh,
                        //     textSize: 16,
                        //     color: greyColor,
                        //     title: 'Go back $sadEmoji',
                        //     function: () =>
                        //         goBackFunction(context, promoProvider)),
                        AppButton(
                          screenWidth: 1.48.sw,
                          screenHeight: 1.sh,
                          textSize: 16,
                          // color: Colors.blue,
                          title: 'Continue booking',
                          function: () => Navigator.pop(context, false), color: Colors.black,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  void goBackFunction(BuildContext context, CarProvider promoprovider) {
    promoprovider.resetDiscountApplied();
    Navigator.pop(this.context, true);
    promoprovider.endPayment();
  }

  void trackEvent() async {
    final Map<String, dynamic> data = {
      'Duration selected': widget.model.remainingDuration,
      'City': widget.model.city,
      'Car': widget.carModel.name,
      'Vendor': widget.carModel.vendor.name,
      'Package': widget.carModel.package,
      'Payable amount': widget.carModel.finalPrice,
      'Pickup location': widget.carModel.pickUpAndDrop,
      'Security Deposit': widget.carModel.vendor.securityDeposit,
      'Type': widget.model.drive.toString(),
      'Start time': '${widget.model.starttime} ${widget.model.startDate}',
      'End time': '${widget.model.endtime} ${widget.model.endDate}',
      'BookingId': bookingId
    };
    data.addAll(widget.userModel.toJson());
    mixpanel.track('Car promo page', properties: data);
  }

  Future<void> promoCodeFunction(String promoCode) async {
    final bool? isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }
    setState(() {
      promoLoading = true;
    });
    _form.currentState?.save();
    FocusScope.of(context).unfocus();
    try {
      await promoMain(promoCode, dontShowError: false );
    } catch (error) {
      buildShowDialog(context, 'Error!', error.toString());
    } finally {
      setState(() {
        promoLoading = false;
      });
    }
  }

  Future<void> promoMain(String promoCode, {required bool dontShowError}) async {
    final promoprovider = Provider.of<CarProvider>(context, listen: false);
    if (promoprovider.initialPrice < minTransactionValue) {
      return;
    }
    int? promoAmount = 0;
    final coupon = await firebaseServices.getPromoAmount(promoCode);
    if (coupon.data() == null) {
      promoAmount = -1;
    } else {
      final isUsed = coupon.data()![widget.userModel.uid];
      if (isUsed == null) {
        final int? discount = int.tryParse(coupon.data()!['amount'].toString());
        promoAmount = discount;
      } else {
        promoAmount = 0;
      }
    }
    if (promoAmount! > 0) {
      mixpanel.track('Promo code applied', properties: {'Code': promoCode});
      promoprovider.promoCodeApply(promoAmount.toDouble());
      voucherPopUp(context, 'Promo code applied successfully!',
          'You saved $rupeeSign ${promoprovider.discountPrice}!');
    } else if (dontShowError) {
      return;
    } else if (promoAmount == 0) {
      buildShowDialog(context, 'Already used!',
          'This promo code has already been used by you.');
    } else if (promoAmount == -1) {
      buildShowDialog(
          context, 'Incorrect promo code', 'Please use a valid promo code.');
    }
  }
}

class FareWidget extends StatelessWidget {
  const FareWidget({
    super.key,
    required this.promoprovider,
    required this.carModel,
    required this.securityDeposit,
    required this.deliveryCharges,
    required this.advancePayBalance,
  });

  final CarProvider promoprovider;
  final CarModel carModel;
  final double advancePayBalance;
  final double securityDeposit;
  final int deliveryCharges;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Fare Breakup', style: largeStyle),
          SizedBox(height: .01.sh),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Base Fare", style: titleStyle),
              Text("$rupeeSign${carModel.finalDiscount.toStringAsFixed(0)}",
                  style: titleStyle),
            ],
          ),
          const Divider(color: Colors.transparent),
          if (promoprovider.discountPrice != 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Voucher Applied", style: greentitleStyle),
                Text(
                    "- $rupeeSign${promoprovider.discountPrice.toStringAsFixed(0)}",
                    style: greentitleStyle),
              ],
            ),
            const Divider(color: Colors.transparent),
          ],
          if (advancePayBalance != 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pay Later", style: greentitleStyle),
                Text("- $rupeeSign${advancePayBalance.toStringAsFixed(0)}",
                    style: greentitleStyle),
              ],
            ),
            const Divider(color: Colors.transparent),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Discount", style: itleStyle),
              Text(
                  "- $rupeeSign${(carModel.finalDiscount - carModel.finalPrice).toStringAsFixed(0)}",
                  style: itleStyle),
            ],
          ),
          const Divider(color: Colors.transparent),
          if (deliveryCharges > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Charges', style: titleStyle),
                Text("$rupeeSign${deliveryCharges.toStringAsFixed(0)}",
                    style: titleStyle),
              ],
            ),
            const Divider(color: Colors.transparent),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Refundable Deposit", style: titleStyle),
              Text("$rupeeSign${securityDeposit.toStringAsFixed(0)}",
                  style: titleStyle),
            ],
          ),
          const Divider(color: Colors.black54),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount", style: titleStyle),
              Text("$rupeeSign${promoprovider.initialPrice.toStringAsFixed(0)}",
                  style: titleStyle),
            ],
          ),
          Text("(GST Incl.)", style: smallText),
        ]),
      ),
    );
  }
}
