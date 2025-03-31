import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart' as slider;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letzrentnew/Services/car_services.dart';
import 'package:letzrentnew/Services/firebase_services.dart';
import 'package:letzrentnew/Services/vendor_services/lowcars_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/Utils/extensions.dart';
import 'package:letzrentnew/Utils/functions.dart';
import 'package:letzrentnew/Utils/widgets.dart';
import 'package:letzrentnew/Widgets/Cars/summary_page.dart';
import 'package:letzrentnew/models/car_model.dart';
import 'package:letzrentnew/models/document_model.dart';
import 'package:letzrentnew/models/user_model.dart';
import 'package:letzrentnew/providers/car_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserBookingScreen extends StatefulWidget {
  static const routeName = '/User-booking';

  @override
  _UserBookingScreenState createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> {
  int pickupIndex = 0;
  final DateTime now = DateTime.now();


  autoFillData(User user) {
    firebaseServices.getUserDetails(user.uid).then((value) {
      street1Controller.text = value!.street1;
      street2Controller.text = value!.street2;
      cityController.text = value.city;
      nameController.text = value.name;
      emailController.text = value.email;
      phoneNumberController.text = value.phoneNumber;
      pinCodeController.text = value.zipcode;
      _dob = DateTime.tryParse(value.dob ?? '') ?? now;
    });
  }

  final TextEditingController street1Controller = TextEditingController();
  final TextEditingController street2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController flightNumberController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final slider.CarouselSliderController _controller = slider.CarouselSliderController();
  late DateTime _dob;
  bool isAdvancePay = true;
  int selected = 0;
  final FirebaseServices firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    final routeArgs =
    ModalRoute
        .of(context)
        ?.settings
        .arguments as Map<dynamic, dynamic>;
    final CarModel carModel = routeArgs['carModel'];
    final DriveModel model = routeArgs['model'];
    final List<String> details = routeArgs['details'];

    if (carModel.vendor.advancePay == 0.0) {
      isAdvancePay = false;
    }
    final bool isChauffeur = model.drive == DriveTypes.WC ||
        model.drive == DriveTypes.RT ||
        model.drive == DriveTypes.OW ||
        model.drive == DriveTypes.AT;
    final PageController _pageController = PageController();
    final String advancePayPrice = CarServices.advancePayFunction(
        ((carModel.finalDiscount) + (carModel.vendor.securityDeposit ?? 0))
            .toStringAsFixed(0),
        carModel.vendor.advancePay);
    final double payableAmount =
        carModel.finalPrice - double.parse(advancePayPrice);

    final bool isZoomCar = carModel.vendor.name == zoomCar;

    mixpanel.track('Car form page', properties: {
      'Duration selected': model.remainingDuration,
      'City': model.city,
      'Car': carModel.name,
      'Vendor': carModel.vendor.name,
      'Payable amount': payableAmount,
      'Security Deposit': carModel.vendor.securityDeposit,
      'Type': model.drive.toString(),
      'Start time': '${model.starttime} ${model.startDate}',
      'End time': '${model.endtime} ${model.endDate}',
    });
    final selectedPickup =
    carModel.pickups != null ? carModel.pickups[selected] : null;

    return SafeArea(
      bottom: false,
      child: Scaffold(
          backgroundColor: greyColor,
          body: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              builder: (ctx, snapshot) {
                final user = snapshot.data;
                autoFillData(user!);
                return ListView(children: <Widget>[
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  if (carModel.multiImages.isEmpty ?? true)
                    carImage(carModel.imageUrl)
                  else
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        CarouselSlider(
                          //carouselController: _pageController,
                          items: carModel.multiImages
                              .map(
                                (e) =>
                                CachedNetworkImage(
                                  imageUrl: e,

                                  fit: BoxFit.fitWidth,
                                  placeholder: (context, ok) =>
                                  const Image(
                                      image: AssetImage(
                                          'assets/images/finallogo.png')),
                                  //      ),
                                ),
                          )
                              .toList(),
                          options: CarouselOptions(
                            viewportFraction: 1,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white54,
                              ),
                              child: IconButton(
                                  onPressed: () =>
                                      _pageController?.previousPage(
                                        duration: Duration(seconds: 300),
                                        curve: Curves.easeInOut,),
                                  icon: Icon(
                                    Icons.chevron_left,
                                  )),
                            ),
                            IconButton(
                                onPressed: () =>
                                    _pageController?.previousPage(
                                      duration: Duration(seconds: 300),
                                      curve: Curves.easeInOut,),
                                icon: Icon(
                                  Icons.chevron_right,
                                ))
                          ],
                        )
                      ],
                    ),
                  carDetails(
                    carModel,
                    model,
                    context,
                    details,
                  ),
                  if (carModel.pickups.isNotEmpty ?? false) ...[
                    SizedBox(height: .01.sh),
                    Container(
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Pickup/Drop Locations (${carModel.pickups
                                          .length})',
                                      style: largeBlackStyle),
                                  ListTile(
                                    onTap: () async {
                                      final lo = await openLocationSelector(
                                          carModel.pickups);
                                      if (lo != null)
                                        setState(() {
                                          carModel.pickUpAndDrop = lo;
                                        });
                                    },
                                    title: Text(
                                        '${selectedPickup?.pickupAddress}',
                                        style: contentStyle),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${selectedPickup
                                                ?.distanceFromUser} KMs away',
                                            style: itleStyle),
                                        Text(
                                            selectedPickup?.deliveryCharges == 0
                                                ? 'Free'
                                                : '$rupeeSign${selectedPickup
                                                ?.deliveryCharges}',
                                            style: titleStyle),
                                      ],
                                    ),
                                    trailing:
                                    Icon(Icons.chevron_right_outlined),
                                  )
                                ]))),
                  ],
                  SizedBox(
                    height: .01.sh,
                  ),
                  if (!isAdvancePay) rentBreakdown(context, carModel),
                  SizedBox(
                    height: .01.sh,
                  ),
                  !snapshot.hasData
                      ? Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: ElevatedButton.icon(
                        label: Text("Proceed"),
                        icon: Icon(Icons.chevron_right),
                        onPressed: () async {
                          await CommonFunctions.navigateToSignIn(context);
                          setState(() {});
                        }),
                  )
                      : form(
                      context,
                      isAdvancePay
                          ? double.parse(advancePayPrice)
                          : payableAmount,
                      carModel,
                      model,
                      isChauffeur,
                      isZoomCar,
                      selectedPickup!,
                      user)
                ]);
              })),
    );
  }

  Future<void> _saveForm(CarModel carModel,
      DriveModel model,
      UserModel userModel,
      double balance,
      String flightNumber,
      DocumentModel documents) async {
    _form.currentState?.save();

    final bool? isValid = _form.currentState?.validate();

    if (!isValid!) {
      buildShowDialog(context, 'Oops!', 'Please fill in all the details');
      return;
    }

    if ((model.drive == DriveTypes.SD || model.drive == DriveTypes.SUB)) {
      final int minAge =
      carModel.vendor.name == wowCarz || carModel.vendor.name == myChoize
          ? 21
          : 18;
      final plusMinAge = DateTime(_dob.year + minAge, _dob.month, _dob.day);
      if (plusMinAge.isAfter(now)) {
        buildShowDialog(context, 'Oops!',
            "Driver's age should be above $minAge years for ${carModel.vendor
                .name} bookings");
        return;
      }
    }
    addUserDataToFirestore(userModel, carModel, model);

    if (carModel.pickups.isNotEmpty ?? false) {
      if (model.drive == DriveTypes.SUB) {
        carModel.pickUpAndDrop = carModel.pickups[selected].pickupAddress;
      } else if (carModel.vendor.name == wowCarz) {
        if (selected != 0) {
          carModel.pickUpAndDrop = carModel.pickups[selected].pickupAddress;
        }
      }
      carModel.deliveryCharges =
          (carModel.pickups[selected].deliveryCharges * 1.28).toInt();
      carModel.selectedPickup = carModel.pickups[selected];
      if (selected != 0) {
        carModel.pickUpAndDrop = carModel.pickups[selected].pickupAddress;
      }
    }
    final bool isZoomLocationsAvailable = carModel.vendor.name == zoomCar &&
        (carModel.pickups.isNotEmpty ?? false);
    if (isZoomLocationsAvailable) {
      carModel.pickUpAndDrop = carModel.pickups[selected].pickupAddress;
      carModel.locationId = carModel.pickups[selected].locationId;
    }
    final double finalPrice = carModel.finalPrice +
        (carModel.vendor.securityDeposit ?? 0) +
        (carModel.deliveryCharges ?? 0);
    final CarProvider promoprovider =
    Provider.of<CarProvider>(context, listen: false);
    promoprovider.setInitialPrice(
        isAdvancePay ? balance : double.parse(finalPrice.toStringAsFixed(2)));
    final double balanceAmount = isAdvancePay
        ? double.parse((finalPrice - balance).toStringAsFixed(0))
        : 0.0;
    final DriveModel tempModel = CarServices.getDriveModel(
        model, flightNumber, balanceAmount, documents, carModel);

    navigateToPromo(
      carModel,
      userModel,
      tempModel,
    );
  }

  void navigateToPromo(CarModel carModel,
      UserModel userModel,
      DriveModel model,) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            SummaryPage(
                carModel: carModel, model: model, userModel: userModel)));
  }

  Future<void> addUserDataToFirestore(UserModel userModel, CarModel carModel,
      DriveModel model) async {
    final Map<String, dynamic> data = {
      'FirstName': userModel.name,
      'Email': userModel.email,
      'PhoneNumber': userModel.phoneNumber.replaceFirst('+91', ''),
      'DateOfBirth': _dob.toString().substring(0, 10),
      'UserId': userModel.uid,
      'Vendor': carModel.vendor.name,
      'StartDate': model.startDate,
      'EndDate': model.endDate,
      'Pickup location': carModel.pickUpAndDrop,
      'MapLocation': model.mapLocation,
      'StartTime': model.starttime,
      'EndTime': model.endtime,
      'Package Selected': carModel.package,
      'DateOfBooking': now.millisecondsSinceEpoch,
      'CarName': carModel.name.toUpperCase(),
      'price': carModel.finalPrice,
      'Street1': userModel.street1,
      'Street2': userModel.street2,
      'City': userModel.city,
      'Zipcode': userModel.zipcode,
    };
    await firebaseServices.addUserData(userModel.toJson());
    await firebaseServices.addDataToFirestore(data);
  }

  Future<void> dateOfBirthPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context), // You can customize the theme here if needed
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dob = picked;
      });
    } else {
      // Optional: Provide feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No date selected')),
      );
    }
  }

  Widget uniformChauffeur() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Spacer(),
          Image.asset(
            'assets/icons/cd.jpeg',
            height: 35,
            width: 35,
          ),
          const Text(
            'Uniformed Chauffeur',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  carImage(String _imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CachedNetworkImage(
        imageUrl: _imageUrl,
        height: .45.sw,
        width: .8.sw,
        fit: BoxFit.fitWidth,
        placeholder: (context, ok) =>
        const Image(image: AssetImage('assets/images/finallogo.png')),
        //      ),
      ),
    );
  }

  rentBreakdown(BuildContext context, CarModel carModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: SizedBox(
            width: 1.sw,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  if (!isAdvancePay) ...[
                    Text('Base Fare', style: titleStyle),
                    if (carModel.finalDiscount > carModel.finalPrice)
                      Text(
                          '$rupeeSign${carModel.finalDiscount.toStringAsFixed(
                              0)}',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.lineThrough)),
                    Text('$rupeeSign${carModel.finalPrice.toStringAsFixed(0)}',
                        style: purpleLargeStyle),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          )),
    );
  }

  Widget advancePayWidget(bool isChauffeur,
      double _advancePayPercentage,
      double _discountprice,
      double _price,
      double payableAmount,
      String advancePayPrice,) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isChauffeur)
              if (_advancePayPercentage != 0.0)
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    CheckboxListTile(
                      activeColor: Colors.black,
                      title: Text(
                          'Pay $rupeeSign$advancePayPrice now and Balance to Driver'),
                      onChanged: (bool? value) {
                        setState(() {
                          isAdvancePay = !isAdvancePay;
                        });
                      },
                      value: isAdvancePay,
                    ),
                    CheckboxListTile(
                      activeColor: Colors.black,
                      title: const Text('Pay total amount now'),
                      onChanged: (bool? value) {
                        setState(() {
                          isAdvancePay = !isAdvancePay;
                        });
                      },
                      value: !isAdvancePay,
                    ),
                  ],
                ),
            if (isAdvancePay) ...[
              Text(
                  'Paying now: $rupeeSign$advancePayPrice Balance: $rupeeSign${payableAmount
                      .toStringAsFixed(0)}',
                  style: contentStyle),
            ]
          ],
        ),
      ),
    );
  }

  Widget form(BuildContext context,
      double payableAmount,
      CarModel carModel,
      DriveModel model,
      bool isChauffeur,
      bool isZoom,
      PickupModel selectedPickup,
      User user) {
    return Form(
        key: _form,
        child: StreamBuilder<DocumentSnapshot>(
            stream: firebaseServices.getDocuments(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return const Center(child: spinkit);
              }

              final DocumentModel documents = DocumentModel.fromJson(
                  snapshot.data!.data() as Map<String, dynamic>);

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if ((selectedPickup.pickupAddress
                        .contains(homeDelivery) ??
                        true) ||
                        carModel.vendor.name == myChoize) ...[
                      const Center(
                          child: Text("Enter Details", style: largeBlackStyle)),
                      const Text(
                        "Address",
                      ),
                      TextFieldBooking(
                        controller: street1Controller,
                        validatorFunction: (value) {
                          if (value.isEmpty) {
                            return 'Enter Street (line 1)';
                          }
                          return '';
                        },
                        title: 'Street (line 1)',
                        keyboardType: TextInputType.text,
                        smallCase: true,
                        function: (newValue) {},
                      ),
                      TextFieldBooking(
                        controller: street2Controller,
                        validatorFunction: (value) {
                          if (value.isEmpty) {
                            return 'Enter Street (line 2)';
                          }
                          return '';
                        },
                        title: 'Street (line 2)',
                        keyboardType: TextInputType.text,
                        smallCase: true,
                        function: (newValue) {
                          null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: .44.sw,
                            height: .1.sh,
                            child: TextFieldBooking(
                              controller: cityController,
                              validatorFunction: (value) {
                                if (value.isEmpty) {
                                  return 'Enter City';
                                }
                                return '';
                              },
                              title: 'City',
                              keyboardType: TextInputType.text,
                              smallCase: true,
                              function: (newValue) {
                                null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: .44.sw,
                            //   height: .1.sh,
                            child: TextFieldBooking(
                              controller: pinCodeController,
                              keyboardType: TextInputType.number,
                              validatorFunction: (value) {
                                if (value.length < 6) {
                                  return 'Pin Code';
                                }
                                return '';
                              },
                              title: 'Pin Code',
                              smallCase: false,
                              function: (newValue) {
                                null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                    const Center(
                        child: Text("Enter Contact Details",
                            style: largeBlackStyle)),
                    TextFieldBooking(
                      keyboardType: TextInputType.name,
                      controller: nameController,
                      validatorFunction: (value) {
                        if (value.isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return '';
                      },
                      title: 'Name',
                      smallCase: true,
                      function: (newValue) {
                        null;
                      },
                    ),
                    TextFieldBooking(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      smallCase: true,
                      validatorFunction: (value) {
                        if (value.isEmpty) {
                          return 'Email cannot be empty';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return '';
                      },
                      title: 'Email',
                      function: (newValue) {
                        null;
                      },
                    ),
                    TextFieldBooking(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.number,
                      validatorFunction: (value) {
                        if (value.length != 10) {
                          return 'Invalid phone number';
                        }
                        return '';
                      },
                      title: 'Phone +91',
                      smallCase: false,
                      function: (newValue) {
                        null;
                      },
                    ),
                    // if (carModel.vendor.name == myChoize)
                    //   TextFieldBooking(
                    //     controller: panNumberController,
                    //     //      keyboardType: TextInputType.number,
                    //     validatorFunction: (value) {
                    //       if (value.length != 10) {
                    //         return 'Invalid pan number';
                    //       }
                    //       return null;
                    //     },
                    //     title: 'Pan Number',
                    //   ),
                    if (model.drive == DriveTypes.AT)
                      if (carModel.vendor.name == myChoize)
                        NoteWidget(
                          text:
                          'Note - \nMyChoize insists on local city documents.',
                        ),
                    const Divider(color: Colors.transparent),
                    if (carModel.vendor.name == wowCarz ||
                        carModel.vendor.name == myChoize ||
                        carModel.vendor.name == lowCars)
                      NoteWidget(
                          text:
                          'Please Note: Driving License Should Be Atleast 1 Year Old.'),
                    if (!isChauffeur && !isZoom)
                      AllDocumentsWidget(documents: documents),
                    const Divider(color: Colors.transparent),
                    Container(
                        child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .secondary),
                                children: [
                                  const TextSpan(
                                    text: 'By clicking on proceed, I agree with ',
                                  ),
                                  TextSpan(
                                      text: '$appName terms and conditions ',
                                      style: const TextStyle(
                                          color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launchUrl(Uri.parse(zymoTerms));
                                        }),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                      text:
                                      '${carModel.vendor.name
                                          .toUpperCase()} terms and conditions. ',
                                      style: const TextStyle(
                                          color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launchUrl(Uri.parse(
                                              CarServices.termsAndConditions(
                                                  carModel.vendor.name)));
                                        }),
                                  const TextSpan(
                                      text: 'Thank you for trusting our service.'),
                                ]))),
                    SizedBox(
                      height: .02.sh,
                    ),
                    Center(
                        child: AppButton(
                          screenHeight: 1.sh,
                          function: () =>
                              proceedToPromoPage(
                                  model,
                                  context,
                                  carModel,
                                  payableAmount,
                                  documents,
                                  !isChauffeur && !isZoom,
                                  user),
                          title: 'Proceed',
                          textSize: 12,
                          color: Colors.black,
                        ))
                  ],
                ),
              );
            }));
  }

  InkWell dateWidget(BuildContext context) {
    return InkWell(
      onTap: () => dateOfBirthPicker(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                )),
            labelText: 'Date Of Birth',
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_dob == null ? 'Select a date' : dateFormatter.format(_dob)),
              Icon(Icons.arrow_drop_down,
                  color: Theme
                      .of(context)
                      .brightness == Brightness.light
                      ? Colors.grey.shade700
                      : Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  void proceedToPromoPage(DriveModel model,
      BuildContext context,
      CarModel carModel,
      double payableAmount,
      DocumentModel documents,
      bool isDocumentsRequired,
      User user) {
    if (_dob == null &&
        (model.drive == DriveTypes.SD || model.drive == DriveTypes.SUB)) {
      buildShowDialog(context, 'No date of birth selected',
          'Please select a date before proceeding');
      return;
    }
    if (isDocumentsRequired) {

    }
    final UserModel submitModel = getUserModel(model, user.uid);
    _saveForm(carModel, model, submitModel, payableAmount,
        flightNumberController.text, documents);
  }

  UserModel getUserModel(DriveModel model, String uid) {
    final String phoneNumber = '+91${phoneNumberController.text}';
    final UserModel submitModel = UserModel(
        aadhaarNumber: '',
        name: nameController.text.trim(),
        phoneNumber:phoneNumber,
        email: emailController.text.trim(),
        prefix: '',
        username: '',
        dob: dateFormatter.format(_dob),
        street1: street1Controller.text.trim(),
        city: model.city ?? cityController.text.trim(),
        zipcode: pinCodeController.text,
        frontLicense: '',
        backLicense: '',
        frontAadhaar: '',
        backAadhaar: '')
      ..street1 = street1Controller.text.trim()
      ..street2 = street2Controller.text.trim()
      ..city = model.city ?? cityController.text.trim()
      ..dob = dateFormatter.format(_dob)
      ..email = emailController.text.trim()
      ..name = nameController.text.trim()
      ..phoneNumber = phoneNumber
      ..uid = uid
    // ..panNumber = panNumberController.text
      ..zipcode = pinCodeController.text;
    if (submitModel.city.isEmpty) {
      submitModel.city = model.city;
    }
    return submitModel;
  }

  Widget carDetails(CarModel carModel,
      DriveModel model,
      BuildContext context,
      List<String> details,) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          carModel.name.toUpperCase(),
                          style: largeBlackStyle,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      if (carModel.vendor.name == zoomCar) ...[
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${carModel.carRatingText ?? ''}',
                                style: contentStyle,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              RatingWidget(totalStars: carModel.carRating),
                            ],
                          ),
                        )
                      ]
                    ],
                  ),
                  SizedBox(height: .01.sh),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.carRear,
                            size: .04.sw,
                            color: Colors.black87,
                          ),
                          SizedBox(
                            width: .02.sw,
                          ),
                          Text(carModel.transmission, style: contentStyle),
                        ],
                      ),
                      Row(children: [
                        Icon(
                          FontAwesomeIcons.gasPump,
                          color: Colors.black87,
                          size: .04.sw,
                        ),
                        SizedBox(
                          width: .02.sw,
                        ),
                        Text(carModel.fuel, style: contentStyle),
                      ]),
                    ],
                  ),
                  SizedBox(height: .01.sh),
                  FulfilledByWidget(
                    vendor: carModel.vendor,
                  ),
                  Divider(),
                  const Text("Start Date", style: largeBlackStyle),
                  Text('${model.startDate} ${model.starttime}',
                      style: contentStyle),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  const Text(
                    "End Date",
                    style: largeBlackStyle,
                  ),
                  Text(
                    '${model.endDate} ${model.endtime}',
                    style: contentStyle,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: distanceWidget(model.distanceOs),
                  ),
                  const Text("Drive Type", style: largeBlackStyle),
                  Text(
                      model.drive == DriveTypes.SD
                          ? "Self Drive"
                          : model.drive == DriveTypes.SUB
                          ? "Monthly Rental"
                          : "Chauffeur",
                      style: contentStyle),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  if (model.drive == DriveTypes.WC ||
                      model.drive == DriveTypes.RT ||
                      model.drive == DriveTypes.OW ||
                      model.drive == DriveTypes.AT) ...[
                    const Text(
                      "Booking Type",
                      style: largeBlackStyle,
                    ),
                    Text(
                        model.drive == DriveTypes.WC
                            ? "Within City"
                            : model.drive == DriveTypes.AT
                            ? 'Airport Transfer'
                            : model.drive == DriveTypes.OW
                            ? 'OutStation (One-way)'
                            : 'OutStation',
                        style: contentStyle),
                  ]
                ],
              )),
        ),
        SizedBox(
          height: .01.sh,
        ),
        extraDetails(context, details),
        if (carModel.vendor.name == lowCars)
          Container(
            // height: .1.sh,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder<List<PickupModel>>(
                      future: LowCarServices.getPickUpLocation(model, carModel),
                      builder: (context, snapshot) {
                        final data = snapshot.data;
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return spinkit;
                        }
                        if (data!.isEmpty) {
                          return Container();
                        }
                        carModel.pickups = data!;
                        return Text(
                            'Pickup location: ${data[selected].pickupAddress}',
                            style: titleStyle);
                      },
                    ),
                  ),
                )),
          ),
        SizedBox(height: .01.sh),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: const Text('Cancellation Policy'),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () async {
                  // Await the future returned by cancellationPolicyWidget
                  dynamic result = await cancellationPolicyWidget(context);
                  // Optionally, handle the result here
                  print('Dialog result: $result');
                },
              ),
            ),
          ),
        )
        //
      ],
    );
  }

  Future<dynamic> cancellationPolicyWidget(BuildContext context) {
    return showDialog(
        context: context,
        builder: (ctx) =>
            Dialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: SizedBox(
                    height: .4.sh,
                    width: 1.sw,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Cancellation Policy',
                            textAlign: TextAlign.center,
                            style: headingStyle,
                          ),
                        ),
                        CancellationRateWidget(),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AppButton(
                            title: 'Okay',
                            function: () => Navigator.of(ctx).pop(),
                            screenHeight: 1.sh,
                            screenWidth: 1.sw,
                            textSize: 12,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ))));
  }

  Widget extraDetails(BuildContext context, List<String> details) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: largeBlackStyle,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('${details[index]}', style: titleStyle),
                      );
                    },
                  ),
                ],
              )),
        ));
  }

  Column distanceWidget(double distance) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              "Distance:",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            Text(
              '$distance Km',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  openLocationSelector(List<PickupModel> pickups) {
    // pickups.sort((a, b) => a.deliveryCharges > b.deliveryCharges
    //     ? a.deliveryCharges
    //     : b.deliveryCharges);
    return showModalBottomSheet<String>(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pickup/Drop Locations', style: bigTitleStyle),
                    Text('Showing ${pickups.showOptionsText()}'),
                    const SizedBox(
                      height: 6,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: .7.sh),
                      child: Scrollbar(
                        interactive: true,
                        child: ListView.builder(
                            itemCount: pickups.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final num deliveryCharge =
                                  pickups[index].deliveryCharges;
                              return Card(
                                child: CheckboxListTile(
                                    title: Text(
                                        '${pickups[index].pickupAddress}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                            '${pickups[index]
                                                .distanceFromUser} KMs away',
                                            style: itleStyle),
                                        Text(deliveryCharge == 0
                                            ? 'Free'
                                            : '$rupeeSign${deliveryCharge}'),
                                      ],
                                    ),
                                    value: selected == index,
                                    onChanged: (val) {
                                      setState(() {
                                        selected = index;
                                      });
                                      Navigator.pop(
                                          context,
                                          pickups[index].pickupAddress);
                                    }),
                              );
                            }),
                      ),
                    ),
                  ],
                )));
  }
}

class TextFieldBooking extends StatelessWidget {
  const TextFieldBooking({
    super.key,
    required this.title,
    required this.validatorFunction,
    required this.controller,
    required this.keyboardType,
    required this.smallCase, required this.function,
  });

  final bool smallCase;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String title;
  final FormFieldValidator validatorFunction;
  final FormFieldSetter function;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
          textCapitalization: smallCase
              ? TextCapitalization.none
              : TextCapitalization.words,
          decoration: InputDecoration(
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  )),
              labelText: title),
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: validatorFunction,
          onSaved: function),
    );
  }
}

