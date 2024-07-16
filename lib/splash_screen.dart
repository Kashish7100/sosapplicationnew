import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/home_screen.dart';
import 'package:vsing/main.dart';
import 'package:vsing/services/auth_services.dart';
import 'package:vsing/services/logout_services.dart'; // Import the login page from the auth folder

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  void navigateToLogin() async {
    // Wait for 2 seconds to simulate a splash screen delay
    await Future.delayed(const Duration(seconds: 3));

    // Navigate to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LandingPage(),
      ),
    );
  }

  void _checkIfLoggedIn() async{
    // check if token is there
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if(token!= null){
      setState(() {
        _isLoggedIn = true;
      });
    }

    Future.delayed(Duration(seconds: 2), () {
      if (_isLoggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen(),
          ),
        );
      } else {
        // Navigate to the login page
        navigateToLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/new_landingbase.png'), // Replace with your image path
            fit: BoxFit.fill,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
