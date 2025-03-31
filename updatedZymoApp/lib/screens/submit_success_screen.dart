import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letzrentnew/Utils/constants.dart';

class SubmitSuccessScreen extends StatelessWidget {
  static const routeName = '/successfull-submit';
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
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  child: Icon(
                    Icons.check,
                    size: 40,
                  )),
            ),
            SizedBox(
              height: .02.sh,
            ),
            const Text(
              "Submitted Successfully! $happyEmoji",
              textAlign: TextAlign.center,
              style: largeStyle,
            ),
            SizedBox(
              height: .02.sh,
            ),
            SizedBox(
              width: 1.sw,
              child: Text('Please check your email for the confirmation mail.',
                  textAlign: TextAlign.center, style: contentStyle),
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
              'Thank you for choosing $appName.',
              style: titleStyle,
            )
          ],
        ),
      ),
    );
  }
}
