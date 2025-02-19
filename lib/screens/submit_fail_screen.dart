import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/widgets.dart';

class SubmitFailScreen extends StatelessWidget {
  const SubmitFailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircleAvatar(
              radius: 50,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: Icon(
                  FontAwesomeIcons.carBurst,
                  size: 40,
                ),
              ),
            ),
            SizedBox(
              height: .02.sh,
            ),
            const Text(
              "Request Failed $sadEmoji",
              textAlign: TextAlign.center,
              style: largeStyle,
            ),
            SizedBox(
              height: .02.sh,
            ),
            SizedBox(
              width: 1.sw,
              child: Text(
                  "Unfortunately, your request couldn't be submitted. Please try again.",
                  textAlign: TextAlign.center,
                  style: contentStyle),
            ),
            SizedBox(
              height: .06.sh,
            ),
            AppButton(
              screenWidth: 2.sw,
              screenHeight: 1.sh,
              title: 'Go back',
              function: () => Navigator.of(context).pop(), textSize: 20, color: Colors.black,
            ),
            SizedBox(
              height: .02.sh,
            ),
            Text(
              'Feel free to reach out to us if you are facing any issues.',
              style: titleStyle,
            ),
            SizedBox(
              height: .01.sh,
            ),
            callUsWidget()
          ],
        ),
      ),
    );
  }
}
