import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letzrentnew/Screens/offers.dart';
import 'package:letzrentnew/Screens/referral_screen.dart';
import 'package:letzrentnew/Utils/constants.dart';

import 'vouchers_screen.dart';

class MyRewards extends StatelessWidget {
  const MyRewards({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: gradientColors)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              height: .01.sh,
            ),
            Container(
                height: .4.sh,
                width: 1.sw,
                child: Card(
                    color: appColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$appName Rewards',
                          style: biWhiteTitleStyle,
                        ),
                        // Image.asset(
                        //   'assets/images/onboarding_images/earn.jpeg',
                        //   // width: double.infinity,
                        // ),
                      ],
                    ))),
            SizedBox(
              height: .01.sh,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RewardButton(
                  child: Icon(
                    FontAwesomeIcons.peopleCarryBox,
                    color: appColor,
                  ),
                  title: 'Refer And Earn',
                  color: Colors.red,
                  function: () =>
                      Navigator.pushNamed(context, ReferralScreen.routeName),
                ),
                RewardButton(
                  child: Icon(
                    FontAwesomeIcons.gift,
                    color: appColor,
                  ),
                  title: 'Offers',
                  color: Colors.green,
                  function: () =>
                      Navigator.pushNamed(context, OfferPage.routeName),
                ),
                RewardButton(
                  child: Icon(
                    FontAwesomeIcons.question,
                    color: appColor,
                  ),
                  title: 'How does this work?',
                  color: Colors.blue,
                  function: () =>
                      //  Navigator.pushNamed(
                      //     context, SuccessPage.routeName,
                      //     arguments: 500)
                      voucherPopUp(context, 'Hey there!',
                          "$appName rewards its users, for every transaction.\n\nRefer us to your friends and earn discount vouchers."),
                ),
              ],
            ),
            SizedBox(
              height: .01.sh,
            ),
            Container(
              height: .16.sh,
              width: 1.sw,
              child: Card(
                  color: appColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () => Navigator.of(context).pushNamed(
                      RewardsScreen.routeName,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: .6.sw,
                            child: Text(
                              'Your Vouchers',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Image.asset(
                            'dev_assets/new_logo.jpeg',
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}

class RewardButton extends StatelessWidget {
  const RewardButton({
    super.key,
    required this.child,
    this.title='',
    required this.function,
    this.color=Colors.black,
  });

  final Widget child;
  final String title;
  final Function function;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: .2.sh,
      width: .3.sw,
      child: Card(
          color: appColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: (){function;},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: .11.sw,
                  backgroundColor: gradientColors[1],
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    radius: .1.sw,
                    child: child,
                  ),
                ),
                SizedBox(
                  height: .04.sh,
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: whiteTitleStyle,
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
