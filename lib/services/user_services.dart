import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';

class UserServices {
  static Future<http.Response> index(int id) async {
    try {
      var url = Uri.parse(baseURL + 'user/index/${id}');
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

  static Future<http.Response> getLiveSingerQueue() async {
    try {
      var url = Uri.parse(baseURL + 'user/getLiveQueue');
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