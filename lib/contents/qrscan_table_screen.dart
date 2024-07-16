import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/contents/song/home_screen.dart';
import 'package:vsing/home_screen.dart';
import 'package:vsing/navbar/bottom_nav_bar.dart';

class QRScanTableScreen extends StatefulWidget {
  const QRScanTableScreen({Key? key}) : super(key: key);

  @override
  State<QRScanTableScreen> createState() => _QRScanTableScreenState();
}

class _QRScanTableScreenState extends State<QRScanTableScreen> {
  late QRViewController _controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  String scannedData = '';
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    // _storeTableId();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          bottomNavigationBar: BottomNavBar(currentIndex: 0),
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
                          'Scan Table QR Code',
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
                      SliverFillRemaining(
                        child: Column(
                          children: [
                            if(isScanning)
                              Expanded(
                                flex: 5,
                                child: QRView(
                                  key: _qrKey,
                                  onQRViewCreated: _onQRViewCreated,
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  )
              ),

            ],
          ),
        ),
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                HomeScreen()),
          );
          return false;
        }
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
      _controller.scannedDataStream.listen((scanData) {
        setState(() {
          scannedData = scanData.code!;
        });
        // Handle the scanned data as desired
        print('Scanned data: ${scanData.code}');
        _storeTableId(scanData.code!);
      });
    });
  }

  void _storeTableId(String qrCode) async {
    Uri uri = Uri.parse(qrCode);
    String? tableId = uri.queryParameters['tableId'];
    // String? tableId = 'b762-fbb3-5c8d-c36b-8d18';

    if (tableId != null) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('TableID', tableId);
      print('TableID stored in local storage: $tableId');
      _showSuccessPopup(context); // Show success popup when tableId is found
    } else {
      print('No tableId found in the QR code');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR error or table not found. Please scan again!'),
          duration: Duration(seconds: 2), // Adjust duration as needed
        ),
      );
      setState(() {
        isScanning = true; // Resume scanning if no tableId is found
      });
    }
  }


  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Success',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'FilsonProRegular',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have choose your table! Now, get ready to enjoy the karaoke experience!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontFamily: 'FilsonProRegular',
                ),
              ),
              // SizedBox(height: 16),
              // Text(
              //   'Scanned Data:',
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: Colors.grey,
              //     fontFamily: 'FilsonProRegular',
              //   ),
              // ),
              // SizedBox(height: 8,),
              // Text(
              //   scannedData,
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: Colors.grey,
              //     fontFamily: 'FilsonProRegular',
              //   ),
              // ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the popup
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SongHomeScreen()),
                  );
                });
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
