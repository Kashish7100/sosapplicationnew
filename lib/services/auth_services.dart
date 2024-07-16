import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsing/main.dart';
import 'package:vsing/services/globals.dart';


class AuthServices
{
  static Future<http.Response> processSignUp(String name, String email, String phone_number, String password,
      String confirm_password, String base64Image) async
  {
    try {
      Map data = {
        "name": name,
        "email": email,
        "phone_number": phone_number,
        "password": password,
        "confirm_password": confirm_password,
        "image": base64Image,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'signup/store');
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
        return http.Response('Error', 400);
      }
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

  static Future<http.Response> getUserData(userId) async {
    try {
      var url = Uri.parse(baseURL + 'signup/show/${userId}');
      http.Response response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        print(response.body);
        return response;
      } else {
        print('Error message: ${response.body}');
        return response;
      }
    } catch (e) {
      return http.Response('Error', 500);
    }
  }

  static Future<http.Response> verifyOTP(int id, String otpNumber) async
  {
    try {
      Map data = {
        "id": id,
        "otp": otpNumber,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'signup/verifyOTP/${id}');
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
        return response;
      }
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

  // Login using email and password
  static Future<http.Response> login(String email, String password) async
  {
    Map data = {
      "email": email,
      "password": password,
    };
    var body = json.encode(data);
    var url = Uri.parse(baseURL + 'auth/login');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(response.body);
    return response;
  }

  // Login using phone number and otp
  static Future<http.Response> mobileLogin(String formattedPhoneNumber) async
  {
    Map data = {
      "phone_number": formattedPhoneNumber,
    };
    var body = json.encode(data);
    var url = Uri.parse(baseURL + 'auth/mobileLogin');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(response.body);
    return response;
  }

  static Future<http.Response> verifyOTPLogin(int id, String otpNumber) async
  {
    try {
      Map data = {
        "id": id,
        "otp": otpNumber,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'auth/verifyOTP/${id}');
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
        return response;
      }
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

  static Future<http.Response> updateUserProfile(int userId, String name, String email, String phone_number, String base64image) async
  {
    try {
      Map data = {
        "id": userId,
        "name": name,
        "email": email,
        "phone_number": phone_number,
        "image": base64image,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'user/update/${userId}');
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
        return response;
      }
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

  static Future<http.Response> deleteUserProfile(int userId) async
  {
    try {
      Map data = {
        "id": userId,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'user/destroy/${userId}');
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
        return response;
      }
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

  static Future<http.Response> facebookLogin(String accessToken, Map<String, dynamic> userData) async
  {
    try {
      Map data = {
        "access_token": accessToken,
        "email": userData['email'],
        "name": userData['name'],
        "password": userData['id'],
        "image": userData['picture']['data']['url'],
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'login/facebook');
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
        return response;
      }
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

  static Future<http.Response> appleSignUp(String? userIdentifier, String email, String firstName, String lastName) async
  {
    try {
      Map data = {
        "name": firstName,
        "email": email,
        "userIdentifier": userIdentifier,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'signup/apple/store');
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
        return http.Response('Error', 400);
      }
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }
}