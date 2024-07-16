import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/song_services.dart';

class EntirePlaylistScreen extends StatefulWidget {
  const EntirePlaylistScreen({Key? key}) : super(key: key);

  @override
  State<EntirePlaylistScreen> createState() => _EntirePlaylistScreenState();
}

class _EntirePlaylistScreenState extends State<EntirePlaylistScreen> {

  late SharedPreferences preferences;
  String currentSongNo = '';
  int currenTableSongID = 0;
  List<dynamic> songs = [];
  Map<int, String> languages = {};
  Map<int, String> categories = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start the periodic timer for fetching data every minute
    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      getSongData();
      getCurrentPlayerData();
      getLanguageData();
      getCategoryData();
    });
    getSongData();
    getCurrentPlayerData();
    getLanguageData();
    getCategoryData();
  }

  void getSongData() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var tableId = localStorage.getString('TableID');

      if(tableId != null)
      {
        http.Response response = await SongServices.getEntirePlaylistData(tableId);
        Map responseMap = jsonDecode(response.body);

        if (responseMap['Status'] == true) {
          setState(() {
            songs = responseMap['PlayList'];
          });
          print(songs);
        } else {
          print('Failed to get song data');
        }
      }
    } catch (e) {
      print(e.toString());
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  void getCurrentPlayerData() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var tableId = localStorage.getString('TableID');

      if(tableId != null)
      {
        http.Response response = await SongServices.getCurrentPlayerData(tableId);
        Map<String, dynamic> responseMap = jsonDecode(response.body);

        if (responseMap['Status'] == true) {
          setState(() {
            var currentSong = responseMap['CurrentSong'];
            currentSongNo = currentSong['Song']['SongNo'];
            currenTableSongID = currentSong['Song']['TableSongID'];
          });
        } else {
          print('Failed to get language data');
        }
      }
    } catch (e) {
      print(e.toString());
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  void getLanguageData() async {
    try {
      http.Response response = await SongServices.getLanguageData();
      Map responseMap = jsonDecode(response.body);

      if (responseMap['Status'] == true) {
        setState(() {
          for (var lang in responseMap['Languages']) {
            languages[lang['ID']] = lang['Name'];
          }
        });
      } else {
        print('Failed to get language data');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void getCategoryData() async {
    try {
      http.Response response = await SongServices.getCategoryData();
      Map responseMap = jsonDecode(response.body);

      if (responseMap['Status'] == true) {
        setState(() {
          for (var cat in responseMap['Categories']) {
            categories[cat['ID']] = cat['Name'];
          }
        });
      } else {
        print('Failed to get category data');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Icon getTrailingIcon(String songNo) {
    if (songNo == currentSongNo && currenTableSongID == 0) {
      return Icon(Icons.volume_up, size: 30, color: Colors.green);
    } else {
      // Otherwise, show the skip next icon
      return Icon(Icons.skip_next, size: 30, color: Colors.blue);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                    'Entire Playlist',
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
                ),
                songs.isEmpty
                    ? const SliverFillRemaining(
                  child: Center(
                    child: Text('No data found', style: TextStyle(color: Colors.white)),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      var song = songs[index];
                      var title = song['Song']['SongName'] ?? '';
                      var path = song['Song']['FileName'];
                      var languageId = song['Song']['LanguageType'];
                      var languageName = languages[languageId] ?? 'Unknown';
                      var categoryId = song['Song']['SongType'];
                      var categoryName = categories[categoryId] ?? 'Unknown';

                      return Container(
                        margin: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
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
                          title: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'FilsonProRegular',
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                  margin: const EdgeInsets.only(right: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Color(0xFFc7f5d9), // Color of the box for language
                                  ),
                                  child: Text(
                                    languageName,
                                    style: const TextStyle(
                                      color: Color(0xFF0b4121),
                                      fontFamily: 'FilsonProRegular',
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Color(0xFFffebc2),
                                  ),
                                  child: Text(
                                    categoryName,
                                    style: const TextStyle(
                                      color: Color(0xFF453008),
                                      fontFamily: 'FilsonProRegular',
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          leading: const Icon(Icons.audiotrack, size: 30, color: Colors.white),
                          trailing: getTrailingIcon(song['Song']['SongNo']),
                        ),
                      );
                    },
                    childCount: songs.length,
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
