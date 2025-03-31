
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';
import 'package:zymo_internship/functions/firebase_fuctions.dart';



class TwilioOTPScreen extends StatefulWidget {
  const TwilioOTPScreen({super.key, required this.phoneController, required this.requestId});
  final TextEditingController phoneController;
  final String? requestId;

  @override
  _TwilioOTPScreenState createState() => _TwilioOTPScreenState();
}

class _TwilioOTPScreenState extends State<TwilioOTPScreen> {
  final TextEditingController otpController = TextEditingController();
  final String accountSid = 'AC3c6f0bbc7cad7d1991de5dccc290bbcd';
  //final String authToken = 'c8278d56158c34754df675841ecfc743';
  final String verifyServiceSid = 'VA0c51bc2969189a0bb5ea801a8d799d04';
  /// ✅ Function to verify OTP
  /*Future<void> verifyOtp(String phoneNumber, String code) async {
    String url =
        'https://verify.twilio.com/v2/Services/$verifyServiceSid/VerificationCheck';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization':
          'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': 'whatsapp:"+91$phoneNumber"',
          'Code': code,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ OTP Verified Successfully!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP Verified Successfully!')),
        );
        signInWithPhoneNumber(phoneNumber);
        // Navigate to Home Screen after successful verification
      } else {
        print("❌ OTP Verification Failed: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP. Please try again.')),
      );
    }
  }*/


  Future<void> verifyOtp(String mobileNumber, String verificationId, String code) async {
    final String customerId = 'C-F409401CB0F049B';
    final String url =
        'https://cpaas.messagecentral.com/verification/v3/validateOtp'
        '?countryCode=91&mobileNumber=$mobileNumber&verificationId=$verificationId&customerId=$customerId&code=$code';

    final Map<String, String> headers = {
      'authToken': 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJDLUY0MDk0MDFDQjBGMDQ5QiIsImlhdCI6MTc0MDUzNjA5MiwiZXhwIjoxODk4MjE2MDkyfQ.H2mAn5fFGsekgoN02TCWuOJcphakHgPlgk5FJopTksCoONSuMNzEbAZ9mddjvQJ_jEilRM2Ej7jBzVPP82AXJg',
    };

    print("Sending request to: $url");
    print("Headers: $headers");

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      // Debugging: Print full response
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("OTP: $code");

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        // Check if response contains expected data
        if (responseData["responseCode"] == 200) {
          print("OTP Verification Successful!");
          return signInWithPhoneNumber(widget.phoneController.text);;
        } else {
          print("Verification Failed: ${responseData['message']}");
        }
      } else {
        print('Failed to verify OTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error verifying OTP: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify OTP"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the OTP sent to your phone',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: 'Enter OTP',
                  prefixIcon: Icon(Icons.lock),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6, // Assuming a 6-digit OTP
              ),
              SizedBox(height: 20),

              /// ✅ Corrected the `onPressed` function
              ElevatedButton(
                onPressed: () {
                  verifyOtp(widget.phoneController.text, widget.requestId.toString(), otpController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Verify OTP',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),

              /// Resend OTP button (Implement resend logic)
              TextButton(
                onPressed: () {
                    SnackBar(content: Text('Resend OTP '),);
                    },
                child: Text(
                  'Resend OTP',
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> handleRetryOtp(String requestId) async {
    final data = {
      'reqId': requestId,  // Request ID
      'retryChannel': 11  // Retry via SMS
    };
    final response = await OTPWidget.retryOTP(data);
    print(response);  // Handle response
  }
}

