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

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {

  late SharedPreferences preferences;
  List<dynamic> songs = [];
  Map<int, String> languages = {};
  Map<int, String> categories = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getSongData();
    getLanguageData();
    getCategoryData();

    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      getSongData();
      getLanguageData();
      getCategoryData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void getSongData() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var tableId = localStorage.getString('TableID');

      if(tableId != null)
      {
        http.Response response = await SongServices.getPlaylistData(tableId);
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

  void removeSongFromPlaylist(int TableSongID) async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var tableId = localStorage.getString('TableID');

      if (TableSongID != null && TableSongID != 0 && tableId != null) {
        http.Response response = await SongServices.removeSongFromPlaylist(TableSongID, tableId);
        Map responseMap = jsonDecode(response.body);

        if (responseMap['Status'] == true) {
          Fluttertoast.showToast(msg: 'Song removed from playlist!');
          getSongData();
          removeLiveSession(TableSongID);
        } else {
          print('Failed to remove song from playlist');
        }
      } else {
        errorSnackBar(context, 'Error remove from playlist!');
      }
    } catch (e) {
      // print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void removeLiveSession(int TableSongID) async {
    try {
      if (TableSongID != null && TableSongID != 0) {
        http.Response response = await SongServices.removeLiveSession(TableSongID);
        Map responseMap = jsonDecode(response.body);

        if (responseMap['Status'] == true) {
          print('Remove song from live singer data');
        } else {
          print('Failed to remove song from live singer data');
        }
      } else {
        errorSnackBar(context, 'Error remove song!');
      }
    } catch (e) {
      // print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Clear Playlist"),
          content: Text("Are you sure you want to clear the playlist?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                clearPlaylist();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Clear"),
            ),
          ],
        );
      },
    );
  }

  void clearPlaylist() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var tableId = localStorage.getString('TableID');

      if(tableId != null)
      {
        http.Response response = await SongServices.clearPlaylist(tableId);
        Map responseMap = jsonDecode(response.body);

        if (responseMap['Status'] == true) {
          Fluttertoast.showToast(msg: 'Playlist cleared!');
          removeAllLiveSession();
          // Reload screen after clearing the playlist
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) => PlaylistScreen()),
          );
        } else {
          print('Failed to clear playlist');
        }
      }
    } catch (e) {
      // print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void removeAllLiveSession() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var tableId = localStorage.getString('TableID');

      if(tableId != null)
      {
        http.Response response = await SongServices.removeAllLiveSession(tableId);
        Map responseMap = jsonDecode(response.body);

        if (responseMap['Status'] == true) {
          print('Remove all song from live singer data');
        } else {
          print('Failed to remove all song from live singer data');
        }
      }
    } catch (e) {
      // print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
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
                    'Playlist',
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
                  actions: [
                    IconButton(
                      onPressed: () {
                        showClearConfirmationDialog(context);
                      },
                      icon: Icon(Icons.clear_all, color: Colors.white),
                    ),
                  ],
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
                      var title = song['SongName'];
                      var path = song['FileName'];
                      var languageId = song['LanguageType'];
                      var languageName = languages[languageId] ?? 'Unknown';
                      var categoryId = song['SongType'];
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
                          trailing: Icon(Icons.close, size: 30, color: Colors.red),
                          onTap: () async {
                            removeSongFromPlaylist(song['TableSongID']);
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
