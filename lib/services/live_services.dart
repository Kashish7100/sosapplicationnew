import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';

class LiveServices {
  static Future<http.Response> getLiveSingerData(int currentSongID, String currentSongNo, String currentTableUniqueKey, int currentTableSongID) async {
    try {
      var url = Uri.parse(baseURL + 'liveSinger/getLiveSinger');
      var params = {
        'currentSongID': currentSongID.toString(),
        'currentSongNo': currentSongNo,
        'currentTableUniqueKey': currentTableUniqueKey,
        'currentTableSongID': currentTableSongID.toString(),
      };

      url = url.replace(queryParameters: params);

      http.Response response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        print(response.body);
        return response;
      } else {
        print('Error message: ${response.body}');
        return http.Response('Error', 500);
      }
    } catch (e) {
      return http.Response('Error', 500);
    }
  }
}