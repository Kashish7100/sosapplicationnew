import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vsing/contents/buy_gems_screen.dart';
import 'package:vsing/contents/chat_screen.dart';
import 'package:vsing/contents/earn_screen.dart';
import 'package:vsing/contents/gems_screen.dart';
import 'package:vsing/contents/profile_screen.dart';
import 'package:vsing/contents/song/home_screen.dart';
import 'package:vsing/home_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  final int currentIndex;

  @override
  _BottomNavBarState createState() => _BottomNavBarState();

  int getCurrentIndex() {
    return currentIndex;
  }
}

class _BottomNavBarState extends State<BottomNavBar> {
  String label = '';

  @override
  Widget build(BuildContext context) {
    // Access the currentIndex using widget.currentIndex
    int _currentIndex = widget.getCurrentIndex() ?? 0;

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      fixedColor: Color(0xFF020835),
      items: [
        BottomNavigationBarItem(
          backgroundColor: Color(0xFF020835),
          icon: Column(
            children: [
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                icon: _currentIndex == 0
                    ? const Image(
                  image: AssetImage('assets/images/navbar/home_3.png'),
                  width: 50.0,
                  height: 50.0,
                )
                    : const Image(
                  image: AssetImage('assets/images/navbar/home_1.png'),
                  width: 50.0,
                  height: 50.0,
                ),
              ),
              if(_currentIndex == 0)
                const Text(
                  'Home',
                  style: TextStyle(
                    color: Color(0xFF00C5D4),
                    fontFamily: 'FilsonProRegular',
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          label: '',
        ),
        // BottomNavigationBarItem(
        //   backgroundColor: Color(0xFF020835),
        //   icon: Column(
        //     children: [
        //       GestureDetector(
        //         onTap: () {
        //           setState(() {
        //             _currentIndex = 1;
        //           });
        //           Timer(Duration(milliseconds: 100), () {
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(builder: (context) => EarnScreen(currentIndex: _currentIndex)),
        //             );
        //           });
        //         },
        //         child: _currentIndex == 1
        //             ? const Image(
        //           image: AssetImage('assets/images/navbar/earn3.png'),
        //           width: 100.0,
        //           height: 35,
        //         )
        //             : const Image(
        //           image: AssetImage('assets/images/navbar/earn1.png'),
        //           width: 100.0,
        //           height: 35,
        //         ),
        //       ),
        //       if(_currentIndex == 1)
        //         const Text(
        //           'Earn',
        //           style: TextStyle(
        //             color: Color(0xFF00C5D4),
        //             fontFamily: 'FilsonProRegular',
        //             fontSize: 12,
        //           ),
        //         ),
        //     ],
        //   ),
        //   label: '',
        // ),
        BottomNavigationBarItem(
          backgroundColor: Color(0xFF020835),
          icon: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                  Timer(Duration(milliseconds: 100), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SongHomeScreen()),
                    );
                  });
                },
                child: _currentIndex == 1
                    ? Transform.scale(
                  scale: 1.2, // Increase the scale factor as desired
                  child: const Image(
                    image: AssetImage('assets/images/navbar/sing_now_btn.png'),
                    width: 50.0,
                    height: 50.0,
                  ),
                )
                    : const Image(
                  image: AssetImage('assets/images/navbar/sing_now_btn.png'),
                  width: 50.0,
                  height: 50.0,
                ),
              ),
            ],
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          backgroundColor: Color(0xFF020835),
          icon: Column(
            children: [
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                  Timer(Duration(milliseconds: 100), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen()),
                    );
                  });
                },
                icon: _currentIndex == 2
                    ? const Image(
                  image: AssetImage('assets/images/navbar/chats_3.png'),
                  width: 100.0,
                  height: 35,
                )
                    : const Image(
                  image: AssetImage('assets/images/navbar/Chats1.png'),
                  width: 100.0,
                  height: 35,
                ),
              ),
              if(_currentIndex == 2)
                const Text(
                  'Chat',
                  style: TextStyle(
                    color: Color(0xFF00C5D4),
                    fontFamily: 'FilsonProRegular',
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          backgroundColor: Color(0xFF020835),
          icon: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 3;
                  });
                  Timer(Duration(milliseconds: 100), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen(currentIndex: _currentIndex)),
                    );
                  });
                },
                child: _currentIndex == 3
                    ? const Image(
                  image: AssetImage('assets/images/navbar/profile_3.png'),
                  width: 50.0,
                  height: 35,
                )
                    : const Image(
                  image: AssetImage('assets/images/navbar/profile_1.png'),
                  width: 50.0,
                  height: 35,
                ),
              ),
              if(_currentIndex == 3)
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Color(0xFF00C5D4),
                    fontFamily: 'FilsonProRegular',
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          label: '',
        ),
      ],
    );
  }
}

