import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:vsing/contents/gems_screen.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/plan_services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class BuyGemsScreen extends StatefulWidget {
  const BuyGemsScreen({Key? key, required this.id, required this.user})
      : super(key: key);

  final int id; // Plan ID
  final int user; // Auth User ID

  @override
  State<BuyGemsScreen> createState() => _BuyGemsScreenState();
}

class _BuyGemsScreenState extends State<BuyGemsScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> form2Key = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isPaymentProcessing = false;
  int planId = 0;
  int userId = 0;
  Map<String, dynamic> planData = {};
  int decimalPlaces = 2;

  FocusNode _focusNode = FocusNode();
  Color _iconColor = Color(0xFF7676FE);
  TextEditingController _referCodeEditingController = TextEditingController();
  String _referralCode = '';
  String _cardNumber = '';
  TextEditingController _expiryController = TextEditingController();
  String _cvvNumber = '';

  void initState() {
    super.initState();
    int planId = widget.id;
    int userId = widget.user;
    getPlanData(planId);

    _focusNode.addListener(() {
      setState(() {
        _iconColor = _focusNode.hasFocus ? Colors.white : Color(0xFF7676FE);
      });
    });
    _expiryController.addListener(_formatExpiryDate);
  }

  @override
  void dispose() {
    _expiryController.dispose();
    super.dispose();
  }

  void getPlanData(planId) async {
    try {
      http.Response response = await PlanServices.getPlanData(planId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          planData = data['plan'];
        });
      } else {
        errorSnackBar(context, data.values.first);
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // Card details input form
  void _formatExpiryDate() {
    final text = _expiryController.text;
    if (text.length == 2 && !_expiryController.text.contains('/')) {
      _expiryController.text = text.substring(0, 2) + '/';
      _expiryController.selection = TextSelection.fromPosition(
        TextPosition(offset: _expiryController.text.length),
      );
    }
  }

  // Credit card payment integration start
  void cardPayment(BuildContext context, int planId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  'Enter Card Details',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF000038),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                color: const Color(0xFF000038),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Form(
                  key: form2Key,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Card Number",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF000038),
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      TextFormField(
                        onChanged: (value) {
                          _cardNumber = value;
                        },
                        validator: (val) =>
                            val == "" ? "Please enter card number" : null,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Enter card number...",
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "Expiry Date",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF000038),
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      TextFormField(
                        controller: _expiryController,
                        validator: (val) =>
                        val == "" ? "Expiration Date (MM/YY)')" : null,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Enter expiration date...",
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "CVV Number",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF000038),
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      TextFormField(
                        onChanged: (value) {
                          _cvvNumber = value;
                        },
                        validator: (val) =>
                        val == "" ? "Please enter cvv number" : null,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: const Color(0xFF000038),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Enter CVV number...",
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: const Color(0xFF000038),
                ),
              ),
              onPressed: () {
                form2Key.currentState!.reset();
                Navigator.of(context).pop();
              },
            ),
            Material(
              color: const Color(0xFF000038),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  if (!isPaymentProcessing && form2Key.currentState!.validate()) {
                    setState(() {
                      isPaymentProcessing = true;
                    });

                    String paymentType = 'card';
                    processPayment(planId, paymentType);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  child: isPaymentProcessing
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text(
                    "Pay",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Define your Stripe API key (publishable key)
  String apiKey = 'pk_live_51ObCYGF0sZU2lswwKtgaD9VPJSYrEOYY6lvbtiMavtcbv1v5x2dH3JVSITzo2359TBhfADzCQvx9UB5QhT8Cy9fI00PHUk5uHs';

  //Function to create a Stripe token
  Future<String> createStripeToken(String cardNumber, String expiryDate, String cvvNumber) async
  {
    final url = 'https://api.stripe.com/v1/tokens';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
      body: {
        'card[number]': cardNumber,
        'card[exp_month]': expiryDate.substring(0, 2), // Extract month
        'card[exp_year]': expiryDate.substring(3),      // Extract year
        'card[cvc]': cvvNumber,
      }
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String tokenId = data['id'];
      return tokenId;
    } else {
      throw Exception('Failed to create Stripe token');
    }
  }

  void processPayment(int planId, String paymentType) async {
    if(!form2Key.currentState!.validate()) {
      return;
    }

    try {
      final userId = widget.user;
      final expiryDate = _expiryController.text;

      if (planId == 0 || paymentType.isEmpty || userId == 0) {
        showError('Error: Invalid purchase details.');
        return;
      }

      // Create a Stripe token
      String tokenId = await createStripeToken(_cardNumber, expiryDate, _cvvNumber);

      http.Response response = await PlanServices.processCardPayment(
          planId, paymentType, userId, _referralCode, tokenId);
      Map responseMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Handle 3D Secure Authentication
        if (responseMap['requires_action'] == true) {
          String clientSecret = responseMap['payment_intent_client_secret'];

          await Stripe.instance.handleNextAction(clientSecret);

          // Check the status of the Payment Intent
          final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);

          print(paymentIntent);

          if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
            print('Payment succeeded');
            String paymentType = 'card';

            http.Response response = await PlanServices.confirmCardPayment(
                planId, paymentType, userId, _cardNumber, paymentIntent);
            Map responseMap = jsonDecode(response.body);

            if (response.statusCode == 200) {
              setState(() {
                isPaymentProcessing = false;
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => GemsScreen(),
                  ));
              Fluttertoast.showToast(msg: 'Successfully purchase gems.');
            } else {
              setState(() {
                isPaymentProcessing = false;
              });
              errorSnackBar(context, responseMap.values.first);
            }
          }  else {
            // Payment failed
            print('Payment not succeeded, status: ${paymentIntent.status}');
            setState(() {
              isPaymentProcessing = false;
            });
            errorSnackBar(context, 'Payment failed. Please try again.');
          }
        } else {
          setState(() {
            isPaymentProcessing = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => GemsScreen(),
              ));
          Fluttertoast.showToast(msg: 'Successfully purchase gems.');
        }
      } else {
        setState(() {
          isPaymentProcessing = false;
        });
        errorSnackBar(context, responseMap.values.first);
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isPaymentProcessing = false;
      });
      Fluttertoast.showToast(msg: 'Payment Failed!');
    }
  }

  void showError(String message) {
    setState(() {
      isPaymentProcessing = false;
    });
    errorSnackBar(context, message);
  }

  // Credit card payment integration end

  void storePayment(int planId, String paymentType) async {
    userId = widget.user; // Get user id

    if (paymentType != 'card') {
      _cardNumber = '';
    }

    try {
      if (planId != 0 && paymentType != '' && userId != 0) {
        bool confirmed = await _showConfirmationDialog();
        if (!confirmed) {
          return;
        }

        http.Response response = await PlanServices.storePayment(
            planId, paymentType, _cardNumber, userId, _referralCode);
        Map responseMap = jsonDecode(response.body);

        if (response.statusCode == 200) {
          print(response.body);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => GemsScreen(),
              ));
          Fluttertoast.showToast(msg: 'Successfully purchase gems.');
        } else {
          errorSnackBar(context, responseMap.values.first);
        }
      } else {
        errorSnackBar(context, 'Error purchase gems!');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  //Confirmation delete in dialog box
  _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase Gems'),
          content: Text('Are you sure you want to purchase gems?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // User cancelled the deletion
              },
            ),
            TextButton(
              child: Text('Purchase'),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed the deletion
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
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
            Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(5.0),
                  child: ListView(
                    children: [
                      if (planData['image'] == null)
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/image_not_available.png',
                              width: 350,
                              height: 150,
                            ),
                          ),
                        ),
                      if (planData['image'] != null)
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              imageGemsURL + planData['image'],
                              width: 350,
                              height: 150,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/image_not_available.png', // Path to your default image asset
                                  width: 350,
                                  height: 150,
                                );
                              },
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16,
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF020835),
                                  borderRadius: BorderRadius .circular(15.0),
                                ),
                                child: Padding(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    vertical: 5.0,
                                    horizontal: 10.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        planData['name'] ?? '',
                                        style:
                                        const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'FilsonProRegular',
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: [
                                          Text(
                                            'RM ' + planData['total_price'].toString(),
                                            style:
                                            const TextStyle(
                                              color: Color(0xFF00C5D4),
                                              fontFamily:
                                              'FilsonProRegular',
                                            ),
                                          ),
                                          SizedBox(width: 30),
                                          Image.asset(
                                            "assets/images/gem.png", // Replace 'path/to/image.png' with the actual image path
                                            width:
                                            18, // Adjust the width of the image
                                            height:
                                            18, // Adjust the height of the image
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            planData['total_gems'].toString(),
                                            style:
                                            const TextStyle(
                                              color: Color(0xFF00C5D4),
                                              fontFamily:
                                              'FilsonProRegular',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Referral Code
                              // const SizedBox(height: 15.0),
                              // const Align(
                              //   alignment: Alignment.centerLeft,
                              //   child: Text(
                              //     'Referral Code',
                              //     style: TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 12.0,
                              //       fontFamily: 'FilsonProRegular',
                              //       fontWeight: FontWeight.w700,
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(height: 8.0),
                              // Container(
                              //   decoration: BoxDecoration(
                              //     color: Color(0xFF000038),
                              //     borderRadius: BorderRadius.circular(15.0),
                              //   ),
                              //   child: Padding(
                              //     padding: EdgeInsets.fromLTRB(15, 5, 15, 15),
                              //     child: TextFormField(
                              //       controller: _referCodeEditingController,
                              //       focusNode: _focusNode,
                              //       decoration: InputDecoration(
                              //         hintText:
                              //             'Key in your referral code (optional)',
                              //         hintStyle: TextStyle(
                              //           color: const Color(0xFF7676FE),
                              //           fontFamily: 'FilsonProRegular',
                              //           fontSize: 13,
                              //         ),
                              //         border: UnderlineInputBorder(
                              //           borderSide: BorderSide(
                              //             color: const Color(0xFF7676FE),
                              //           ),
                              //         ),
                              //         enabledBorder: UnderlineInputBorder(
                              //           borderSide: BorderSide(
                              //             color: const Color(0xFF7676FE),
                              //           ),
                              //         ),
                              //         focusedBorder: UnderlineInputBorder(
                              //           borderSide: BorderSide(
                              //             color: Colors.white,
                              //           ),
                              //         ),
                              //         suffixIcon: IconButton(
                              //           icon: Icon(
                              //             Icons.clear,
                              //             color: _iconColor,
                              //             size: 15,
                              //           ),
                              //           onPressed: () {
                              //             _referCodeEditingController.clear();
                              //             _focusNode.unfocus();
                              //           },
                              //         ),
                              //       ),
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontFamily: 'FilsonProRegular',
                              //         fontSize: 13,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 10.0,
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Image.asset(
                                  'assets/images/select_method.png',
                                  width: 200.0,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5.0,
                                  mainAxisSpacing: 5.0,
                                  children: [
                                    // Card payment
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (_referCodeEditingController
                                              .text.isNotEmpty) {
                                            _referralCode =
                                                _referCodeEditingController
                                                    .text;
                                          }
                                        });

                                        cardPayment(context, planData['id']);
                                      },
                                      child: Image.asset(
                                        'assets/images/add_card_btn.png',
                                        width: 300.0,
                                        height: 100.0,
                                      ),
                                    ),
                                    // E-Wallets payment
                                    GestureDetector(
                                      onTap: () {
                                        // String paymentType = 'ewallet';
                                        // setState(() {
                                        //   if (_referCodeEditingController
                                        //       .text.isNotEmpty) {
                                        //     _referralCode =
                                        //         _referCodeEditingController
                                        //             .text;
                                        //   }
                                        // });
                                        //
                                        // storePayment(
                                        //     planData['id'], paymentType);
                                        Fluttertoast.showToast(
                                          msg: "Payment method not supported yet.",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/images/ewallet_btn.png',
                                        width: 200.0,
                                        height: 80.0,
                                      ),
                                    ),
                                    // Online banking payment
                                    GestureDetector(
                                      onTap: () {
                                        // String paymentType = 'bank';
                                        // setState(() {
                                        //   if (_referCodeEditingController
                                        //       .text.isNotEmpty) {
                                        //     _referralCode =
                                        //         _referCodeEditingController
                                        //             .text;
                                        //   }
                                        // });
                                        //
                                        // storePayment(planData['id'], paymentType);
                                        Fluttertoast.showToast(
                                          msg: "Payment method not supported yet.",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/images/bank_btn.png',
                                        width: 200.0,
                                        height: 80.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Image.asset(
                                  'assets/images/t&c.png',
                                  width: 200.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
    );
  }
}
