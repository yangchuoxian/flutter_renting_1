import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/services/http.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class Util {
  // 由于ios中某些ssl证书域名被污染导致app卡顿，网络加载速度太慢，所以针对iOS设备，将https替换为http
  // 同样，在加载网络详情页时，因为存在七牛上的图片是用的http协议，所以也需要替换成http
  static String replaceHTTPProtocol(String url) {
    if (url.contains(baseURL) && url.contains("https://")) {
      url = url.replaceFirst("https://", "http://");
    }
    return url;
  }

  ///大陆手机号码11位数，匹配格式：前三位固定格式+后8位任意数
  /// 此方法中前三位格式有：
  /// 13+任意数 * 15+除4的任意数 * 18+除1和4的任意数 * 17+除9的任意数 * 147
  static bool isChinaPhoneLegal(String str) {	
	  return new RegExp('^1([38][0-9]|4[579]|5[^4]|6[6]|7[0-9]|9[189])\\d{8}\$').hasMatch(str);
  }

  static bool isPasswordValid(String p) {
    if (p.length >= 6 && p.length <= 20) {
      return true;
    }
    return false;
  }

  static bool isValueValid(dynamic v) {
    if (v != null && v != '') {
      return true;
    }
    return false;
  }

  void loseFocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  SnackBar failureSnackBar(String content) {
    return SnackBar(
      backgroundColor: colorFailure,
      content: Text(content, textAlign: TextAlign.center),
      elevation: 0.0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(circularBorderRadius),
        ),
      ),
    );
  }

  SnackBar successSnackBar(String content) {
    return SnackBar(
      backgroundColor: colorSuccess,
      content: Text(content, textAlign: TextAlign.center),
      elevation: 0.0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(circularBorderRadius),
        ),
      ),
    );
  }

  static String hidePhone(String phoneNumber) {
    return phoneNumber.substring(0, 3) + '****' + phoneNumber.substring(7);
  }

  static String hideIdNumber(String idNumber) {
    return idNumber.substring(0, 2) +
        '****' +
        idNumber.substring(idNumber.length - 4);
  }

  static String hideRealName(String realname) {
    var len = realname.length;
    var hider = '**';
    if (len == 2) {
      hider = '*';
    }
    return realname.substring(0, 1) + hider;
  }

  static Future<http.StreamedResponse> uploadFile(
      File file, String url, Map<String, String> params) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files
        .add(await http.MultipartFile.fromPath('uploadAvatar', file.path));
    params.forEach((key, value) {
      request.fields[key] = value;
    });
    var res = await request.send();
    return res;
  }

  static setAuthInfo(String loginToken, String phone, String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginToken', loginToken);
    await prefs.setString('phone', phone);
    await prefs.setString('uuid', uuid);
  }

  static submitRegistrationID(String registrationID, String loginToken, String userUUID) async {
    if (registrationID != '') {
      try {
        await HTTP.post('$baseURL$apiRegisterJPushRegistrationID', {
          'registrationID': registrationID,
          'loginToken': loginToken,
          'uuid': userUUID,
        });
      } catch (err) {
      }
    }
  }

  logout(AuthStore aStore) async {
    final prefs = await SharedPreferences.getInstance();
    aStore.clearLoggedInUser();
    aStore.setEnteredPhone('');
    aStore.setEnteredNewPhone('');
    await prefs.remove('loginToken');
    await prefs.remove('uuid');
    await prefs.remove('phone');
  }

  // 当一段文字太长时，该方法只显示这段文字的前面n个字加上"......"
  showAbbreviatedText(int n, String longText) {
    if (longText.length > n) {
      return '${longText.substring(0, n)}...';
    }
    return longText;
  }

  String getDateStringOfDateTime(DateTime dt) {
    return '${dt.year}年${dt.month}月${dt.day}日';
  }
}
