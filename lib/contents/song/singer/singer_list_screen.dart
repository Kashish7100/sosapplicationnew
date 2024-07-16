import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vsing/contents/song/search_input_delegate.dart';
import 'package:vsing/contents/song/singer/song_by_singer_screen.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/song_services.dart';

class SingerListScreen extends StatefulWidget {
  const SingerListScreen({Key? key, required this.id}) : super(key: key);

  final int id;

  @override
  State<SingerListScreen> createState() => _SingerListScreenState();
}

class _SingerListScreenState extends State<SingerListScreen> {

  List<dynamic> singers = [];
  int id = 0;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    id = widget.id;
    getSingerData(id, searchText);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getSingerData(id, String searchText) async {
    try {
      http.Response response = await SongServices.getSingerData(id, searchText);
      Map responseMap = jsonDecode(response.body);

      if (responseMap['Status'] == true) {
        setState(() {
          singers = responseMap['SingerList'];
        });
        print(singers);
      } else {
        print('Failed to get singer data');
      }

    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "Uh-oh! It looks like we can’t connect to the song provider at the moment.");
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
                    id == 1 ? 'Male' :
                    id == 2 ? 'Female' :
                    id == 0 ? 'All Singers' :
                    id == 3 ? 'Group' :
                    'List of Singer',
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
                      getSingerData(id, searchText);
                    },
                  ),
                ),
                singers.isEmpty
                    ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      var singer = singers[index];
                      var title = singer['SingerName'];
                      var singerNo = singer['SingerNo'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SingerSongListScreen(singerName: title, singerNo: singerNo),
                              ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
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
                                fontSize: 14,
                              ),
                            ),
                            leading: const Icon(Icons.person, size: 25, color: Colors.white),
                          ),
                        ),
                      );
                    },
                    childCount: singers.length,
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
