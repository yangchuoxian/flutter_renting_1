import 'package:flutter_renting/services/util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HTTP {
  static Future<dynamic> get(String url) async {
    url = Util.replaceHTTPProtocol(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      var errorResp = json.decode(response.body)['errorMessage'];
      throw Exception(errorResp);
    }
  }

  static Future<dynamic> post(String url, dynamic contentToPost) async {
    url = Util.replaceHTTPProtocol(url);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(contentToPost),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      var errorResp = json.decode(response.body)['errorMessage'];
      throw Exception(errorResp);
    }
  }

  static Future<dynamic> postWithAuth(String url, dynamic contentToPost) async {
    url = Util.replaceHTTPProtocol(url);
    final prefs = await SharedPreferences.getInstance();
    contentToPost['loginToken'] = prefs.getString('loginToken');
    contentToPost['uuid'] = prefs.getString('uuid');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(contentToPost),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      var errorResp = json.decode(response.body)['errorMessage'];
      throw Exception(errorResp);
    }
  }
}
