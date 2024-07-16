import 'dart:convert';

import 'package:flutter/src/widgets/editable_text.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_platform_interface/src/models/payment_intents.dart';
import 'package:vsing/services/globals.dart';

class PlanServices {
  static Future<http.Response> index() async {
    try {
      var url = Uri.parse(baseURL + 'plan/index');
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

  static Future<http.Response> getPlanData(int planId) async {
    try {
      var url = Uri.parse(baseURL + 'plan/getPlanData/${planId}');
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

  static Future<http.Response> storePayment(int planId, String paymentType, String cardNumber, int userId, String referralCode) async
  {
    try {
      Map data = {
        "plan_id": planId,
        "payment_type": paymentType,
        "card_number": cardNumber,
        "user_id": userId,
        "referral_code": referralCode,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'plan/storePayment/${userId}');
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

  static Future<http.Response> processCardPayment(int planId, String paymentType, int userId, String referralCode, String tokenId) async
  {
    try {
      Map data = {
        "plan_id": planId,
        "payment_type": paymentType,
        "user_id": userId,
        "referral_code": referralCode,
        "stripe_token": tokenId,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'plan/processCardPayment/${userId}');
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

  static Future<http.Response> confirmCardPayment(int planId, String paymentType, int userId, String cardNumber, PaymentIntent paymentIntent) async
  {
    try {
      Map data = {
        "plan_id": planId,
        "payment_type": paymentType,
        "user_id": userId,
        "card_number": cardNumber,
        "paymentIntent": paymentIntent,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'plan/confirmPayment/${userId}');
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