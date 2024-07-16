import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vsing/contents/chat_screen.dart';
import 'package:vsing/contents/gems_screen.dart';
import 'package:vsing/contents/qrscan_table_screen.dart';
import 'package:vsing/contents/song/home_screen.dart';
import 'package:vsing/contents/svip/svip_1_screen.dart';
import 'package:vsing/contents/svip/svip_2_screen.dart';
import 'package:vsing/contents/svip/svip_3_screen.dart';
import 'package:vsing/contents/svip/svip_4_screen.dart';
import 'package:vsing/contents/svip/svip_5_screen.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/main.dart';
import 'package:vsing/services/gift_services.dart';
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/live_services.dart';
import 'package:vsing/services/song_services.dart';
import 'package:vsing/services/user_services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedPreferences preferences;
  Timer? _timer;
  Timer? _debounce;

  bool isLoading = false;
  int userID = 0;
  String tableId = '';
  int userRanking = 0;
  Map<String, dynamic> userData = {};
  Map<String, dynamic>? userEarning = {};
  Map<String, dynamic>? liveSingerData = {};
  Map<String, dynamic>? liveSinger = {};
  Map<String, dynamic>? trackData = {};
  List<dynamic> gifts = [];
  List<dynamic> rankings = [];
  List<dynamic> singQueues = [];
  List<dynamic> topGifters = [];
  List<int> customOrderTopGifters = [1, 0, 2];
  List<dynamic> topSingers = [];
  List<int> customOrderTopSingers = [1, 0, 2];
  int totalGems = 0;
  String shieldImageUrl = '';
  int singerUserId = 0;
  String singerName = 'No user live';
  String singerImage = '';
  String singerGifts = '0';
  String currentSongName = 'No song play';
  int currentSongID = 0;
  String currentSongNo = '';
  String currentTableUniqueKey = '';
  int currentTableSongID = 0;
  int itemCountToShow = 2;

  bool showAllGifts = false;
  bool isFirstPageOpen = false;
  bool isSecondPageOpen = false;
  bool isThirdPageOpen = false;
  bool isForthPageOpen = false;
  bool isFifthPageOpen = false;

  @override
  void initState() {
    super.initState();
    initializeData();

    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      getCurrentLiveSingerData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  void initializeData() async {
    preferences = await SharedPreferences.getInstance();
    var userJson = preferences.getString('user');

    if (userJson == null) {
      errorSnackBar(context, 'Unauthenticated user!');
      return;
    }

    var user = jsonDecode(userJson);
    setState(() {
      userID = user['id'];
    });

    getUserData(userID);
  }

  void getUserData(int userID) async {
    if (userID == null || userID == 0) {
      errorSnackBar(context, 'Undefined user!');
      return;
    }

    try {
      http.Response response = await UserServices.index(userID);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          userData = data['user'];
          userEarning = userData['user_earning'];
          gifts = data['gifts'];
          rankings = data['rankings'];
          topGifters = data['topGifters'];
          topSingers = data['topSingers'];
          totalGems = userEarning?['total_gems'] ?? 0;

          rankings.sort((a, b) => a['total_gems'].compareTo(b['total_gems']));

          shieldImageUrl = getShieldImageUrl(totalGems, rankings);
          userRanking = getUserRanking(totalGems, rankings);
        });
      } else {
        errorSnackBar(context, data.values.first);
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }


  void getCurrentLiveSingerData() {
    // Debounce the function to prevent rapid API calls
    _debounce?.cancel();
    _debounce = Timer(Duration(seconds: 1), () {
      _fetchLiveSingerData();
      _fetchLiveSingerQueue();
    });
  }

  //Fetch singer queue
  Future<void> _fetchLiveSingerQueue() async {
    try {
      http.Response response = await UserServices.getLiveSingerQueue();
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          singQueues = data['singQueues'];
        });
      } else {
        print(data.values.first);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //Get live singer data to fetch table unique key
  Future<void> _fetchLiveSingerData() async {
    try {
      http.Response response = await SongServices.getCurrentLiveSingerData();
      Map<String, dynamic> responseMap = jsonDecode(response.body);

      if (responseMap['data'] != null) {
        setState(() {
          tableId = responseMap['data']['TableUniqueKey'];
        });
        await getCurrentPlayerData(tableId);
      } else {
        print('Failed to get current player data');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Get current play song data from song provider api
  Future<void> getCurrentPlayerData(tableId) async {
    try {
      if(tableId != null) {
        http.Response response = await SongServices.getCurrentPlayerData(tableId);
        Map<String, dynamic> responseMap = jsonDecode(response.body);

        if (responseMap['Status'] == true) {
          var currentSong = responseMap['CurrentSong'];

          setState(() {
            currentSongName = currentSong['Song']['SongName'];
            currentSongID = currentSong['Song']['SongID'];
            currentSongNo = currentSong['Song']['SongNo'];
            currentTableUniqueKey = currentSong['TableInfo']['UniqueKey'];
            currentTableSongID = currentSong['Song']['TableSongID'];
          });
          await getLiveSingerData(currentSongID, currentSongNo, currentTableUniqueKey, currentTableSongID);
        } else {
          print('Failed to get current player data');
        }
      } else {
        print('No live singer');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getLiveSingerData(int currentSongID, String currentSongNo, String currentTableUniqueKey, int currentTableSongID) async {
    try {
      http.Response response = await LiveServices.getLiveSingerData(currentSongID, currentSongNo, currentTableUniqueKey, currentTableSongID);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        liveSingerData = data['live_singer'];

        setState(() {
          singerUserId = liveSingerData?['user_id'] ?? '';
          singerName = liveSingerData?['singer_name'] ?? '';
          singerImage = liveSingerData?['singer_image'] ?? '';
          singerGifts = liveSingerData?['total_gift_receives'].toString() ?? '0';
        });
      } else {
        print('Failed to get live singer data');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void sendGift(int userID,int giftId, int singerUserId) async {

    if(singerUserId == null || singerUserId == 0) {
      errorSnackBar(context, 'No live singer!');
      return;
    }

    if (userID == null || userID == 0 || giftId == null || giftId == 0) {
      errorSnackBar(context, 'Error sending gift!');
      return;
    }

    if(singerUserId == userID) {
      Fluttertoast.showToast(msg: 'You cannot send a gift to yourself!');
      return;
    }

    try {
      http.Response response = await GiftServices.storeSendGift(userID, giftId);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'You sent a gift to ' + singerName);
      } else {
        errorSnackBar(context, 'Error sending gift!');
      }
    } catch (e) {
      print(e.toString());
      errorSnackBar(context, 'Error sending gift! Too many request, please try again later.');
    }
  }

  void logout() {
    _timer?.cancel();

    SharedPreferences.getInstance().then((preferences) {
      preferences.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LandingPage(),
        ),
      );
    });
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

  int getUserRanking(int totalGems, List rankings) {
    for (int i = 0; i < rankings.length; i++) {
      if (totalGems < rankings[i]['total_gems']) {
        return i == 0 ? 0 : i - 1;
      }
    }
    return rankings.length - 1;
  }

  String _getFirstWords(String name) {
    List<String> words = name.split(' ');
    // Take the first two words, or as many as are available
    if (words.length > 0) {
      return words.sublist(0, 1).join(' ');
    } else {
      return name;
    }
  }

  String _getFirstTwoWords(String name) {
    List<String> words = name.split(' ');
    // Take the first two words, or as many as are available
    if (words.length > 2) {
      return words.sublist(0, 2).join(' ');
    } else {
      return name;
    }
  }

  void toggleFirstPage() {
    setState(() {
      isFirstPageOpen = !isFirstPageOpen;
    });
  }

  void toggleSecondPage() {
    setState(() {
      isSecondPageOpen = !isSecondPageOpen;
    });
  }

  void toggleThirdPage() {
    setState(() {
      isThirdPageOpen = !isThirdPageOpen;
    });
  }

  void toggleForthPage() {
    setState(() {
      isForthPageOpen = !isForthPageOpen;
    });
  }

  void toggleFifthPage() {
    setState(() {
      isFifthPageOpen = !isFifthPageOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
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
                      // Choose table button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      logout();
                                    },
                                    child: const Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              // Check In Button
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const QRScanTableScreen(),
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
                                        vertical: 10.0,
                                        horizontal: 20.0,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Check In',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 150,
                            width: 150,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CircleAvatar(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: TextStyle(
                                      color: Color(0xFF00FFE4),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    userData['name'] != null
                                        ? _getFirstTwoWords(userData['name'])
                                        : 'No user found',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20.0),
                          Container(
                            height: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final toggleFunctions = [
                                      toggleFirstPage,
                                      toggleSecondPage,
                                      toggleThirdPage,
                                      toggleForthPage,
                                      toggleFifthPage,
                                    ];

                                    if (userRanking >= 0 && userRanking < toggleFunctions.length) {
                                      toggleFunctions[userRanking]();
                                    }
                                  },
                                  child: shieldImageUrl.isNotEmpty
                                      ? Image.network (
                                    shieldImageUrl,
                                    height: 100.0,
                                    width: 75.0,
                                    fit: BoxFit.fill,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset('assets/images/shield/shield_1.png',
                                        height: 100.0,
                                        width: 75.0,
                                        fit: BoxFit.fill,);
                                    },
                                  )
                                      : CircularProgressIndicator(),
                                ),
                                SizedBox(width: 10.0),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20.0),
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 80, 255, 246),
                                      Color.fromARGB(255, 174, 81, 213),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.transparent,
                                    width: 2.0, // Adjust the border width here
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00030E),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final textScaleFactor =
                                            MediaQuery.of(context).textScaleFactor;
                                        final maxFontSize = 13.0;
                                        final minFontSize = 12.0;
                                        final scaledFontSize =
                                            maxFontSize * textScaleFactor;
                                        final fontSize = scaledFontSize.clamp(
                                            minFontSize, maxFontSize);

                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'My Balance',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontSize: fontSize,
                                              ),
                                            ),
                                            const SizedBox(
                                              width:
                                              30, // Adjust the spacing between text and number
                                            ),
                                            Text(
                                              (totalGems != null || totalGems != 0)
                                                  ? NumberFormat.decimalPattern()
                                                  .format(totalGems).toString()
                                                  : '0',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontSize: fontSize,
                                              ),
                                            ),
                                            const SizedBox(
                                              width:
                                              10, // Adjust the spacing between number and image
                                            ),
                                            Image.asset(
                                              "assets/images/gem.png",
                                              width: 25,
                                              height: 40,
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ),
                            ),

                            SizedBox(width: 10.0),

                            // Top up button
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const GemsScreen()),
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
                                  minimumSize: MaterialStateProperty.all(Size(100, 0))
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 80, 255, 246),
                                        Color.fromARGB(255, 174, 81, 213),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 15.0,
                                    ),
                                    alignment: Alignment.center,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final textScaleFactor =
                                              MediaQuery.of(context).textScaleFactor;
                                          final maxFontSize = 12.0;
                                          final minFontSize = 10.0;
                                          final scaledFontSize =
                                              maxFontSize * textScaleFactor;
                                          final fontSize = scaledFontSize.clamp(
                                              minFontSize, maxFontSize);

                                          return Text(
                                            'Top Up',
                                            style: TextStyle(
                                              color: Color(0xFF03383A),
                                              fontSize: fontSize,
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.0),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 5.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.all(10.0),
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
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Now Playing',
                                          style: TextStyle(
                                            color: Colors.white,
                                            height: 2.0,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => ChatScreen()),
                                            );
                                          },
                                          child: Image(
                                            image: AssetImage('assets/images/go_to_chat_btn.png'),
                                            width: 130.0,
                                            height: 50.0,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 8),

                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30.0),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color.fromARGB(255, 80, 255, 246),
                                                Color.fromARGB(255, 174, 81, 213),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(4.0), // Adjust the padding as needed
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(30.0),
                                                color: const Color(0xFF00030E),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Image(
                                                      image:
                                                      AssetImage('assets/images/wave.png'),
                                                      width: 100.0,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        currentSongName,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12.0,
                                                          fontFamily: 'FilsonProRegular',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),


                                    SizedBox(height: 8),

                                    Stack(
                                      children: [
                                        Container(
                                          width: double
                                              .infinity,
                                          height: 320.0,
                                          color: Colors.transparent,
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 10,
                                          left: 10,
                                          child: Image(
                                            image:
                                            AssetImage('assets/images/border_profile.png'),
                                            width: 100.0,
                                            height: 120,
                                          ),
                                        ),

                                        Positioned(
                                            top: 30,
                                            right: 10,
                                            left: 10,
                                            child: Container(
                                              height: 70,
                                              width: 50,
                                              child: Padding(
                                                padding: const EdgeInsets.all(0.0),
                                                child: CircleAvatar(
                                                  child: ClipOval(
                                                    child: singerImage == ''
                                                        ? Image.asset(
                                                      "assets/images/avatar-3.png",
                                                      width: 70,
                                                      fit: BoxFit.fill,
                                                    )
                                                    : Image.network(
                                                      imageURL + singerImage,
                                                      width: 70,
                                                      fit: BoxFit.fill,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        // Handle image loading errors
                                                        return Image.asset(
                                                          'assets/images/avatar-3.png', // Path to your default image asset
                                                          width: 70,
                                                          fit: BoxFit.fill,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                        Positioned(
                                          top: 130,
                                          right: 10,
                                          left: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                singerName,
                                                style:
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'FilsonProRegular',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 155,
                                          right: 10,
                                          left: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                'Total Score',
                                                style:
                                                const TextStyle(
                                                  color: Color(0xFF00C5D4),
                                                  fontFamily: 'FilsonProRegular',
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 175,
                                          right: 10,
                                          left: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  text: singerGifts,
                                                  style:
                                                  const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'FilsonProRegular',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: '  ',
                                                      style: TextStyle(
                                                        fontSize: 4,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: 'SP',
                                                      style: TextStyle(
                                                        color: Color(0xFF00C5D4),
                                                        fontFamily: 'FilsonProRegular',
                                                        fontSize: 12,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 55,
                                          right: 10,
                                          left: 10,
                                          child: Image(
                                            image:
                                            AssetImage('assets/images/sec2_border.png'),
                                            width: 100.0,
                                            height: 230,
                                          ),
                                        ),
                                        Positioned(
                                          top: 190,
                                          right: 10,
                                          left: 10,
                                          child: Image(
                                            image: AssetImage(
                                                'assets/images/send_gift_btn.png'),
                                            width: 55.0,
                                            height: 55,
                                          ),
                                        ),
                                        Positioned(
                                          top: 280,
                                          right: 0,
                                          left: 0,
                                          child: Image(
                                            image:
                                            AssetImage('assets/images/gift_title.png'),
                                            width: 55.0,
                                            height: 55,
                                          ),
                                        ),
                                      ],
                                    ),

                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: itemCountToShow,
                                        itemBuilder: (context, index) {
                                          final startIndex = index * 3;
                                          final endIndex = startIndex + 3;

                                          if(startIndex < gifts.length) {
                                            final rowGifts = gifts.sublist(
                                                startIndex,
                                                endIndex < gifts.length
                                                    ? endIndex
                                                    : gifts.length);

                                            return Row(
                                              children: [
                                                for (final gift in rowGifts) ...[
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        sendGift(userID, gift['id'], singerUserId);
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets.fromLTRB(
                                                            0, 0, 0, 10.0),
                                                        child: Column(
                                                          children: [
                                                            gift['thumbnail'] == null
                                                              ? Image.asset(
                                                              'assets/images/gifts/gift_1.png', // Path to your default image asset
                                                              width: 300.0,
                                                              height: 100.0,
                                                              fit: BoxFit.fill,
                                                            )
                                                              : Image.network(
                                                              imageGiftURL + gift['thumbnail'],
                                                              width: 300.0,
                                                              height: 100.0,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Image.asset(
                                                                  'assets/images/gifts/gift_1.png', // Path to your default image asset
                                                                  width: 300.0,
                                                                  height: 100.0,
                                                                  fit: BoxFit.fill,
                                                                );
                                                              },
                                                            ),
                                                            SizedBox(width: 8),
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
                                                                      gift['total_gems'].toString(),
                                                                      style:
                                                                      const TextStyle(
                                                                        color: Color(
                                                                            0xFF00C5D4),
                                                                        fontFamily:
                                                                        'FilsonProRegular',
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                ],
                                                if (rowGifts.length < 3) ...[
                                                  if (gifts.length % 3 == 1)
                                                    SizedBox(width: 8),
                                                  const Expanded(
                                                    child: SizedBox(),
                                                  ),
                                                ],
                                              ],
                                            );
                                          } else {
                                            return Container();
                                          }
                                        }
                                    ),

                                    SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        // Increase the number of items to show when the "See All" button is pressed
                                        setState(() {
                                          showAllGifts = !showAllGifts;
                                          itemCountToShow = showAllGifts ? gifts.length : 2;
                                        });
                                      },
                                      child: Container(
                                        width: double
                                            .infinity,
                                        height: 35.0,
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
                                          child: Center(
                                            child: Text(
                                              showAllGifts ? 'Hide All Gift' : 'See All Gift',
                                              style: const TextStyle(
                                                color: Color(0xFF00C5D4),
                                                fontFamily: 'FilsonProRegular',
                                                fontSize: 15.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 20.0),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.0,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 200, //adjust card size
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
                            ),
                            const Positioned(
                              top: 3,
                              left: 20,
                              child: Text(
                                'Sing Queue',
                                style: TextStyle(
                                  color: Colors.white,
                                  height: 2.0,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 50, // Adjust this value based on your layout
                              left:
                              5.0, // Adjust this value based on your layout
                              right:
                              5.0, // Adjust this value based on your layout
                              child: Builder(
                                builder: (BuildContext context) {
                                  if(singQueues.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'No singer in the queue.',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: 1,
                                        itemBuilder: (context, index) {
                                          final startIndex = index * 4;
                                          final endIndex = startIndex + 4;
                                          final rowSingQueues = singQueues.sublist(
                                              startIndex,
                                              endIndex < singQueues.length
                                                  ? endIndex
                                                  : singQueues.length);

                                          return Row(
                                            children: [
                                              for (final singQueue in rowSingQueues) ...[
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.fromLTRB(
                                                        0, 0, 0, 10.0),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 110,
                                                          width: 110,
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(10.0),
                                                            child: CircleAvatar(
                                                              child: ClipOval(
                                                                child: singQueue['user']['image'] == null
                                                                    ? Image.asset(
                                                                  "assets/images/avatar-3.png",
                                                                  width: 115,
                                                                  fit: BoxFit.fill,
                                                                )
                                                                    : Image.network(
                                                                  imageURL + singQueue['user']['image'],
                                                                  width: 115,
                                                                  fit: BoxFit.fill,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    // Handle image loading errors
                                                                    return Text('Error loading image');
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                          children: [
                                                            Text(
                                                              _getFirstWords(singQueue['user']['name']),
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
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (singQueues.length % 4 == 1)
                                              const Expanded(
                                                child: SizedBox(),
                                              ),
                                            ],
                                          );
                                        });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.0,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 230, //adjust card size
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
                              child: Stack(
                                children: [],
                              ),
                            ),
                            Positioned(
                              top: 3,
                              left: 20,
                              child: Text(
                                'Entertainments',
                                style: TextStyle(
                                  color: Colors.white,
                                  height: 2.0,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  right: 5,
                                  left: 10,
                                  top:
                                  50.0), // Adjust the margin-top value as needed
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SongHomeScreen()),
                                      );
                                    },
                                    child: Image(
                                      image: AssetImage(
                                          'assets/images/sing_now_btn.png'),
                                      width: 150.0,
                                      height: 150,
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                    5.0, // Adjust the spacing between the images
                                  ),
                                  Expanded(
                                    child: Column(
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
                                          child: Image(
                                            image: AssetImage(
                                                'assets/images/drinks_btn.png'),
                                            width: 150.0,
                                            height: 80,
                                          ),
                                        ),
                                        SizedBox(height: 5.0,),
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
                                          child: Image(
                                            image: AssetImage(
                                                'assets/images/discover_ppl_btn.png'),
                                            width: 150.0,
                                            height: 80,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 20.0),
                      if(topSingers.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.0,
                          ),
                          child: Stack(
                            children: [
                              Container(
                                height: 440, //adjust card size
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
                              ),
                              Positioned(
                                top: 3,
                                left: 20,
                                child: Text(
                                  'Top Singers',
                                  style: TextStyle(
                                    color: Colors.white,
                                    height: 2.0,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 50,
                                left: 10,
                                right: 10,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                    vertical: 8.0,
                                  ),
                                  child: Container(
                                    height: 400,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: topSingers.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                int dataIndex = customOrderTopSingers[index];

                                                if(dataIndex >=0 && dataIndex < topSingers.length) {
                                                  var item = topSingers[dataIndex];
                                                  double paddingValue = dataIndex * 50.0; // padding value based on the index
                                                  double containerHeight = 200.0 - (dataIndex * 50.0); // Define the container height based on the index
                                                  double containerWidth = (MediaQuery.of(context).size.width - 20) / topSingers.length;
                                                  containerWidth = containerWidth < 110.0 ? containerWidth : 110.0;

                                                  return _buildTopSingersItem(item, paddingValue, containerHeight, containerWidth);
                                                } else {
                                                  return SizedBox();
                                                }
                                              },
                                            ),
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
                      SizedBox(height: 20.0),

                      if(topGifters.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.0,
                          ),
                          child: Stack(
                            children: [
                              Container(
                                height: 440, //adjust card size
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
                                child: Stack(
                                  children: [],
                                ),
                              ),
                              Positioned(
                                top: 3,
                                left: 20,
                                child: Text(
                                  'Top Gifters',
                                  style: TextStyle(
                                    color: Colors.white,
                                    height: 2.0,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 50,
                                left: 10,
                                right: 10,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                    vertical: 8.0,
                                  ),
                                  child: Container(
                                    height: 400,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: topGifters.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                int dataIndex = customOrderTopGifters[index];

                                                if(dataIndex >=0 && dataIndex < topGifters.length) {
                                                  var item = topGifters[dataIndex];
                                                  double paddingValue = dataIndex * 50.0; // padding value based on the index
                                                  double containerHeight = 200.0 - (dataIndex * 50.0); // Define the container height based on the index
                                                  double containerWidth = (MediaQuery.of(context).size.width - 20) / topGifters.length;
                                                  containerWidth = containerWidth < 110.0 ? containerWidth : 110.0;

                                                  return _buildTopGiftersItem(item, paddingValue, containerHeight, containerWidth);
                                                } else {
                                                  return SizedBox();
                                                }
                                              },
                                            ),
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
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
              // Blurred Background
              if (isFirstPageOpen ||
                  isSecondPageOpen ||
                  isThirdPageOpen ||
                  isForthPageOpen ||
                  isFifthPageOpen)
                GestureDetector(
                  onTap: () {
                    if (isFirstPageOpen) {
                      toggleFirstPage();
                    }
                    if (isSecondPageOpen) {
                      toggleSecondPage();
                    }
                    if (isThirdPageOpen) {
                      toggleThirdPage();
                    }
                    if (isForthPageOpen) {
                      toggleForthPage();
                    }
                    if (isFifthPageOpen) {
                      toggleFifthPage();
                    }
                  },
                  child: AnimatedOpacity(
                    opacity: (isFirstPageOpen ||
                        isSecondPageOpen ||
                        isThirdPageOpen ||
                        isForthPageOpen ||
                        isFifthPageOpen)
                        ? 1.0
                        : 0.0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // First AnimatedContainer
          if (isFirstPageOpen)
            SVIP1Screen(
              isFirstPageOpen: isFirstPageOpen,
              toggleFirstPage: toggleFirstPage,
              toggleSecondPage: toggleSecondPage,
            ),

          // Second AnimatedContainer
          if (isSecondPageOpen)
            SVIP2Screen(
              isSecondPageOpen: isSecondPageOpen,
              toggleFirstPage: toggleFirstPage,
              toggleSecondPage: toggleSecondPage,
              toggleThirdPage: toggleThirdPage,
            ),

          // Third AnimatedContainer
          if (isThirdPageOpen)
            SVIP3Screen(
              isThirdPageOpen: isThirdPageOpen,
              toggleSecondPage: toggleSecondPage,
              toggleThirdPage: toggleThirdPage,
              toggleForthPage: toggleForthPage,
            ),

          // Forth AnimatedContainer
          if (isForthPageOpen)
            SVIP4Screen(
              isForthPageOpen: isForthPageOpen,
              toggleForthPage: toggleForthPage,
              toggleFifthPage: toggleFifthPage,
            ),

          // Fifth AnimatedContainer
          if (isFifthPageOpen)
            SVIP5Screen(
              isFifthPageOpen: isFifthPageOpen,
              toggleFifthPage: toggleFifthPage,
              toggleFirstPage: toggleFirstPage,
            ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildTopSingersItem(Map<String, dynamic> item, double paddingValue, double containerHeight, double containerWidth){
    return Padding(
      padding: EdgeInsets.only(top: paddingValue),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(
                child: ClipOval(
                  child: item['image'] != null
                      ? Image.network(
                    imageURL + item['image']!,
                    width: 100,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      // Handle image loading errors
                      return Text('Error loading image');
                    },
                  )
                      : Image.asset(
                    "assets/images/avatar-3.png",
                    width: 100,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['name'], // Access the name property from your dynamic data
                style: const TextStyle(
                  color: Color(0xFF00C5D4),
                  fontFamily: 'FilsonProRegular',
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Stack(
              children: [
                Container(
                  height: containerHeight,
                  width: containerWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF228DAB),
                        Color(0xFF224181),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          item['total_gems'], // Access the value property from your dynamic data
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'FilsonProRegular',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopGiftersItem(Map<String, dynamic> item, double paddingValue, double containerHeight, double containerWidth){
    return Padding(
      padding: EdgeInsets.only(top: paddingValue),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(
                child: ClipOval(
                  child: item['image'] != null
                      ? Image.network(
                    imageURL + item['image']!,
                    width: 100,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      // Handle image loading errors
                      return Text('Error loading image');
                    },
                  )
                      : Image.asset(
                    "assets/images/avatar-3.png",
                    width: 100,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['name'], // Access the name property from your dynamic data
                style: const TextStyle(
                  color: Color(0xFF00C5D4),
                  fontFamily: 'FilsonProRegular',
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Stack(
              children: [
                Container(
                  height: containerHeight,
                  width: containerWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF228DAB),
                        Color(0xFF224181),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          item['total_gems'], // Access the value property from your dynamic data
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'FilsonProRegular',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

