import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/contents/song/search_input_delegate.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:vsing/services/globals.dart';
import 'package:http/http.dart' as http;
import 'package:vsing/services/song_services.dart';


class SingerSongListScreen extends StatefulWidget {
  const SingerSongListScreen({Key? key, required this.singerName, required this.singerNo}) : super(key: key);

  final String singerName;
  final String singerNo;

  @override
  State<SingerSongListScreen> createState() => _SongBySingerListScreenState();
}

class _SongBySingerListScreenState extends State<SingerSongListScreen> {

  late SharedPreferences preferences;
  String tableId = '';
  int _id = 0;
  String singerNo = '';
  String singerName = '';
  String searchText = '';
  List<dynamic> songs = [];
  Map<int, String> languages = {};
  Map<int, String> categories = {};
  List<dynamic> playlist = [];
  int totalGems = 0;

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
    singerNo = widget.singerNo;
    singerName = widget.singerName;
    getSongData(singerNo, searchText);
    getLanguageData();
    getCategoryData();
    getSongPriceData();
  }

  Future<void> _loadSharedPreferences() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      tableId = localStorage.getString('TableID') ?? '';
    });
  }

  void getSongData(singerNo, searchText) async {
    try {
      http.Response response = await SongServices.getSingerSongData(singerNo, searchText);
      final data = jsonDecode(response.body);
      print(data);

      if (data['Status'] == true) {
        setState(() {
          songs = data['SongList'];
        });
        print(songs);
      } else {
        errorSnackBar(context, data.values.first);
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "Uh-oh! It looks like we can’t connect to the song provider at the moment.");
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
    }
  }

  void getSongPriceData() async {
    try {
      http.Response response = await SongServices.getSongPriceData();
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          totalGems = data['total_gems'];
        });
      } else {
        errorSnackBar(context, data.values.first);
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
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
                    singerName,
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
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SearchInputDelegate(
                    onSearchTextChanged: (text) {
                      setState(() {
                        searchText = text;
                      });
                      getSongData(singerNo, searchText);
                    },
                  ),
                ),
                songs.isEmpty
                    ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      var song = songs[index];
                      var title = song['SongName'];
                      var path = song['FileName'];
                      var languageId = song['LanguageType'];
                      var languageName = languages[languageId] ?? 'Unknown';
                      var categoryId = song['SongType'];
                      var categoryName = categories[categoryId] ?? 'Unknown';

                      return Container(
                        margin: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0), // Add bottom padding here
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "Artist: ${song['SingerName']}",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'FilsonProRegular',
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
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
                              ],
                            ),
                          ),
                          leading: const Icon(Icons.audiotrack, size: 30, color: Colors.white),
                          trailing: Icon(Icons.playlist_add, size: 30, color: Colors.white),
                          onTap: () async {
                            showConfirmationDialog(context, song['SongNo'], tableId, playlist, totalGems);
                          },
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
