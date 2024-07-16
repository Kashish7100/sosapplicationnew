import 'package:flutter/material.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';
// import 'contents/buy_gems_screen.dart';

class EarnScreen extends StatefulWidget {
  const EarnScreen({Key? key, required this.currentIndex}) : super(key: key);

  final int currentIndex;

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: widget.currentIndex),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mainbase.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  SizedBox(height: 10.0),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                    ),
                    child: Container(
                      width: double
                          .infinity, // Set the width to match the available space
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
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: Column(
                          children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Sing To Earn',
                                  style: TextStyle(
                                    color: Colors.white,
                                    height: 2.0,
                                    fontSize: 16.0,
                                    fontFamily: 'FilsonProRegular',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                            Image(
                              image: AssetImage(
                                  'assets/images/earn/total_earn_btn.png'),
                              width: 400.0,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Image(
                                    image:
                                    AssetImage('assets/images/earn/wd_btn.png'),
                                    width: 200.0,
                                    height: 100.0,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(

                                  child: Image(
                                    image: AssetImage(
                                        'assets/images/earn/convert_btn.png'),
                                    width: 200.0,
                                    height: 100.0,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Image(
                                    image: AssetImage(
                                        'assets/images/earn/redeem_btn.png'),
                                    width: 200.0,
                                    height: 100.0,
                                  ),
                                ),
                              ],
                            ),
                            ],
                          ),
                        ),
                    ),
                  ),
                  SizedBox(height: 50.0),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
    );
  }
}
