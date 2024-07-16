import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/contents/profile_screen.dart';
import 'package:vsing/main.dart';
import 'package:vsing/services/auth_services.dart';

import '../services/globals.dart';
import '../services/user_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key, required this.id}) : super(key: key);

  final int id; //User ID

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late SharedPreferences preferences;
  Map<String, dynamic>? userData = {};
  var formKey = GlobalKey<FormState>();
  int _id = 0;
  String _name = '';
  String _email = '';
  String _phone_number = '';

  PickedFile? _pickedImage;
  late File _imageFile = File('assets/images/avatar-3.png');
  String base64Image = '';
  String _isoCode = '';

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'MY';
  PhoneNumber number = PhoneNumber(isoCode: 'MY');

  Map<String, TextEditingController> _textEditingController = {};

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    try {
      preferences = await SharedPreferences.getInstance();
      var user = jsonDecode(preferences.getString('user').toString());
      _id = user['id'];

      if (_id != null && _id != 0) {
        http.Response response = await UserServices.index(_id);
        Map responseMap = jsonDecode(response.body);
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          setState(() {
            userData = data['user'];
            print(userData);

            Map<String, dynamic> phoneNumberData = getPhoneNumberWithIsoCode(userData?['phone_number']);

            _name = userData?['name'] ?? '';
            _email = userData?['email'] ?? '';
            _phone_number = userData?['phone_number'] ?? '';

            _textEditingController['name'] = TextEditingController(text: userData?['name']) ;
            _textEditingController['email'] = TextEditingController(text: userData?['email']) ;
            _textEditingController['phone_number'] = TextEditingController(text: userData?['phone_number']);

            _isoCode = phoneNumberData['isoCode'];

            // Set the initial value for InternationalPhoneNumberInput
            number = PhoneNumber(isoCode: _isoCode, phoneNumber: phoneNumberData['phoneNumber']);
          });
        } else {
          errorSnackBar(context, responseMap.values.first);
        }
      } else {
        errorSnackBar(context, 'Undefined user!');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Map<String, dynamic> getPhoneNumberWithIsoCode(String? fullPhoneNumber) {
    if (fullPhoneNumber == null) {
      return {
        'phoneNumber': '', // or any other default value
        'isoCode': 'MY', // Fallback to a default country code if phone number is null
      };
    }

    List<String> parts = fullPhoneNumber.split("-"); // Assuming phone number and ISO code are separated by a "-"
    if (parts.length == 2) {
      return {
        'phoneNumber': parts[0],
        'isoCode': parts[1],
      };
    }

    return {
      'phoneNumber': fullPhoneNumber, // Fallback to the original number if not separated
      'isoCode': 'MY', // Fallback to a default country code if not separated
    };
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

  editProfileUser() async {
    int userId = widget.id;
    String? updatedPhoneNumber = _textEditingController['phone_number']?.text;

    // Read the image file and convert it to base64
    if(_imageFile != null && _imageFile.existsSync()) {
      base64Image = base64Encode(_imageFile.readAsBytesSync());
    }

    if (userId != 0 && _name.isNotEmpty && _email.isNotEmpty && updatedPhoneNumber!.isNotEmpty) {
      http.Response response = await AuthServices.updateUserProfile(userId, _name, _email, _phone_number, base64Image);
      Map responseMap = jsonDecode(response.body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print(response.body);
        Fluttertoast.showToast(msg: 'Profile updated!');
      } else if (response.statusCode == 400) {
        String errorMessage = '';

        if (data['message'] != null) {
          if (data['message'] is Map) {
            final errors = data['message'] as Map<String, dynamic>;
            if (errors.isNotEmpty) {
              errorMessage = errors.values.first[0];
            }
          }
        }

        errorSnackBar(context, errorMessage.isNotEmpty ? errorMessage : 'Unknown validation error');
      } else {
        print('Error message: ${response.body}');
        errorSnackBar(context, 'An error occurred');
      }
    } else {
      errorSnackBar(context, 'Enter all required fields');
    }
  }

  // Function to show the confirmation dialog
  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: RichText(
            text: TextSpan(
              text: "Are you sure you want to delete your account?\n\n",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: "This action is irreversible, and you cannot recover your account anymore.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            // Confirm button
            TextButton(
              onPressed: () {
                deleteProfileUser();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  deleteProfileUser() async {
    int userId = widget.id;

    if (userId != 0) {
      http.Response response = await AuthServices.deleteUserProfile(userId);
      Map responseMap = jsonDecode(response.body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        preferences.clear();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LandingPage(),
          ),
        );
        Fluttertoast.showToast(msg: 'User account deleted!');
      } else if (response.statusCode == 400) {
        String errorMessage = '';

        if (data['message'] != null) {
          if (data['message'] is Map) {
            final errors = data['message'] as Map<String, dynamic>;
            if (errors.isNotEmpty) {
              errorMessage = errors.values.first[0];
            }
          }
        }

        errorSnackBar(context, errorMessage.isNotEmpty ? errorMessage : 'Unknown validation error');
      } else {
        print('Error message: ${response.body}');
        errorSnackBar(context, 'An error occurred');
      }
    } else {
      errorSnackBar(context, 'Enter all required fields');
    }
  }

  @override
  void dispose() {
    _textEditingController.values.forEach((controller) => controller.dispose());
    super.dispose();
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
          Positioned.fill(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: Color(0xFF020835),
                    title: Text(
                      'Profile',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'FilsonProRegular',
                        fontSize: 16,
                      ),
                    ),
                    pinned: true,
                    centerTitle: true,
                    iconTheme: IconThemeData(
                      color: Colors.white,
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        // Navigate back to the HomeScreen
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => ProfileScreen(currentIndex: 3)),
                        );
                      },
                    ),
                  ),
                  SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontFamily: 'FilsonProRegular',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 20),

                          Padding(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'My photo',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'FilsonProRegular',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),

                          Padding(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Pick some that show the true you',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xff577DE5),
                                  fontFamily: 'FilsonProRegular',
                                ),
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
                                    controller: _textEditingController['name'],
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
                                    controller: _textEditingController['email'],
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
                                      textFieldController: _textEditingController['phone_number'],
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

                                  SizedBox(height: 50.0),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,  // Set the desired red color
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 1,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: ()
                                          {
                                            showDeleteConfirmationDialog(context);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 30,
                                              vertical: 12,
                                            ),
                                            child: Text(
                                              "Delete Account",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: 'FilsonProRegular',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 30.0),

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
                                            editProfileUser();
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 30,
                                              vertical: 12,
                                            ),
                                            child: Text(
                                              "Save",
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
                ],
              )
          ),
        ],
      ),
    );
  }
}
