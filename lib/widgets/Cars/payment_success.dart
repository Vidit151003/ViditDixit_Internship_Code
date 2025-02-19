import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:letzrentnew/Screens/tabs_screen.dart';
import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/Utils/constants.dart';

class SuccessPage extends StatelessWidget {
  static const routeName = '/payment-sucess';
  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as int;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(twoSeconds);
      await voucherPopUp(context, '$rupeeSign$routeArgs',
          'You won a voucher of $routeArgs for this transaction!$happyEmoji$happyEmoji$happyEmoji Visit Rewards section to find details.');
      await _requestReview();
    });

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
              "Payment Success!",
              textAlign: TextAlign.center,
              style: largeStyle,
            ),
            SizedBox(
              height: .02.sh,
            ),
            SizedBox(
              width: 1.sh,
              child: Text('Your booking has been received successfully.',
                  textAlign: TextAlign.center, style: contentStyle),
            ),
            SizedBox(
              height: .06.sh,
            ),
            AppButton(
              screenWidth: 2.sw,
              screenHeight: 1.sh,
              title: 'Back to Home',
              function: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(TabScreen.routeName, (r) => false), textSize: 15, color: Colors.black,
            ),
            SizedBox(
              height: .02.sh,
            ),
            Text(
              'Thank you for booking on $appName.',
              style: titleStyle,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _requestReview() async {
    final InAppReview _inAppReview = InAppReview.instance;
    if (await _inAppReview.isAvailable()) _inAppReview.requestReview();
    // else
    //   _inAppReview.openStoreListing(
    //     appStoreId: '1547829759',
    //   );
  }
}
