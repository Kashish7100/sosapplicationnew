import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/services/chat_services.dart';
import 'package:vsing/services/globals.dart';
import 'package:vsing/services/song_services.dart';

import '../navbar/bottom_nav_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late SharedPreferences preferences;
  bool _isLoading = false;
  int _userId = 0;
  int _liveSingerId = 0;
  int _liveSingerUserId = 0;
  List<dynamic> userComments = [];
  Map<String, dynamic> liveSinger = {};
  TextEditingController _commentTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  Timer? _debounce;
  DateTime? _lastRequestTime;

  @override
  void initState() {
    super.initState();
    initializeData();
    _timer = Timer.periodic(Duration(seconds: 30), (Timer timer) {
      getCurrentLiveSingerData();
    });
    getCurrentLiveSingerData();
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
      _userId = user['id'];
    });
  }

  Future<void> getCurrentLiveSingerData() async {
    final now = DateTime.now();
    if(_lastRequestTime != null && now.difference(_lastRequestTime!).inSeconds < 30) {
      return;
    }
    _lastRequestTime = now;

    try {
      http.Response response = await SongServices.getCurrentLiveSingerData();
      Map<String, dynamic> responseMap = jsonDecode(response.body);

      if (responseMap['data'] != null) {
        setState(() {
          _liveSingerId = responseMap['data']['id'];
          _liveSingerUserId = responseMap['data']['user_id'];
        });
        await getCommentData(_liveSingerId);
      } else {
        print('Failed to get current live singer data');
      }
    } catch (e) {
      print(e.toString());
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  getCommentData(int liveSingerId) async {
    try {
      http.Response response = await ChatServices.index(liveSingerId);
      Map<String, dynamic> responseMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data != null) {
          setState(() {
            userComments = data['comments'] ?? [];
            liveSinger = data['live_singer'] ?? {};
            _liveSingerId = liveSinger['id'] ?? 0;
          });
        } else {
          errorSnackBar(context, 'No comment found');
        }
      } else {
        print(responseMap.values.first);
        // errorSnackBar(context, responseMap.values.first);
      }
    } catch (e) {
      print(e.toString());
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  void debounce(Function() action, {int milliseconds = 1000}) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: milliseconds), action);
  }

  Future<void> _sendMessage(int userId) async {
    if (_liveSingerId == 0) {
      errorSnackBar(context, 'Error! No live singer.');
      return;
    }

    String message = _commentTextController.text.trim();
    if (message.isEmpty) {
      errorSnackBar(context, 'Message is empty!');
      return;
    }

    if(_liveSingerUserId == userId) {
      Fluttertoast.showToast(msg: 'You cannot send a comment to yourself!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      http.Response response = await ChatServices.store(userId, _liveSingerId, message);
      Map responseMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await getCommentData(_liveSingerId);

        setState(() {
          _commentTextController.clear();
          _isLoading = false;
        });

        // Wait for the next frame before scrolling
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Scroll to the bottom after updating comments
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });

        Fluttertoast.showToast(msg: 'Your message send!');
      } else {
        _isLoading = false;
        print(responseMap.values.first);
        // errorSnackBar(context, responseMap.values.first);
      }
    } catch (e) {
      _isLoading = false;
      print(e.toString());
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _timer?.cancel();
    _commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/mainbase.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 40.0, left: 15.0, right: 15.0),
                    padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
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
                      border: Border.all(color: Colors.white, width: 0.5),
                    ),
                    child: userComments.isEmpty
                        ? const Center(
                      child: Text(
                        'No message found',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                        : ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: userComments.length,
                        itemBuilder: (context, index) {
                          final userComment = userComments[index];

                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userComment['sender_name'] + ': ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    userComment['comment'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                    ),
                  ),
              ),

              // Send comment container
              Container(
                margin: const EdgeInsets.only(top: 15.0, bottom: 25.0, left: 15.0, right: 15.0),
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
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
                  border: Border.all(color: Colors.white, width: 1.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: TextField(
                          controller: _commentTextController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: Colors.white),
                            suffixIcon: _commentTextController.text.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _commentTextController.clear();
                                });
                              },
                            )
                                : null,
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 15,),
                          onChanged: (text) {
                            setState(() {}); // Triggers rebuild to show/hide the clear icon
                          },
                        ),
                      ),
                    ),
                    _isLoading
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C5D4)),
                    )
                        : TextButton(
                      onPressed: () {
                        debounce(() => _sendMessage(_userId));
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF00C5D4),
                        textStyle: TextStyle(fontSize: 15), // Increase text size
                      ),
                      child: Text('SEND'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
