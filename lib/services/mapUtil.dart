import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import 'gpsUtil.dart';

class MapUtil {
  /// 苹果地图
  static Future<bool> gotoAppleMap(longitude, latitude) async {
    List<num> list = GpsUtil.bd09ToGcj02(latitude, longitude);
    var url = 'http://maps.apple.com/?daddr=${list[0]},${list[1]}';
    url = Uri.encodeFull(url);
    bool canLaunchUrl = await canLaunch(url);
    if (!canLaunchUrl) {
      return false;
    }
    await launch(url);
    return true;
  }

  /// 高德地图
  static Future<bool> gotoGaoDeMap(longitude, latitude) async {
    List<num> list = GpsUtil.bd09ToGcj02(latitude, longitude);
    var url =
        '${Platform.isAndroid ? 'android' : 'ios'}amap://navi?sourceApplication=amap&lat=${list[0]}&lon=${list[1]}&dev=0&style=2';
    url = Uri.encodeFull(url);
    bool canLaunchUrl = await canLaunch(url);
    if (!canLaunchUrl) {
      return false;
    }
    await launch(url);
    return true;
  }

  /// 百度地图
  static Future<bool> gotoBaiduMap(longitude, latitude) async {
    var url =
        'baidumap://map/direction?destination=$latitude,$longitude&coord_type=bd09ll&mode=driving';
    url = Uri.encodeFull(url);
    bool canLaunchUrl = await canLaunch(url);
    if (!canLaunchUrl) {
      return false;
    }
    await launch(url);
    return canLaunchUrl;
  }

  /// 腾讯地图
  static Future<bool> gotoTencentMap(longitude, latitude) async {
    List<num> list = GpsUtil.bd09ToGcj02(latitude, longitude);
    var url =
        'qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&tocoord=${list[0]},${list[1]}&referer=FN4BZ-6E33P-LFTDB-VRZ4C-NTP3Z-RVFFK';
    bool canLaunchUrl = await canLaunch(url);
    if (!canLaunchUrl) {
      return false;
    }
    await launch(url);
    return canLaunchUrl;
  }
}
