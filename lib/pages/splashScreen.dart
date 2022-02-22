import 'dart:io' show Platform;
import 'package:flutter/material.dart';
// ycx!!!!!! 调用原生代码需要用到的依赖
// import 'package:flutter/services.dart';
import 'package:flutter_renting/constants.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'dart:async';

class SplashScreen extends StatefulWidget {
  SplashScreen();

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // 初始化极光推送SDK
    JPush jpush = JPush();
    jpush.setup(
      appKey: jpushAppKey,
      channel: "flutter_channel",
      production: true,
      debug: false, //是否打印debug日志
    );
    jpush.applyPushAuthority(NotificationSettingsIOS(
      sound: true,
      alert: true,
      badge: true,
    ));
    // 清除之前所有该的push notification和badge
    jpush.clearAllNotifications();
    jpush.setBadge(0);
    final authStore = Provider.of<AuthStore>(context, listen: false);
    jpush.getRegistrationID().then((value) {
      authStore.setRegistrationID(value);
    }).catchError((err) {});

    // 获取 iOS 点击推送启动应用的那条通知。
    jpush.getLaunchAppNotification().then((map) {
      // ycx!!!!!! TODO: 在用户点击推送通知时，需要跳转到对应的消息界面
      /*
      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(Util().successSnackBar('获取到了$map'));
      */
    });

    // 初始化微信SDK
    fluwx.registerWxApi(
      appId: wxAppID,
      universalLink: iosUniversalLink,
    );
    checkUserLoginStatus();
  }

  // 在这里做判断，看用户是否已经登录，或登录信息仍然有效，如果是，直接跳转到home page，否则跳转到登陆界面
  void checkUserLoginStatus() async {
    /*
    // ycx!!!!!! 调用原生代码的示例代码
    const platform = const MethodChannel('com.onezu.rentingEverything/wechat');
    platform.setMethodCallHandler((call) {
      if (call.method == 'onWXLoginResp') {
        print('native code call flutter method successfully!');
        print(call.arguments);
      }
      return;
    });
    print('before invoke');
    await platform.invokeMethod('wxLogin');
    print('after invoke');
    // end of ycx!!!!!!
    */

    final authStore = Provider.of<AuthStore>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    String loginToken = prefs.getString('loginToken');
    if (loginToken != '' && loginToken != null) {
      try {
        var resp = await HTTP.post('$baseURL$apiCheckLoginStatus', {
          'uuid': prefs.getString('uuid'),
          'lt': loginToken,
        });
        // loginToken有效，自动登录成功
        authStore.setLoggedInUser(resp);
        startHomePageAfterDelay();
      } catch (e) {
        // loginToken无效，自动登录失败，跳转到登录界面
        startAuthPageAfterDelay();
      }
    } else {
      // 没有loginToken，跳转到登录界面
      startAuthPageAfterDelay();
    }
  }

  startHomePageAfterDelay() async {
    return Timer(Duration(seconds: splashScreenDelay), () {
      Navigator.pushNamed(context, RouteHome);
    });
  }

  startAuthPageAfterDelay() async {
    return Timer(Duration(seconds: splashScreenDelay), () {
      Navigator.pushNamed(context, RouteEnterPhone);
    });
  }

  @override
  Widget build(BuildContext context) {
    var imageURL = 'assets/images/launch@3x.jpg';
    if (Platform.isAndroid) {
      imageURL = 'assets/images/launch_image.jpg';
    }
    return Scaffold(
      key: _scaffoldKey,
      body: Image.asset(
        imageURL,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }
}
