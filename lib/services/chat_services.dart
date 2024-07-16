import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';

class ChatServices {
  static Future<http.Response> index(int liveSingerId) async {
    try {
      var url = Uri.parse(baseURL + 'comment/index/${liveSingerId}');
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

  static Future<http.Response> store(int id, int liveSingerId, String message) async
  {
    try {
      Map data = {
        "user_id": id,
        "live_singer_id": liveSingerId,
        "message": message,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'comment/store/${id}');
      http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
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