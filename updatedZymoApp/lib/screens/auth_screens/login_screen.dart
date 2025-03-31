import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:letzrentnew/Services/auth_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/functions.dart';
import 'package:letzrentnew/screens/auth_screens/otp_register.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Visibility(
            visible: isLoading,
            replacement: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(40)),
                  child: Container(
                    width: 1.sw,
                    height: .16.sh,
                    color: appColor,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Image.asset(
                          'dev_assets/new_logo_trans.png',
                          // color: Colors.white,
                          height: .12.sh,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: .02.sh,
                ),
                SizedBox(
                  // width: 1.sw,
                  height: .33.sh,
                  child: Text(
                    "Sign in to continue",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: whiteColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: .02.sh,
                      ),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: SizedBox(
                            width: .9.sw,
                            height: .06.sh,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.google,
                                        color: Colors.black),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Sign in With Phone',
                                      style: largeBlackStyle,
                                    )
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Register()),
                                  );
                                })),
                      ),
                      SizedBox(
                        height: .02.sh,
                      ),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: SizedBox(
                            width: .9.sw,
                            height: .06.sh,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.google,
                                        color: Colors.black),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Sign in with Google',
                                      style: largeBlackStyle,
                                    )
                                  ],
                                ),
                                onPressed: signIn)),
                      ),
                      SizedBox(
                        height: .02.sh,
                      ),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: SizedBox(
                            width: .9.sw,
                            height: .06.sh,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.apple,
                                        color: Colors.black),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Sign in with Apple',
                                      style: largeBlackStyle,
                                    )
                                  ],
                                ),
                                onPressed: () {
                                  signInApple;
                                })),
                      ),
                      SizedBox(
                        height: .02.sh,
                      ),
                      // ClipRRect(
                      //   borderRadius:
                      //       const BorderRadius.all(Radius.circular(10)),
                      //   child: SizedBox(
                      //     width: .9.sw,
                      //     height: .06.sh,
                      //     child: SignInButton(Buttons.Google,
                      //         onPressed: () => performGoogleLogin()),
                      //   ),
                      // ),
                      SizedBox(
                        height: .05.sh,
                      ),
                    ],
                  ),
                )
              ],
            ),
            child: SizedBox(height: 1.sh, child: const Center(child: spinkit)),
          ),
        ),
      ),
    );
  }

  void signIn() async {
    try {
      final GoogleSignIn _google = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
      final GoogleSignInAccount? googleSignInAccount = await _google.signIn();
      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication?.accessToken,
        idToken: googleSignInAuthentication?.idToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;
      await Auth.postCreation(authResult, context);
      assert(!user!.isAnonymous);

      // User currentUser = FirebaseAuth.instance.currentUser;
      Navigator.pop(context, true);
    } catch (error) {
      CommonFunctions.showSnackbar(context, error.toString());
      print(error.toString());
    }

    // Future<void> performGoogleLogin() async {
    //   try {
    //     setState(() {
    //       isLoading = true;
    //     });
    //     await Auth().signInWithGoogle(context);
    //     await navigateToHome(context);
    //   } catch (e) {
    //     warningPopUp(context, oops, 'Sign up failed. $e');
    //   } finally {
    //     setState(() {
    //       isLoading = false;
    //     });
    //   }
    // }
  }

  Future signInApple(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Call signInWithApple from Auth class (ensure it's static)
      await signInWithApple(context);

      Navigator.pop(context, true);
    } catch (e) {
      warningPopUp(context, oops, 'Sign up failed. $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    final appleIdCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );
    final UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = authResult.user;
    await Auth.postCreation(authResult, context);
    assert(user!.isAnonymous);
  }
}
