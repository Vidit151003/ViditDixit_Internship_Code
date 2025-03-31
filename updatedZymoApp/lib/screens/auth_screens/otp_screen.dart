import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letzrentnew/Services/auth_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class Otp extends StatefulWidget {
  const Otp({super.key, required this.verificationId, required this.phoneNumber});
  final String verificationId;
  final String phoneNumber;
  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: appColor,
        body: SafeArea(
          child: Consumer<HomeProvider>(
            builder: (BuildContext context, value, Widget? child) => Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 4),
                    child: Column(
                      children: [
                        SizedBox(
                          height: .01.sh,
                        ),
                        Text(
                          'Verify your number',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please enter the code sent to ${widget.phoneNumber}",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Enter your OTP code number",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 28,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: .08.sh,
                          child: Center(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index) =>
                                  _textFieldOTP(index),
                              itemCount: 6,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Text(
                          "Didn't receive any code?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        value.otpTimeout > 0
                            ? Text(
                                'Code should arrive in ${value.otpTimeout} seconds',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : TapDebouncer(
                                cooldown: sevenSeconds,
                                onTap: () async => (value.otpTimeout == 0)
                                    ? Auth().sendOTP(
                                        widget.phoneNumber, context, true)
                                    : null,
                                waitBuilder: (context, w) => whiteSpinkit,
                                builder: (context, onTap) => InkWell(
                                      onTap: onTap,
                                      child: Text(
                                        "Resend new code",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TapDebouncer(
                              cooldown: sevenSeconds,
                              onTap: () async =>
                                  await otpVerificationFunction(context, value),
                              waitBuilder: (context, w) => whiteSpinkit,
                              builder: (context, onTap) => CupertinoButton(
                                    color: greyColor,
                                    // screenHeight: 1.sh,
                                    // screenWidth: 1.sw,
                                    onPressed: onTap,
                                    child: Text(
                                      'Verify',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )))),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> otpVerificationFunction(
      BuildContext context, HomeProvider value) async {
    FocusScope.of(context).unfocus();
    try {
      if (otp.contains('')) {
        warningPopUp(context, oops, 'Invalid OTP');
      } else {
        final bool res = await Auth()
            .signInWithOTP(widget.verificationId, context, otp.join(''));
        if (res) {
          value.cancelTimer();
          // FlutterBranchSdk.trackContentWithoutBuo(
          //     branchEvent: BranchEvent.standardEvent(
          //         BranchStandardEvent.COMPLETE_REGISTRATION));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      warningPopUp(context, oops, 'Sign up failed. $e');
    }
  }

  final List<String> otp = List.filled(6, '');
  Widget _textFieldOTP(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: .14.sw,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: TextField(
            autofocus: true,
            onChanged: (value) {
              otp[index] = value;
              print(otp);
              if (value.length == 1) {
                FocusScope.of(context).nextFocus();
              }
              if (value.length == 0) {
                FocusScope.of(context).previousFocus();
              }
            },
            showCursor: false,
            readOnly: false,
            textAlign: TextAlign.center,
            style: bigTitleStyle,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              filled: true,
              focusColor: Colors.white,
              hoverColor: Colors.white,
              counter: Offstage(),
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.black12),
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.blue),
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
