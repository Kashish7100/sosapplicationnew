import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/main.dart';

class LogoutService {
  LogoutService._privateConstructor();
  static final LogoutService _instance = LogoutService._privateConstructor();
  factory LogoutService() {
    return _instance;
  }

  Timer? _logoutTimer;
  final int sessionTimeout = 2700 ; // 1 hour in seconds
  DateTime? _timerStart;

  void startLogoutTimer(BuildContext context) {
    _cancelTimer();
    _timerStart = DateTime.now();
    print('Starting logout timer for $sessionTimeout seconds');

    _logoutTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      final elapsed = DateTime.now().difference(_timerStart!).inSeconds;
      // print('Elapsed time: $elapsed seconds');
      if (elapsed >= sessionTimeout) {
        timer.cancel();
        logout(context);
      }
    });

  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    print('Logging out and clearing preferences');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LandingPage(),
      ),
    );
  }

  void _cancelTimer() {
    if (_logoutTimer != null) {
      print('Cancelling existing timer');
      _logoutTimer!.cancel();
      _logoutTimer = null;
    }
  }

  void dispose() {
    _cancelTimer();
  }
}
