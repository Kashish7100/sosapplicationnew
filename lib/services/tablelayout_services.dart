import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';
import 'dart:convert';

class TableLayoutServices {
  static Future<http.Response> index() async {
    try {
      var url = Uri.parse(baseURL + 'tableLayout/index');
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

//store data
  static Future<http.Response> storeData(int table_layout_id, id) async {
    try {
      Map<String, dynamic> data = {
        'table_layout_id': table_layout_id,
      };

      var body = json.encode(data);
      var url = Uri.parse('${baseURL}tableLayout/store${id}');
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
        if (response.statusCode == 400) {
          return http.Response(
              'Table layout is already taken by another user.', 400);
        } else {
          return http.Response(
              'You have already selected this table layout.', 500);
        }
      }
    } catch (e) {
      print('Exception: $e');
      return http.Response('An error occurred.', 500);
    }
  }

  static Future<http.Response> getTableData(String tableId) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      var url = Uri.parse(baseURL + 'externalApi/tableData/${tableId}');
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
