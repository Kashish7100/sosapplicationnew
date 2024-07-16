import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/contents/qrscan_table_screen.dart';
import 'package:vsing/contents/song/category/home_category_screen.dart';
import 'package:vsing/contents/song/entire_playlist_screen.dart';
import 'package:vsing/contents/song/hit_song_screen.dart';
import 'package:vsing/contents/song/language/home_language_screen.dart';
import 'package:vsing/contents/song/new_song_screen.dart';
import 'package:vsing/contents/song/playlist_screen.dart';
import 'package:vsing/contents/song/singer/singer_category_screen.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/song_services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vsing/services/tablelayout_services.dart';

class CustomBarcode {
  String code;
  BarcodeFormat format;

  CustomBarcode({
    required this.code,
    required this.format,
  });
}

class SongHomeScreen extends StatefulWidget {
  const SongHomeScreen({Key? key}) : super(key: key);

  @override
  State<SongHomeScreen> createState() => _SongHomeScreenState();
}

class _SongHomeScreenState extends State<SongHomeScreen> {
  late SharedPreferences preferences;
  String tableId = '';
  String tableName = '';

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Playlist", "icon": Icons.playlist_play, "route": PlaylistScreen()},
    {"title": "New Songs", "icon": Icons.new_releases, "route": NewSongListScreen()},
    {"title": "Hit Song", "icon": Icons.star, "route": HitSongListScreen()},
    {"title": "Singer", "icon": Icons.person, "route": SingerCategoryScreen()},
    {"title": "Language", "icon": Icons.language, "route": HomeLanguageScreen()},
    {"title": "Category", "icon": Icons.category, "route": HomeCategoryScreen()},
    {"title": "Entire Playlist", "icon": Icons.featured_play_list_outlined, "route": EntirePlaylistScreen()},
  ];

  @override
  void initState() {
    super.initState();
    getTableData();
    _loadSharedPreferences();
  }

  Future<void> _loadSharedPreferences() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      tableId = localStorage.getString('TableID') ?? '';
    });

    // Check if tableId is null
    if (tableId.isEmpty) {
      _showChooseTablePopup();
    }
  }

  void getTableData() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var tableId = localStorage.getString('TableID');

      if(tableId != null)
      {
        http.Response response = await TableLayoutServices.getTableData(tableId);
        Map responseMap = jsonDecode(response.body);

        if (responseMap['Status'] == true) {
          setState(() {
            tableName = responseMap['Table']['TableName'] ?? 'No Table';
          });
        } else {
          print('Failed to get table data');
        }
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void _showChooseTablePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Choose a Table',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'FilsonProRegular',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Please scan a Table QR Code before continuing.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'FilsonProRegular',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanTableScreen()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
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
                    tableName,
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
                  automaticallyImplyLeading: false,
                ),
                SliverFillRemaining(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final menuItem = menuItems[index];

                        return Container(
                          margin: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Color.fromARGB(255, 84, 70, 202).withOpacity(0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(
                              menuItem["icon"],
                              color: Colors.white, // Set icon color to white
                              size: 20, // Set icon size
                            ),
                            title: Text(
                              menuItem["title"],
                              style: TextStyle(
                                color: Colors.white, // Set text color to white
                                fontSize: 15, // Set text size
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => menuItem["route"]),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}
