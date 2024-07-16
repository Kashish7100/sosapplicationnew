import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/home_screen.dart';
import 'package:vsing/main.dart';
import 'package:vsing/services/auth_services.dart';
import 'package:vsing/services/globals.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key, required this.id}) : super(key: key);

  final int id; //User ID

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  var formKey = GlobalKey<FormState>();
  int userId = 0;
  Map<String, dynamic> user = {};

  int otpNumberLength = 0;
  final List<TextEditingController> _controllers = List.generate(
    6, (index) => TextEditingController(),
  );
  String otpNumber = '';

  @override
  void initState() {
    super.initState();
    int userId = widget.id;
    getUserData(userId);
  }

  void getUserData(userId) async {
    try {
      http.Response response = await AuthServices.getUserData(userId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          user = data;
          otpNumberLength = data['otp'].length;
        });
      } else {
        errorSnackBar(context, data.values.first);
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  //Verification of otp number send to phone number
  verifyOtpNumber(int id, String otpNumber) async {
    try {
      if (id != 0 && otpNumber.isNotEmpty) {
        http.Response response = await AuthServices.verifyOTP(id, otpNumber);
        Map responseMap = jsonDecode(response.body);
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          print(response.body);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LandingPage(),
              ));
          Fluttertoast.showToast(msg: data['message']);
        } else {
          clearOtpFields();
          errorSnackBar(context, responseMap.values.first);
        }
      } else {
        clearOtpFields();
        errorSnackBar(context, 'Enter all required fields');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  verifyOtpLogin(int id, String otpNumber) async {
    try {
      if (id != 0 && otpNumber.isNotEmpty) {
        http.Response response = await AuthServices.verifyOTPLogin(id, otpNumber);
        Map responseMap = jsonDecode(response.body);
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          SharedPreferences localStorage =
          await SharedPreferences.getInstance();
          localStorage.setString('token', responseMap['token']);
          localStorage.setString('user', json.encode(responseMap['user']));

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen(),
              ));
          Fluttertoast.showToast(msg: data['message']);
        } else {
          clearOtpFields();
          errorSnackBar(context, responseMap.values.first);
        }
      } else {
        clearOtpFields();
        errorSnackBar(context, 'Enter all required fields');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void clearOtpFields() {
    for (TextEditingController controller in _controllers) {
      controller.clear();
    }
    otpNumber = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/mainbase.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'OTP Verification',
                        style: TextStyle(
                          fontSize: 38,
                          color: Colors.white,
                          fontFamily: 'FilsonProRegular',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5),

                      Padding(
                        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: Text(
                          'The verification code has been sent via SMS to :',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xff577DE5),
                            fontFamily: 'FilsonProRegular',
                          ),
                        ),
                      ),

                      SizedBox(height: 30.0),

                      Form(
                        key: formKey,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 30.0,
                          ),
                          child: Column(
                            children: [
                              //Phone number
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  user['phone_number'] ?? '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'FilsonProRegular',
                                  ),
                                ),
                              ),

                              SizedBox(height: 30.0),

                              //Enter code
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Enter code:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'FilsonProRegular',
                                  ),
                                ),
                              ),

                              SizedBox(height: 10.0),

                              // OTP input
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                    otpNumberLength,
                                    (index) => Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 3.0),
                                        child: TextFormField(
                                          controller: _controllers[index],
                                          maxLength: 1,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xff577DE5),
                                            fontFamily: 'FilsonProRegular',
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty && index < (otpNumberLength - 1)) {
                                              FocusScope.of(context).nextFocus();
                                            }
                                          },
                                          enabled: true,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: const Color(0xff577DE5),
                                                width: 2,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: const Color(0xff577DE5),
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6,
                                            ),
                                            fillColor: Color(0xff020835),
                                            filled: true,
                                            counterText: '',
                                          ),
                                        ),
                                      )
                                    )
                                ),
                              ),


                              SizedBox(height: 25.0),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xff020835),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xff577DE5),
                                      width: 1,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: ()
                                    {
                                      for (TextEditingController controller in _controllers) {
                                        otpNumber += controller.text;
                                      }
                                      print('OTP: $otpNumber');
                                      if(user['is_phone_verified'] == 0 ) {
                                        verifyOtpNumber(widget.id, otpNumber); // Verify otp number for sign up
                                      } else {
                                        verifyOtpLogin(widget.id, otpNumber); // Verify otp number for mobile login
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        "Next",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'FilsonProRegular',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }
}
