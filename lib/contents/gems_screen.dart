import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/contents/buy_gems_screen.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/plan_services.dart';
import 'package:vsing/services/user_services.dart';
import 'package:intl/intl.dart';

class GemsScreen extends StatefulWidget {
  const GemsScreen({Key? key}) : super(key: key);

  @override
  State<GemsScreen> createState() => _GemsScreenState();
}

class _GemsScreenState extends State<GemsScreen> {
  late SharedPreferences preferences;
  int _id = 0;
  Map<String, dynamic> userData = {};
  Map<String, dynamic> userEarning = {};
  List<dynamic> planCategories = [];
  int totalGems = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getUserData();
    getPlanData();
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
            userEarning = userData['user_earning'];
            // totalGems = int.parse(userEarning['total_gems']);
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

  void getPlanData() async {
    try {
      http.Response response = await PlanServices.index();
      Map responseMap = jsonDecode(response.body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          planCategories = data['plan_categories'];
        });
      } else {
        errorSnackBar(context, responseMap.values.first);
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
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
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  // My balance container
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF4246FA),
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                        color: Color(0xFF2525F8),
                        width: 2.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Adjust the spacing between number and image
                          Row(
                            children: [
                              // Adjust the spacing between number and image
                              Image.asset(
                                "assets/images/gem.png", // Replace 'path/to/image.png' with the actual image path
                                width: 28, // Adjust the width of the image
                                height: 28, // Adjust the height of the image
                              ),
                              SizedBox(width: 8),
                              Text(
                                'My Balance',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'FilsonProRegular',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                (userEarning['total_gems'] != null)
                                    ? NumberFormat.decimalPattern()
                                        .format(userEarning['total_gems']).toString()
                                    : '0',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'FilsonProRegular',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'S GEM',
                                style: const TextStyle(
                                  color: Color(0xFF032182),
                                  fontFamily: 'FilsonProRegular',
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Image.asset(
                            "assets/images/tf_sgem_btn.png",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      // Expanded(
                      //   child: GestureDetector(
                      //     onTap: () {},
                      //     child: Image.asset(
                      //       "assets/images/topup_cash_btn.png",
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15.0),

                  SingleChildScrollView(
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: planCategories.length,
                      itemBuilder: (context, index) {
                        final planCategory = planCategories[index];

                        return Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                            ),
                            child: Container(
                              width: double
                                  .infinity, // Set the width to match the available space
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Color.fromARGB(255, 84, 70, 202)
                                    .withOpacity(0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 5,
                                    blurRadius: 5,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        planCategory['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          height: 2.0,
                                          fontSize: 16.0,
                                          fontFamily: 'FilsonProRegular',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8.0),

                                    ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                      (planCategory['plans'].length / 2)
                                          .ceil(),
                                      itemBuilder: (context, index) {
                                        final startIndex = index * 2;
                                        final endIndex = startIndex + 2;
                                        final rowPlans = planCategory['plans']
                                            .sublist(
                                            startIndex,
                                            endIndex <
                                                planCategory['plans']
                                                    .length
                                                ? endIndex
                                                : planCategory['plans']
                                                .length);

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 10.0),
                                          child: Row(
                                            children: [
                                              for (final plan in rowPlans) ...[
                                                Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                BuyGemsScreen(
                                                                    id: plan['id'],
                                                                    user: userData[
                                                                    'id']),
                                                          ),
                                                        );
                                                      },
                                                      child: Column(
                                                        children: [
                                                          Image.network(
                                                            imageGemsURL + plan['image'],
                                                            errorBuilder:
                                                                (context, error, stackTrace) {
                                                              return Image.asset(
                                                                'assets/images/image_not_available.png', // Path to your default image asset
                                                              );
                                                            },
                                                          ),
                                                          SizedBox(height: 8),
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color:
                                                              Color(0xFF020835),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                vertical: 5.0,
                                                                horizontal: 10.0,
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  // Adjust the spacing between number and image
                                                                  Image.asset(
                                                                    "assets/images/gem.png", // Replace 'path/to/image.png' with the actual image path
                                                                    width:
                                                                    18, // Adjust the width of the image
                                                                    height:
                                                                    18, // Adjust the height of the image
                                                                  ),
                                                                  SizedBox(width: 5),
                                                                  Text(
                                                                    plan['name'],
                                                                    style:
                                                                    const TextStyle(
                                                                      color: Color(
                                                                          0xFF00C5D4),
                                                                      fontFamily:
                                                                      'FilsonProRegular',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                SizedBox(width: 8),
                                              ],
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}
