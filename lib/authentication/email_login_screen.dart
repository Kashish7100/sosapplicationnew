import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:vsing/home_screen.dart';
import 'package:vsing/main.dart';
import 'package:vsing/services/auth_services.dart';
import 'package:vsing/services/globals.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/services/logout_services.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({Key? key}) : super(key: key);

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  var formKey = GlobalKey<FormState>();
  var isObsecure = true.obs;

  String _email = '';
  String _password = '';

  final LogoutService _logoutService = LogoutService();
  Timer? _debounce;
  DateTime? _lastLoginAttemptTime;

  void debounce(Function() action, {int milliseconds = 1000}) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: milliseconds), action);
  }

  loggedInUser() async {
    final now = DateTime.now();
    if (_lastLoginAttemptTime != null && now.difference(_lastLoginAttemptTime!).inSeconds < 5) {
      Fluttertoast.showToast(msg: 'Please wait before trying again.');
      return;
    }
    _lastLoginAttemptTime = now;

    try {
      if (_email.isNotEmpty && _password.isNotEmpty) {
        http.Response response = await AuthServices.login(_email, _password);
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
          errorSnackBar(context, responseMap['message']);
        }
      } else {
        errorSnackBar(context, 'Enter all required fields');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "Failed to reload.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/mainbase.png',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo_sos.png',
                        width: 400,
                        height: 200,
                      ),

                      SizedBox(height: 10.0,),

                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 33.0,
                          color: Colors.white,
                          fontFamily: 'FilsonProRegular',
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 10.0,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "It's nice to see you again! Please enter your email address to log in.",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontFamily: 'FilsonProRegular',
                          ),
                        ),
                      ),

                      SizedBox(height: 20.0,),

                      // Email input
                      Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020835),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: const Color(0xFF4400ff),
                            width: 2.0,
                          ),
                        ),
                        child: TextFormField(
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'FilsonProRegular',
                          ),
                          onChanged: (value) {
                            _email = value;
                          },
                          enabled: true,
                          validator: (val) =>
                          val == "" ? "Please enter email" : null,// Set input value text color
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: const Color(0xFF3a68e8),
                                fontFamily: 'FilsonProRegular'),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      // Password input
                      Obx(
                            () => Container(
                          margin: const EdgeInsets.all(15.0),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF020835),
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(
                              color: const Color(0xFF4400ff),
                              width: 2.0,
                            ),
                          ),
                          child: TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'FilsonProRegular',
                            ),
                            onChanged: (value) {
                              _password = value;
                            },
                            enabled: true,
                            validator: (val) =>
                            val == "" ? "Please enter password" : null,
                            obscureText: isObsecure.value,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: const Color(0xFF3a68e8)),
                              border: InputBorder.none,
                              suffixIcon: Obx(() => GestureDetector(
                                onTap: () {
                                  isObsecure.value = !isObsecure.value;
                                },
                                child: Icon(
                                  isObsecure.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Color(0xff577DE5),
                                ),
                              )),
                            ),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Handle forgot password action
                              // Implement the logic for resetting the password
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 5.0, right: 30.0),
                              child: const Text(
                                'Forgot Password',
                                style: TextStyle(
                                  color: Color(0xFF3a68e8),
                                  // decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const LandingPage()));
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent), // Set button background color
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30), // Set the desired border radius here
                                  ),
                                ),
                                elevation: MaterialStateProperty.all<double>(0.0),
                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF020835),
                                  borderRadius: BorderRadius.circular(30.0),
                                  border: Border.all(
                                    color: const Color(0xFF4400ff),
                                    width: 2.0,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 30.0, // Adjust the padding here
                                  ),
                                  child: const Text(
                                    'Back',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                debounce(() => loggedInUser());
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent), // Set button background color
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30), // Set the desired border radius here
                                  ),
                                ),
                                elevation: MaterialStateProperty.all<double>(0.0),
                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 80, 255, 246),
                                      Color.fromARGB(255, 174, 81, 213)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 30.0, // Adjust the padding here
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
