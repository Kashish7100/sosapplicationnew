import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vsing/contents/song/singer/singer_list_screen.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SingerCategoryScreen extends StatefulWidget {
  const SingerCategoryScreen({Key? key}) : super(key: key);

  @override
  State<SingerCategoryScreen> createState() => _SingerCategoryScreenState();
}

class _SingerCategoryScreenState extends State<SingerCategoryScreen> {

  late SharedPreferences preferences;

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Male", "icon": Icons.male, "route": SingerListScreen(id: 1)},
    {"title": "Female", "icon": Icons.female, "route": SingerListScreen(id: 2)},
    {"title": "Group", "icon": Icons.group, "route": SingerListScreen(id: 3)},
    {"title": "All Singers", "icon": Icons.people, "route": SingerListScreen(id: 0)},
  ];

  @override
  void initState() {
    super.initState();
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
                    'Singer',
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
                                color: Colors.white,
                                size: 25,
                              ),
                              title: Text(
                                menuItem["title"],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
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
                      childCount: menuItems.length,
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
