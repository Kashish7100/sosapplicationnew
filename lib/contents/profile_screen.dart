import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vsing/contents/edit_profile_screen.dart';
import 'package:vsing/contents/gems_screen.dart';
import 'package:vsing/contents/song/home_screen.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/user_services.dart';
import 'package:vsing/contents/qrcode_screen.dart';

import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.currentIndex}) : super(key: key);

  final int currentIndex;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SharedPreferences preferences;
  Map<String, dynamic> userData = {};
  Map<String, dynamic> userEarning = {};
  List<dynamic> rankings = [];
  bool isLoading = false;
  int _id = 0;
  int totalGems = 0;
  String shieldImageUrl = '';
  int totalContribution = 0;
  int totalGemsEarned = 0;
  int userFans = 0;
  int userFollowing = 0;

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
            rankings = data['rankings'];

            rankings.sort((a, b) => a['total_gems'].compareTo(b['total_gems']));

            if(userData['user_earning'] == null || userData['user_earning'].isEmpty) {
              userFans = 0;
              userFollowing = 0;
              totalContribution = 0;
              totalGemsEarned = 0;

              totalGems = 0;
              shieldImageUrl = 'assets/images/shield/shield_1.png';
            } else {
              userEarning = userData['user_earning'];

              userFans = userEarning['user_fans'] ?? 0;
              userFollowing = userEarning['user_following'] ?? 0;
              totalContribution = userEarning?['total_contribution'] ?? 0;
              totalGemsEarned = userEarning?['gems_earned'] ?? 0;

              totalGems = userEarning?['total_gems'] ?? 0;

              rankings.sort((a, b) => a['total_gems'].compareTo(b['total_gems']));

              shieldImageUrl = getShieldImageUrl(totalGems, rankings);
            }

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

  String getShieldImageUrl(int totalGems, List rankings) {
    String imageUrl = '';
    if(totalGems <= rankings.first['total_gems']) {
      imageUrl = imageRankingURL + rankings.first['logo_image'];
    } else {
      for (int i = 0; i < rankings.length - 1; i++) {
        // Check if totalGems is more than or equal to current ranking's total_gems and less than next ranking's total_gems
        if (totalGems >= rankings[i]['total_gems'] && totalGems < rankings[i + 1]['total_gems']) {
          imageUrl = imageRankingURL + rankings[i]['logo_image'];
          break;
        }
      }
    }

    if(imageUrl.isEmpty) {
      imageUrl = imageRankingURL + rankings.last['logo_image'];
    }

    return imageUrl;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/mainbase.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(5.0),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 0.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF030936),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Padding(
                              padding:
                              EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            // Existing code for profile image
                                            // ...

                                            Expanded(
                                              child: Container(
                                                height: 200,
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      children: [
                                                        Container(
                                                          height: 130,
                                                          width: 130,
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(
                                                                20.0),
                                                            child:
                                                            CircleAvatar(
                                                              child: ClipOval(
                                                                child: userData['image'] == null
                                                                    ? Image.asset(
                                                                  "assets/images/avatar-3.png",
                                                                  width: 115,
                                                                  fit: BoxFit.fill,
                                                                )
                                                                    : Image.network(
                                                                  userData['image'].startsWith('http')
                                                                      ? userData['image']
                                                                      : imageURL + userData['image'],
                                                                  width: 115,
                                                                  fit: BoxFit.fill,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    // Handle image loading errors
                                                                    return Image.asset(
                                                                      'assets/images/avatar-3.png',
                                                                      width: 115,
                                                                      fit: BoxFit.fill,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            height: 100,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              children: [
                                                                Text(
                                                                  userData['name'] ?? '-',
                                                                  style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                    20.0,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.edit,
                                                            color: Color(0xFF7676FE),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => EditProfileScreen(id: userData['id'])),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(
                                                                userFans.toString(),
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Fans',
                                                                style:
                                                                TextStyle(
                                                                  color: Color(
                                                                      0xFF7676FE),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(width: 20),
                                                          Column(
                                                            children: [
                                                              Text(
                                                                userFollowing.toString(),
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Following',
                                                                style:
                                                                TextStyle(
                                                                  color: Color(
                                                                      0xFF7676FE),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(width: 20),
                                                          Column(
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  FormattedNumber(value: totalContribution),
                                                                  SizedBox(
                                                                      width: 5),
                                                                  Image.asset(
                                                                    'assets/images/gem.png',
                                                                    width: 20,
                                                                    height: 20,
                                                                    // Adjust the image path and dimensions as needed
                                                                  ),
                                                                ],
                                                              ),
                                                              Text(
                                                                'Contribute',
                                                                style:
                                                                TextStyle(
                                                                  color: Color(
                                                                      0xFF7676FE),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(width: 20),
                                                          Column(
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  FormattedNumber(value: totalGemsEarned),
                                                                  SizedBox(
                                                                      width: 3),
                                                                  Image.asset(
                                                                    'assets/images/profile_page/receive_icon.png',
                                                                    width: 20,
                                                                    height: 20,
                                                                    // Adjust the image path and dimensions as needed
                                                                  ),
                                                                ],
                                                              ),
                                                              Text(
                                                                'Receive',
                                                                style:
                                                                TextStyle(
                                                                  color: Color(
                                                                      0xFF7676FE),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top:
                              70.0), // Adjust the top padding value as needed
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF1B228B).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Padding(
                              padding:
                              EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  GridView.count(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 19.0,
                                    mainAxisSpacing: 20.0,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Fluttertoast.showToast(
                                            msg: "Some buttons aren't ready yet.\n We're working on it!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            fontSize: 14.0,
                                          );
                                        },
                                        child: Image.asset(
                                          'assets/images/profile_page/Market.png',
                                          width: 30.0,
                                          height: 60.0,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                const GemsScreen()),
                                          );
                                        },
                                        child: Image.asset(
                                          'assets/images/profile_page/wallet.png',
                                          width: 30.0,
                                          height: 60.0,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Fluttertoast.showToast(
                                            msg: "Some buttons aren't ready yet.\n We're working on it!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            fontSize: 14.0,
                                          );
                                        },
                                        child: Image.asset(
                                          'assets/images/profile_page/my_bag.png',
                                          width: 30.0,
                                          height: 60.0,
                                        ),
                                      ),

                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                const QrCodeScreen()),
                                          );
                                        },
                                        child: Image.asset(
                                          'assets/images/profile_page/qr-code.png',
                                          width: 30.0,
                                          height: 60.0,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Fluttertoast.showToast(
                                            msg: "Some buttons aren't ready yet.\n We're working on it!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            fontSize: 14.0,
                                          );
                                        },
                                        child: Image.asset(
                                          'assets/images/profile_page/record.png',
                                          width: 30.0,
                                          height: 60.0,
                                        ),
                                      ),

                                      GestureDetector(
                                        onTap: () {
                                          Fluttertoast.showToast(
                                            msg: "Some buttons aren't ready yet.\n We're working on it!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            fontSize: 14.0,
                                          );
                                        },
                                        child: Image.asset(
                                          'assets/images/profile_page/badges.png',
                                          width: 30.0,
                                          height: 60.0,
                                        ),
                                      ),

                                      SizedBox
                                          .shrink(), // Empty SizedBox for alignment with column 0
                                      SizedBox
                                          .shrink(), // Empty SizedBox for alignment with column 1
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            shieldImageUrl.isNotEmpty
                                ? Image.network (
                              shieldImageUrl,
                              height: 100.0,
                              width: 75.0,
                              fit: BoxFit.fill,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return Image.asset('assets/images/shield/shield_2.png',
                                  height: 100.0,
                                  width: 75.0,
                                  fit: BoxFit.fill,);
                              },
                            )
                                : CircularProgressIndicator(),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF2370B1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(0),
                                ),
                                border: Border.all(
                                  color: Color(0xFF012C74),
                                  width: 2.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 15.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Adjust the spacing between number and image
                                    Row(
                                      children: [
                                        Text(
                                              () {
                                            if (totalGems <= 10000) {
                                              return 'SVIP 1';
                                            } else if (totalGems > 10000 &&
                                                totalGems <= 20000) {
                                              return 'SVIP 2';
                                            } else if (totalGems > 20000 &&
                                                totalGems <= 50000) {
                                              return 'SVIP 3';
                                            } else if (totalGems > 50000 &&
                                                totalGems <= 70000) {
                                              return 'SVIP 4';
                                            } else if (totalGems > 70000) {
                                              return 'SVIP 5';
                                            } else {
                                              return 'Error';
                                            }
                                          }(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'FilsonProRegular',
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFF290092),
                                            borderRadius:
                                            BorderRadius.circular(30.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5.0,
                                              horizontal: 25.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                      () {
                                                    if (totalGems <= 10000) {
                                                      return '${NumberFormat.decimalPattern().format(totalGems)}/10,000';
                                                    } else if (totalGems >
                                                        10000 &&
                                                        totalGems <= 20000) {
                                                      return '${NumberFormat.decimalPattern().format(totalGems)}/20,000';
                                                    } else if (totalGems >
                                                        20000 &&
                                                        totalGems <= 50000) {
                                                      return '${NumberFormat.decimalPattern().format(totalGems)}/50,000';
                                                    } else if (totalGems >
                                                        50000 &&
                                                        totalGems <= 70000) {
                                                      return '${NumberFormat.decimalPattern().format(totalGems)}/70,000';
                                                    } else if (totalGems >
                                                        70000) {
                                                      return '${NumberFormat.decimalPattern().format(totalGems)}/100,000';
                                                    } else {
                                                      return 'Error';
                                                    }
                                                  }(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily:
                                                    'FilsonProRegular',
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
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
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF1B228B).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Others',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'FilsonProRegular',
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(
                                msg: "Some buttons aren't ready yet.\n We're working on it!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                fontSize: 14.0,
                              );
                            },
                            child: Image.asset(
                              'assets/images/profile_page/apps_tutorial.png',
                              width: 100.0,
                              height: 40.0, // Adjusted size for Apps Tutorial
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(
                                msg: "Some buttons aren't ready yet.\n We're working on it!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                fontSize: 14.0,
                              );
                            },
                            child: Image.asset(
                              'assets/images/profile_page/apps_feedback.png',
                              width: 100.0,
                              height: 40.0, // Adjusted size for Apps Feedback
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SongHomeScreen()),
                              );
                            },
                            child: Image.asset(
                              'assets/images/profile_page/song_request.png',
                              width: 100.0,
                              height: 40.0, // Adjusted size for Song Request
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              const url = 'https://staronstage.my/';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                errorSnackBar(context, 'Could not launch $url');
                              }
                            },
                            child: Image.asset(
                              'assets/images/profile_page/customer_support.png',
                              width: 100.0,
                              height: 40.0, // Adjusted size for Customer Support
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: BottomNavBar(currentIndex: widget.currentIndex),
    );
  }
}

class FormattedNumber extends StatelessWidget {
  final int value;

  const FormattedNumber({required this.value});

  String _formatValue() {
    if (value >= 1000000) {
      final formattedValue = (value / 1000000).toStringAsFixed(1);
      return '${formattedValue.endsWith('.0') ? formattedValue.substring(0, formattedValue.length - 2) : formattedValue}M';
    } else if (value >= 1000) {
      final formattedValue = (value / 1000).toStringAsFixed(1);
      return '${formattedValue.endsWith('.0') ? formattedValue.substring(0, formattedValue.length - 2) : formattedValue}K';
    } else {
      return value.toString();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Text(
      _formatValue(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

}
