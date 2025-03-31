import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letzrentnew/Screens/submit_fail_screen.dart';
import 'package:letzrentnew/Services/firebase_services.dart';
import 'package:letzrentnew/Utils/constants.dart';

import 'submit_success_screen.dart';

class CancelledByVendorScreen extends StatefulWidget {
  const CancelledByVendorScreen(
      {super.key,
      required this.bookingId,
      required this.vendor,
      required this.email,
      required this.documentId});
  final String bookingId;
  final String email;
  final String vendor;
  final String documentId;
  @override
  State<CancelledByVendorScreen> createState() =>
      _CancelledByVendorScreenState();
}

class _CancelledByVendorScreenState extends State<CancelledByVendorScreen> {
  late File cancellationScreenShot;
  bool isLoading = false;
  final TextEditingController additionalInfoController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cancelled by vendor'),
      ),
      body: SingleChildScrollView(child: uploadPage()),
    );
  }

  Padding uploadPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Please upload a screenshot of cancellation by ${widget.vendor} for the Booking ID ${widget.bookingId}. (Make sure all the relevant details are visible).',
              style: titleStyle,
            ),
          ),
          Text(
            '\nNote: Submitting wrong submission for cancellation by vendor may attract penalty and blocking of the profile.',
            style: titleStyle,
          ),
          SizedBox(
            height: .02.sh,
          ),
          Container(
              color: Colors.black12,
              height: .3.sh,
              width: 1.sw,
              margin: const EdgeInsets.all(4),
              child: cancellationScreenShot != null
                  ? Image.file(
                      cancellationScreenShot,
                    )
                  : IconButton(
                      icon: Icon(Icons.upload),
                      onPressed: () async {
                        print(widget.email);
                        final File? file = await pickImage(ImageSource.gallery);
                        setState(() {
                          cancellationScreenShot = file!;
                        });
                      })),
          ...[
          Row(
            children: <Widget>[
              TextButton(
                  onPressed: () => setState(() {
                        cancellationScreenShot.exists();
                      }),
                  child: const Icon(Icons.refresh)),
            ],
          ),

          // Uploader(
          //     file: cancellationScreenShot,
          //     cat: '${widget.bookingId}CancellationScreenShot'),
        ],
          SizedBox(
            height: .02.sh,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child:
                  Text('Additional information (Optional)', style: titleStyle)),
          SizedBox(
            height: .01.sh,
          ),
          TextField(
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              )),
            ),
            controller: additionalInfoController,
            keyboardType: TextInputType.text,
            maxLines: 4,
          ),
          SizedBox(
            height: .02.sh,
          ),
          isLoading
              ? spinkit
              : AppButton(
                  screenWidth: 1.sw,
                  screenHeight: 1.sh,
                  function: () => submitFunction(),
                  title: 'Submit', textSize: 20, color:Colors.black,)
        ],
      ),
    );
  }

  Future<void> submitFunction() async {
    await submitRequestFunction();
    }

  Future<void> submitRequestFunction() async {
    setState(() {
      isLoading = true;
    });
    String? screenshotLink = 'No screenshot uploaded';
    screenshotLink = await uploadFunction(
        cancellationScreenShot, '${widget.bookingId}Cancellation', context);
      final bool response = await FirebaseServices().submitCancellationRequest(
        widget.bookingId,
        screenshotLink!,
        additionalInfoController.text,
        widget.email,
        widget.documentId);
    setState(() {
      isLoading = false;
    });
    if (response) {
      Navigator.of(context).pushReplacementNamed(SubmitSuccessScreen.routeName);
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SubmitFailScreen()));
    }
  }
}
