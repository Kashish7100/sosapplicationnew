import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';

class GiftServices {
  static Future<http.Response> storeSendGift(int userId, int giftId) async
  {
    try {
      Map data = {
        "user_id": userId,
        "gift_id": giftId,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'gift/store/${userId}');
      http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print(response.body);
        return response;
      } else if(response.statusCode == 422) {
        return response;
      } else{
        print('Error message: ${response.body}');
        return http.Response('Error', 500);
      }
    } catch (e) {
      return http.Response('Error', 500);
    }
  }
}