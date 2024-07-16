import 'dart:convert';
import 'package:vsing/navbar/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({Key? key}) : super(key: key);

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mainbase.png',
              fit: BoxFit.cover,
            ),
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/profile_page/qr_base.png',
                  width: 400.0,
                  height: 500.0,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/profile_page/qr_example.png',
                  width: 400.0,
                  height: 250.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
