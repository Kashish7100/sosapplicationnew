import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/services/song_services.dart';


// const String baseURL = "http://10.0.2.2:8000/api/";
// const String imageURL = "http://10.0.2.2:8000/images/"; // URL of SOS API
// const String imagePortalURL = "http://10.0.2.2:8003/images/"; //URL of SOS Portal
// const String imageGiftURL = "http://10.0.2.2:8003/images/gift/"; //URL of Gift image in SOS Portal
// const String imageGemsURL = "http://10.0.2.2:8003/images/gems/"; //URL of Gems/Plan image in SOS Portal
// const String imageRankingURL = "http://10.0.2.2:8003/images/ranking/"; //URL of Ranking image in SOS Portal
const String baseURL = "https://api.staronstage.my/api/";
const String imageURL = "https://api.staronstage.my/images/"; // URL of SOS API
const String imagePortalURL = "https://staronstage.my/images/"; //URL of SOS Portal
const String imageGiftURL = "https://staronstage.my/images/gift/"; //URL of Gift image in SOS Portal
const String imageGemsURL = "https://staronstage.my/images/gems/"; //URL of Gems/Plan image in SOS Portal
const String imageRankingURL = "https://staronstage.my/images/ranking/"; //URL of Ranking image in SOS Portal

const Map<String, String> headers = {"Content-Type": "application/json"};

errorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Text(text),
    duration: const Duration(seconds: 1),
  ));
}

// Add to playlist
Future<void> showConfirmationDialog(BuildContext context, String songNo, String tableId, List playlist, int totalGems) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text(
          "Confirm Song Addition",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'FilsonProRegular',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        content: Text(
          "Your gems will be deducted by ${totalGems} if you add this song to the playlist. Do you want to proceed?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontFamily: 'FilsonProRegular',
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'No',
              style: TextStyle(
                color: const Color(0xFF000038),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Material(
            color: const Color(0xFF000038),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                deductGems(context, songNo, tableId, playlist);
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> deductGems(BuildContext context, String songNo, String tableId, List playlist) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var user = jsonDecode(preferences.getString('user').toString());
    int userId = user['id'];

    if (songNo != null && songNo != 0 && tableId != null && userId != 0) {
      http.Response response = await SongServices.deductUserGems(userId);

      if (response.statusCode == 200) {
        addToPlaylist(context, songNo, tableId, playlist);
      } else {
        print('Failed to add song to playlist');
        Fluttertoast.showToast(msg: "Oops! Looks like you're running low on gems. Please top up your gems to add the song to the playlist.");
      }
    } else {
      errorSnackBar(context, 'Error add to playlist!');
    }
  } catch (e) {
    // print(e.toString());
    Fluttertoast.showToast(msg: e.toString());
  }
}

Future<void> addToPlaylist(BuildContext context, String songNo, String tableId, List playlist) async {
  try {
    if (songNo != null && songNo != 0 && tableId != null) {
      http.Response response = await SongServices.addSongToPlaylist(songNo, tableId);
      Map responseMap = jsonDecode(response.body);

      if (responseMap['Status'] == true) {
        Fluttertoast.showToast(msg: 'Successfully add song to playlist!');
        playlist = responseMap['SongList'];

        if (playlist.isNotEmpty) {
          int songID = playlist[0]['SongID'];
          String songNo = playlist[0]['SongNo'];
          String tableUniqueKey = tableId;
          int tableSongID = playlist[0]['TableSongID'];

          await storeLiveSession(context, songID, songNo, tableUniqueKey, tableSongID);
        }

      } else {
        print('Failed to add song to playlist');
      }
    } else {
      errorSnackBar(context, 'Error add to playlist!');
    }
  } catch (e) {
    // print(e.toString());
    Fluttertoast.showToast(msg: e.toString());
  }
}

// Store live session data
Future<void> storeLiveSession(BuildContext context, int songID, String songNo, String tableUniqueKey, int tableSongID) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var user = jsonDecode(preferences.getString('user').toString());
    int _id = user['id'];

    if (_id != null && _id != 0 && songID != 0 && songNo != '' && tableUniqueKey != '' && tableSongID != 0) {
      http.Response response = await SongServices.storeLiveSession(_id, songID, songNo, tableUniqueKey, tableSongID);
      Map responseMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Live session stored!');
      } else {
        errorSnackBar(context, responseMap.values.first);
      }
    } else {
      errorSnackBar(context, 'Error play songs!');
    }
  } catch (e) {
    print(e.toString());
    Fluttertoast.showToast(msg: e.toString());
  }
}
