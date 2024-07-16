import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/user_services.dart';

class SVIP3Screen extends StatefulWidget {
  const SVIP3Screen({Key? key, required this.isThirdPageOpen, required this.toggleSecondPage, required this.toggleThirdPage, required this.toggleForthPage}) : super(key: key);

  final bool isThirdPageOpen;
  final VoidCallback toggleSecondPage;
  final VoidCallback toggleThirdPage;
  final VoidCallback toggleForthPage;

  @override
  State<SVIP3Screen> createState() => _SVIP3ScreenState();
}

class _SVIP3ScreenState extends State<SVIP3Screen> {
  late SharedPreferences preferences;
  bool isLoading = false;
  int _id = 0;
  List<dynamic> rankings = [];
  String shieldImageUrl = '';

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

      if (_id != 0) {
        http.Response response = await UserServices.index(_id);
        Map responseMap = jsonDecode(response.body);
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          setState(() {
            rankings = data['rankings'];

            for (var ranking in rankings) {
              if(ranking['total_gems'] == 50000) {
                shieldImageUrl = imageRankingURL + ranking['shield_image'];
              }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
        height: widget.isThirdPageOpen ? MediaQuery.of(context).size.height * 0.7 : 0,
        width: double.infinity,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.network(
              shieldImageUrl,
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  return child;
                }
                return CircularProgressIndicator(); // You can replace this with a loading indicator of your choice.
              },
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/shield/SVIP3.png',
                  fit: BoxFit.cover,);
              },
            ).image,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.toggleThirdPage,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                IconButton(
                  onPressed: widget.toggleForthPage,
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
