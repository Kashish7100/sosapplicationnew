import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vsing/services/globals.dart';

class SongServices {
  static Future<http.Response> storeLiveSession(int userId, int songID, String songNo, String tableUniqueKey, int tableSongID) async
  {
    try {
      Map data = {
        "user_id": userId,
        "songID": songID,
        "songNo": songNo,
        "tableUniqueKey": tableUniqueKey,
        "tableSongID": tableSongID,
      };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + 'liveSinger/storeLiveSession/${userId}');
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

  static Future<http.Response> removeLiveSession(int tableSongID) async
  {
    try {
      var url = Uri.parse(baseURL + 'liveSinger/destroyLiveSession/${tableSongID}');
      http.Response response = await http.post(
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

  static Future<http.Response> removeAllLiveSession(String tableId) async
  {
    try {
      Map data = {
        "tableUniqueKey": tableId,
      };
      var body = json.encode(data);

      var url = Uri.parse(baseURL + 'liveSinger/destroyAllLiveSession');
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

  static Future<http.Response> getNewSongData(String searchText) async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getNewSongData');

      url = Uri.http(url.authority, url.path, {'searchText': searchText});

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

  static Future<http.Response> getHitSongData(String searchText) async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getHitSongData');

      url = Uri.http(url.authority, url.path, {'searchText': searchText});

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

  static Future<http.Response> getCategoryData() async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getCategoryData');
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

  static Future<http.Response> getCategorySongData(categoryId, String searchText) async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getCategorySongData/${categoryId}');

      url = Uri.http(url.authority, url.path, {'searchText': searchText});

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

  static Future<http.Response> getSingerSongData(singerNo, String searchText) async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getSingerSongData/${singerNo}');

      url = Uri.http(url.authority, url.path, {'searchText': searchText});

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

  static Future<http.Response> getSingerData(id, String searchText) async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getSingerData/${id}');

      url = Uri.http(url.authority, url.path, {'searchText': searchText});

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

  static Future<http.Response> getLanguageData() async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getLanguageData');
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

  static Future<http.Response> getLanguageSongData(languageId, String searchText) async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getLanguageSongData/${languageId}');
      url = Uri.http(url.authority, url.path, {'searchText': searchText});

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

  static Future<http.Response> getPlaylistData(String tableId) async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getPlaylistData/${tableId}');
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

  //  Add song to playlist
  static Future<http.Response> addSongToPlaylist(String SongNo, String tableId) async
  {
  try {
      var url = Uri.parse(baseURL + 'externalApi/addSongToPlaylist/${SongNo}');
      url = Uri.http(url.authority, url.path, {'tableId': tableId});

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

  //  Remove song from playlist
  static Future<http.Response> removeSongFromPlaylist(int TableSongID, String tableId) async
  {
    try {
      var url = Uri.parse(baseURL + 'externalApi/removeSongFromPlaylist/${TableSongID}');
      url = Uri.http(url.authority, url.path, {'tableId': tableId});

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

  //  Clear playlist
  static Future<http.Response> clearPlaylist(String tableId) async
  {
    try {
      var url = Uri.parse(baseURL + 'externalApi/clearPlaylist');
      url = Uri.http(url.authority, url.path, {'tableId': tableId});

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

  static Future<http.Response> getEntirePlaylistData(String tableId) async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getEntirePlaylistData');
      url = Uri.http(url.authority, url.path, {'tableId': tableId});

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

  static Future<http.Response> getCurrentPlayerData(String tableId) async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getCurrentPlayerData');
      url = Uri.http(url.authority, url.path, {'tableId': tableId});

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

  static Future<http.Response> getCurrentLiveSingerData() async {
    try {
      var url = Uri.parse(baseURL + 'externalApi/getCurrentLiveSingerData');
      url = Uri.http(url.authority, url.path);

      http.Response response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        print('Error message: ${response.body}');
        return http.Response('Error', 500);
      }
    } catch (e) {
      return http.Response('Error', 500);
    }
  }

  static Future<http.Response> getSongPriceData() async {
    try {
      var url = Uri.parse(baseURL + 'songPrice/index');
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

  static Future<http.Response> deductUserGems(int userId) async
  {
    try {
      var url = Uri.parse(baseURL + 'songPrice/deductGems/${userId}');
      http.Response response = await http.post(
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