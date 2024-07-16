import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/home_screen.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/tablelayout_services.dart';
import 'package:vsing/services/user_services.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({Key? key}) : super(key: key);

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  late SharedPreferences preferences;

  List<dynamic> tableLayouts = [];

  int table_layout_id = 0;
  int user_id = 0;

  @override
  void initState() {
    super.initState();
    getTableLayoutData();
  }

  void getTableLayoutData() async {
    try {
      http.Response response = await TableLayoutServices.index();
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          tableLayouts = data
              .map((layout) =>
                  {...layout, 'isSelected': layout['id'] == table_layout_id})
              .toList();
          print(tableLayouts);
        });
      } else {
        errorSnackBar(context, data.values.first);
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void getSelectedTableFromPrefs() async {
    preferences = await SharedPreferences.getInstance();
    final selectedTableId = preferences.getInt('selectedTableId') ?? 0;
    setState(() {
      table_layout_id = selectedTableId;
    });
  }

  void saveSelectedTableToPrefs(int tableLayoutId) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setInt('selectedTableId', tableLayoutId);
  }

  void onTapTableLayout(int tableLayout) {
    setState(() {
      table_layout_id = tableLayout;
      print(table_layout_id);

      for (final layout in tableLayouts) {
        layout['isSelected'] = layout['id'] == table_layout_id;
      }
    });

    saveSelectedTableToPrefs(
        table_layout_id); // Save the selected table ID to SharedPreferences
  }

  // Store role data function
  submitData(int table_layout_id, user_id) async {
    try {
      var user = jsonDecode(preferences.getString('user').toString());
      user_id = user['id'];

      if (table_layout_id != 0) {
        http.Response response =
            await TableLayoutServices.storeData(table_layout_id, user_id);

        if (response.statusCode == 200) {
          print(response.body);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => HomeScreen(),
            ),
          );
          Fluttertoast.showToast(msg: 'Table selected!');
        } else {
          errorSnackBar(context, response.body);
        }
      } else {
        errorSnackBar(context, 'Please select a table');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mainbase.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 65),
              Container(
                height: 20,
                width: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Please select your seat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 173, 29, 231),
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(0.0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 0.0,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: (tableLayouts.length / 3).ceil(),
                      itemBuilder: (context, index) {
                        final startIndex = index * 3;
                        final endIndex = startIndex + 3;
                        final rowtableLayouts = tableLayouts.sublist(
                          startIndex,
                          endIndex < tableLayouts.length
                              ? endIndex
                              : tableLayouts.length,
                        );

                        return Row(
                          children: [
                            for (final tableLayout in rowtableLayouts) ...[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        onTapTableLayout(tableLayout['id']);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 23),
                                        child: Container(
                                          height: 50,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: tableLayout['isSelected']
                                                ? Color.fromARGB(
                                                    255, 173, 29, 231)
                                                : Color.fromARGB(255, 0, 0, 0),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.fromARGB(
                                                    255, 173, 29, 231),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              tableLayout['name'],
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0,),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color.fromARGB(255, 173, 29, 231),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        submitData(table_layout_id, user_id);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 173, 29, 231),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                          color: Color.fromARGB(255, 132, 26, 199),
                        ),
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0,),
            ],
          ),
        ],
      ),
    );
  }
}
