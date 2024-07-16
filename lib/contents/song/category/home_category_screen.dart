import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vsing/contents/song/category/category_song_screen.dart';
import 'package:vsing/contents/song/language/languange_song_screen.dart';
import 'package:vsing/contents/song/singer/singer_list_screen.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vsing/services/song_services.dart';

class HomeCategoryScreen extends StatefulWidget {
  const HomeCategoryScreen({Key? key}) : super(key: key);

  @override
  State<HomeCategoryScreen> createState() => _HomeCategoryScreenState();
}

class _HomeCategoryScreenState extends State<HomeCategoryScreen> {

  late SharedPreferences preferences;

  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    getCategoryData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getCategoryData() async {
    try {
      http.Response response = await SongServices.getCategoryData();
      Map responseMap = jsonDecode(response.body);
      print(responseMap);

      if (responseMap['Status'] == true) {
        setState(() {
          categories = responseMap['Categories'];
        });
        print(categories);
      } else {
        print('Failed to get data');
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
                    'Category',
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
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        final menuItem = categories[index];

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
                            // leading: Icon(
                            //   menuItem["icon"],
                            //   color: Colors.white,
                            //   size: 30,
                            // ),
                            title: Text(
                              menuItem["Name"],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategorySongListScreen(categoryId: menuItem["ID"], categoryName: menuItem["Name"]),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: categories.length,
                    ),
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
