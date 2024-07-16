import 'dart:convert';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vsing/authentication/otp_verification_screen.dart';
import 'package:vsing/main.dart';
import 'package:vsing/services/auth_services.dart';
import 'package:vsing/services/globals.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var formKey = GlobalKey<FormState>();
  var isObsecure = true.obs;
  var isObsecureConfirm = true.obs;

  String _name = '';
  String _email = '';
  String _phone_number = '';
  String _password = '';
  String _confirm_password = '';
  PickedFile? _pickedImage;
  late File _imageFile = File('assets/images/avatar-3.png');
  String base64Image = '';
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'MY';
  PhoneNumber number = PhoneNumber(isoCode: 'MY');
  bool isMessageSent = false;

  //Store user data function
  signUpUser() async {
    try {
      // Read the image file and convert it to base64
      if(_imageFile != null && _imageFile.existsSync()) {
        base64Image = base64Encode(_imageFile.readAsBytesSync());
      }

      if (_name.isNotEmpty && _email.isNotEmpty && _phone_number.isNotEmpty && _password.isNotEmpty
          && _confirm_password.isNotEmpty) {

        bool consent = await _askForConsent();

        if(consent) {
          http.Response response = await AuthServices.processSignUp(_name, _email, _phone_number,
              _password, _confirm_password, base64Image);
          Map responseMap = jsonDecode(response.body);
          final data = jsonDecode(response.body);

          if (response.statusCode == 200) {
            print(response.body);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => OtpVerificationScreen(id: data['user']['id']),
                ));
            Fluttertoast.showToast(msg: 'Successfully sign up!');
          } else if (response.statusCode == 400) {
            String errorMessage = '';

            if (data['message'] != null) {
              var messageMap = data['message'] as Map<String, dynamic>;
              List<String> errorMessages = [];

              // Iterate over each field in the message map
              messageMap.forEach((key, value) {
                if (value != null && value is List<dynamic> && value.isNotEmpty) {
                  // If the field has error messages, add them to the errorMessages list
                  errorMessages.addAll(value.map((error) => '$error'));
                }
              });

              errorMessage = errorMessages.join('\n');
            }

            // Display the error message
            errorSnackBar(context, errorMessage.isNotEmpty ? errorMessage : 'Unknown validation error');
          } else {
            print('Error message: ${response.body}');
            errorSnackBar(context, 'An error occurred');
          }
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LandingPage(),
          ));
          errorSnackBar(context, 'Registration requires your consent. We are unable to proceed without it.');
        }
      } else {
        errorSnackBar(context, 'Enter all required fields');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<bool> _askForConsent() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'User Consent',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'FilsonProRegular',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'We need your consent to collect and use your email and password for authentication purposes.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'FilsonProRegular',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // true indicates consent given
              },
              child: const Text('I Consent',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'FilsonProRegular',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LandingPage(),
                    ));
              },
              child: const Text('I Do Not Consent',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'FilsonProRegular',
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false; // If the dialog is dismissed without an action, return false
  }

  Future<void> _selectImage() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);

    if(pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
        _imageFile = File(pickedImage.path);
      });
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mainbase.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to SOS',
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
                          'Register a SOS account with your email address',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xff577DE5),
                            fontFamily: 'FilsonProRegular',
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Form(
                        key: formKey,
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              //Profile Image
                              Container(
                                height: 130,
                                width: 130,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  fit: StackFit.expand,
                                  children: [
                                    if(_pickedImage != null)
                                      CircleAvatar(
                                        child: ClipOval(
                                          child: Image.file(File(_pickedImage!.path),
                                              width: 130,
                                              fit: BoxFit.fill
                                          ),
                                        ),
                                      ),
                                    if(_pickedImage == null)
                                      CircleAvatar(
                                        child: ClipOval(
                                          child: Image.asset(
                                              "assets/images/avatar-3.png",
                                              width: 130,
                                              fit: BoxFit.fill
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 0,
                                      left: 80,
                                      child: RawMaterialButton(
                                        onPressed: () {
                                          _selectImage();
                                        },
                                        elevation: 2.0,
                                        fillColor: Color(0xFF587DE5),
                                        child: Icon(Icons.camera_alt_rounded, color: Colors.white),
                                        padding: EdgeInsets.all(15.0),
                                        shape: CircleBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 30.0),

                              // Name input
                              TextFormField(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'FilsonProRegular',
                                ),
                                onChanged: (value) {
                                  _name = value;
                                },
                                enabled: true,
                                validator: (val) =>
                                val == "" ? "Please enter name" : null,
                                decoration: InputDecoration(
                                  hintText: "Name",
                                  hintStyle: TextStyle(
                                    color: Color(0xff577DE5),
                                    fontFamily: 'FilsonProRegular',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: const Color(0xff577DE5),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
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
                                ),
                              ),

                              SizedBox(height: 15.0),

                              // Email input
                              TextFormField(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'FilsonProRegular',
                                ),
                                onChanged: (value) {
                                  _email = value;
                                },
                                enabled: true,
                                validator: (val) =>
                                val == "" ? "Please enter email" : null,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                    color: Color(0xff577DE5),
                                    fontFamily: 'FilsonProRegular',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: const Color(0xff577DE5),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
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
                                ),
                              ),

                              SizedBox(height: 15.0),

                              // Phone Number input
                              Padding(
                                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: InternationalPhoneNumberInput(
                                  onInputChanged: (PhoneNumber number) {
                                    print(number.phoneNumber);
                                    _phone_number = (number.phoneNumber).toString();
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
                                      fontFamily: 'FilsonProRegular',
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                        color: const Color(0xff577DE5),
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
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
                                  ),
                                ),
                              ),


                              SizedBox(height: 15.0),

                              // Password input
                              Obx(
                                    () => TextFormField(
                                  style: const TextStyle(
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
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                      color: Color(0xff577DE5),
                                      fontFamily: 'FilsonProRegular',
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                        color: const Color(0xff577DE5),
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
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
                                  ),
                                ),
                              ),

                              SizedBox(height: 15.0),

                              // Confirm password input
                              Obx(
                                    () => TextFormField(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'FilsonProRegular',
                                  ),
                                  onChanged: (value) {
                                    _confirm_password = value;
                                  },
                                  enabled: true,
                                  validator: (val) =>
                                  val == "" ? "Please enter confirm password" : null,
                                  obscureText: isObsecureConfirm.value,
                                  decoration: InputDecoration(
                                    suffixIcon: Obx(() => GestureDetector(
                                      onTap: () {
                                        isObsecureConfirm.value = !isObsecureConfirm.value;
                                      },
                                      child: Icon(
                                        isObsecureConfirm.value
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Color(0xff577DE5),
                                      ),
                                    )),
                                    hintText: "Confirm Password",
                                    hintStyle: TextStyle(
                                      color: Color(0xff577DE5),
                                      fontFamily: 'FilsonProRegular',
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                        color: const Color(0xff577DE5),
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
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
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.0),

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


                              SizedBox(height: 25.0),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
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
                                        Get.to(LandingPage());
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 12,
                                        ),
                                        child: Text(
                                          "Back",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'FilsonProRegular',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 10.0),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: isMessageSent
                                          ? const Color(0xff020835)
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xff577DE5),
                                        width: 1,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (isMessageSent) {
                                          signUpUser();
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}
