import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vsing/authentication/email_login_screen.dart';
import 'package:vsing/authentication/phone_login_screen.dart';
import 'package:vsing/authentication/sign_up_screen.dart';
import 'package:vsing/services/auth_services.dart';
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/logout_services.dart';
import 'package:vsing/splash_screen.dart';
import 'package:vsing/home_screen.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = 'pk_live_51ObCYGF0sZU2lswwKtgaD9VPJSYrEOYY6lvbtiMavtcbv1v5x2dH3JVSITzo2359TBhfADzCQvx9UB5QhT8Cy9fI00PHUk5uHs'; // Chopie key
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => LandingPage(),
      },
      initialRoute: '/',
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  final LogoutService _logoutService = LogoutService();

  Future<void> signInWithFacebook() async {
    try {
      // Trigger Facebook Login
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ["public_profile", "email"],
      );

      // Check the login result
      if (result.status == LoginStatus.success) {
        // Obtain the access token
        final accessToken = result.accessToken?.token;
        print('Facebook Access Token: $accessToken');
        final userData = await FacebookAuth.instance.getUserData();
        print(userData);

        // Call the function to store details
        await storeFacebookDetails(accessToken!, userData);
      } else {
        print('Facebook login failed: ${result.status}');
        // Handle login failure (optional)
      }
    } catch (e) {
      print('Error signing in with Facebook: $e');
      // Handle other errors (optional)
    }
  }

  Future<void> storeFacebookDetails(String accessToken, Map<String, dynamic> userData) async {

    http.Response response = await AuthServices.facebookLogin(accessToken, userData);
    Map responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', responseMap['token']);
      localStorage.setString('user', json.encode(responseMap['user']));

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen(),
          ));
      Fluttertoast.showToast(msg: 'You are login Successfully.');
      _logoutService.startLogoutTimer(context);
    } else {
      // Handle authentication failure
      print('Authentication failed. Status Code: ${response.statusCode}');
      print('API Response: ${response.body}');
      errorSnackBar(context, responseMap.values.first);
    }
  }

  Future<void> storeAppleDetails(String? userIdentifier, String email, String firstName, String lastName) async {

    http.Response response = await AuthServices.appleSignUp(userIdentifier, email, firstName, lastName);
    Map responseMap = jsonDecode(response.body);

    if (response.statusCode == 200) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', responseMap['token']);
      localStorage.setString('user', json.encode(responseMap['user']));

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen(),
          ));
      Fluttertoast.showToast(msg: 'You are login Successfully.');
      _logoutService.startLogoutTimer(context);
    } else {
      // Handle authentication failure
      print('Authentication failed. Status Code: ${response.statusCode}');
      print('API Response: ${response.body}');
      errorSnackBar(context, responseMap.values.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/new_landingbase.png'), // Replace with your image path
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'A social Concert Places',
              style: TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
                fontFamily: 'FilsonProRegular',
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 80, 255, 246),
                      Color.fromARGB(255, 174, 81, 213)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Handle button tap
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EmailLoginScreen()));
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 80.0,
                      ),
                      child: const Text(
                        'Log in with email',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontFamily: 'FilsonProRegular',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0), // Add spacing between buttons
            Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 5, 135),
                      Color.fromARGB(255, 0, 5, 135),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Handle button tap
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PhoneLoginScreen()));
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 80.0,
                      ),
                      child: const Text(
                        'Log in with phone',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontFamily: 'FilsonProRegular',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0), // Add spacing between button and text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white,
                    thickness: 1.0,
                    indent: 50.0,
                    endIndent: 8.0,
                  ),
                ),
                Text(
                  'Or Sign Up With',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontFamily: 'FilsonProRegular',
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white,
                    thickness: 1.0,
                    indent: 8.0,
                    endIndent: 50.0,
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 16.0), // Add spacing between text and image buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 25.0,
                      backgroundImage: const AssetImage('assets/images/FB.png'),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      child: InkWell(
                        onTap: () async {
                          signInWithFacebook();
                          // Fluttertoast.showToast(
                          //   msg: "Sign up method not supported yet.",
                          //   toastLength: Toast.LENGTH_SHORT,
                          //   gravity: ToastGravity.BOTTOM,
                          //   timeInSecForIosWeb: 1,
                          //   backgroundColor: Colors.red,
                          //   textColor: Colors.white,
                          //   fontSize: 16.0,
                          // );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 25.0,
                      backgroundImage:
                          const AssetImage('assets/images/mac.png'),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      child: InkWell(
                        onTap: () async {
                          try {
                            // final credential = await SignInWithApple.getAppleIDCredential(
                            //   scopes: [
                            //     AppleIDAuthorizationScopes.email,
                            //     AppleIDAuthorizationScopes.fullName,
                            //   ],
                            // );
                            //
                            // print(credential);
                            // // Access user's email, first name, and last name
                            // final String? userIdentifier = credential.userIdentifier;
                            // final String email = credential.email ?? '';
                            // final String firstName = credential.givenName ?? '';
                            // final String lastName = credential.familyName ?? '';
                            //
                            // // Print the user information
                            // print('Email: $email');
                            // print('First Name: $firstName');
                            // print('Last Name: $lastName');
                            //
                            // storeAppleDetails(userIdentifier, email, firstName, lastName);
                            Fluttertoast.showToast(
                              msg: "Signing up with Apple is not supported on Android devices.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          } catch (e) {
                            print('Error signing in with Apple: $e');
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0), // Add spacing between button and text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    text: "Don't have an account yet? ",
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      fontFamily: 'FilsonProRegular',
                    ),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'FilsonProRegular',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 113, 246,
                              237), // Replace with your desired color
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(SignUpScreen());
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text:
                              'By clicking "Sign Up" or "Log In" button, you agree to ',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 31, 227, 241),
                            fontFamily: 'FilsonProRegular',
                          ),
                        ),
                        const TextSpan(text: '\n'),
                        const TextSpan(
                          text: 'our ',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 31, 227, 241),
                            fontFamily: 'FilsonProRegular',
                          ),
                        ),
                        const TextSpan(
                          text: "Privacy Policy, Terms of Use ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontFamily: 'FilsonProRegular',
                          ),
                        ),
                        const TextSpan(
                          text: 'and ',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 31, 227, 241),
                          ),
                        ),
                        const TextSpan(
                          text: "User data",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontFamily: 'FilsonProRegular',
                          ),
                        ),
                        const TextSpan(text: '\n'),
                        TextSpan(
                          text: "deletion policy",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontFamily: 'FilsonProRegular',
                          ),
                          // recognizer: TapGestureRecognizer()
                          //   ..onTap = () {
                          //     // Handle "Sign Up" tap
                          //   },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
