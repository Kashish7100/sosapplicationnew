import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vsing/authentication/otp_verification_screen.dart';
import 'package:vsing/home_screen.dart';
import 'package:vsing/main.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:vsing/services/auth_services.dart';
import 'package:vsing/services/globals.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/services/logout_services.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final LogoutService _logoutService = LogoutService();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'MY';
  PhoneNumber number = PhoneNumber(isoCode: 'MY');
  String formattedPhoneNumber = '';
  bool isMessageSent = false;

  phoneLoggedIn() async {
    try {
      if (formattedPhoneNumber.isNotEmpty) {
        http.Response response = await AuthServices.mobileLogin(formattedPhoneNumber);
        Map responseMap = jsonDecode(response.body);
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => OtpVerificationScreen(id: data['user']['id']),
              ));
          Fluttertoast.showToast(msg: data['message']);
          _logoutService.startLogoutTimer(context);
        } else {
          errorSnackBar(context, responseMap.values.first);
        }
      } else {
        errorSnackBar(context, 'Enter all required fields');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // Send whatsapp before sing up
  void openWhatsApp() async {
    final url = 'https://wa.me/14155238886?text=join structure-purple';
    if (await canLaunch(url)) {
      await launch(url);
      setState(() {
        isMessageSent = true;
      });
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/mainbase.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_sos.png',
                width: 400,
                height: 200,
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 33.0,
                      color: Colors.white,
                      fontFamily: 'FilsonProRegular',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.0,),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Please verify your phone number to login your SOS account",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontFamily: 'FilsonProRegular',
                  ),
                ),
              ),

              SizedBox(height: 20.0,),

              Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          print(number.phoneNumber);
                          formattedPhoneNumber = (number.phoneNumber).toString();
                        },
                        onInputValidated: (bool value) {
                          print(value);
                        },
                        selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          // backgroundColor: Colors.black,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        initialValue: number,
                        textFieldController: controller,
                        inputBorder: InputBorder.none,
                        formatInput: false,
                        keyboardType: TextInputType.phone,
                        textStyle: TextStyle(
                          color: Colors.white,
                        ),
                        inputDecoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(
                            color: const Color(0xFF3a68e8),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: const Color(0xFF3a68e8),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15.0),

              // WhatsApp message hyperlink
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Send WhatsApp Message',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'FilsonProRegular',
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        content: Text(
                          'Kindly send a WhatsApp message from your registered number to the provided contact to receive your OTP for verification.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontFamily: 'FilsonProRegular',
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'FilsonProRegular',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              openWhatsApp();
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'FilsonProRegular',
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Send Message on WhatsApp",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                    fontFamily: 'FilsonProRegular',
                  ),
                ),
              ),

              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LandingPage(),
                          ),
                        );
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
                          color: Color(0xFF020835),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: Color(0xFF4400ff),
                            width: 2.0,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 20.0,
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 0.0),
                  Expanded(
                    flex: 2, // Set flex value to 3
                    child: Opacity(
                      opacity: isMessageSent ? 1.0 : 0.5,
                      child: ElevatedButton(
                        onPressed: () {
                          formKey.currentState?.validate();

                          if (isMessageSent) {
                            phoneLoggedIn();
                          } else {
                            Fluttertoast.showToast(
                              msg: "Please send the WhatsApp message first to receive the OTP.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
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
                              horizontal:
                              90.0, // Adjust the horizontal padding value to make it wider
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
