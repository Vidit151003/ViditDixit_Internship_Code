import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zymo_internship/screens/twilio_otp_screen.dart';

class twiliologinpage extends StatefulWidget {
  const twiliologinpage({super.key});

  @override
  _twiliologinpageState createState() => _twiliologinpageState();
}

class _twiliologinpageState extends State<twiliologinpage> {
  //final String accountSid = 'AC3c6f0bbc7cad7d1991de5dccc290bbcd';
  //final String authToken = 'c8278d56158c34754df675841ecfc743';
  //final String verifyServiceSid = 'VA0c51bc2969189a0bb5ea801a8d799d04';
  final TextEditingController phoneNumberController = TextEditingController();

  /*Future<void> sendOtpWhatsApp(String phoneNumber) async {
    String url =
        'https://verify.twilio.com/v2/Services/$verifyServiceSid/Verifications';

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization':
        'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'To': 'whatsapp:"+91$phoneNumber"', // Specify WhatsApp as the channel
        'Channel': 'whatsapp',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("OTP sent successfully via WhatsApp!");
      Navigator.push(context, MaterialPageRoute(builder:(_)=> TwilioOTPScreen( phoneController: phoneNumberController) ));
    } else {
      print("Failed to send OTP: ${response.body}");
    }
  }*/


  Future<void> sendOTP(String phoneNumber, BuildContext context) async {
    String customerId = 'C-F409401CB0F049B';
    String authToken = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJDLUY0MDk0MDFDQjBGMDQ5QiIsImlhdCI6MTc0MDUzNjA5MiwiZXhwIjoxODk4MjE2MDkyfQ.H2mAn5fFGsekgoN02TCWuOJcphakHgPlgk5FJopTksCoONSuMNzEbAZ9mddjvQJ_jEilRM2Ej7jBzVPP82AXJg';
    String apiUrl =
        "https://cpaas.messagecentral.com/verification/v3/send?countryCode=91&customerId=$customerId&flowType=SMS&mobileNumber=$phoneNumber";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "authToken": authToken,
          "Content-Type": "text/plain",
        },
        body: "",
      );

      // Print the full response for debugging
      print("Full Response: ${response.body}");

      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print("OTP sent successfully: ${responseData['data']}");

        // Extract verificationId safely
        String? verificationId = responseData['data']?['verificationId'];

        if (verificationId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TwilioOTPScreen(
                phoneController: phoneNumberController,
                requestId: verificationId,
              ),
            ),
          );
        } else {
          print("Verification ID is null!");
        }
      } else {
        print("Error sending OTP: ${response.statusCode} - ${response.body}");

        // Extract verificationId safely even on error response
        String? verificationId = responseData['data']?['verificationId'];
        print('Verification ID: $verificationId');
      }
    } catch (e) {
      print("Exception: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/e2/43/40/e2434097-4287-4c51-feb6-bed0f2a9a627/AppIcon-0-0-1x_U007epad-0-85-220.png/246x0w.webphttps://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/e2/43/40/e2434097-4287-4c51-feb6-bed0f2a9a627/AppIcon-0-0-1x_U007epad-0-85-220.png/246x0w.webp',
                height: 80,
              ),
              SizedBox(height: 20),
              Text(
                'Zymo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Let's Sign In",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: 'Enter Phone',
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  sendOTP(phoneNumberController.text, context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 16,color: Colors.black),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: Icon(Icons.message, color: Colors.black,),
                label: Text(
                  'Continue with WhatsApp',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'By signing in, you agree to the Terms and policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
