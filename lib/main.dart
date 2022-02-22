import 'dart:io' show Platform, exit;
import 'package:janalytics/janalytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bmfbase/BaiduMap/bmfmap_base.dart'
    show BMFMapSDK, BMF_COORD_TYPE;
import 'package:flutter/material.dart';
import 'package:flutter_renting/pages/splashScreen.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:provider/provider.dart';

import 'stores/navigation.store.dart';
import 'stores/message.store.dart';
import 'stores/auth.store.dart';
import 'stores/address.store.dart';
import 'stores/product.store.dart';
import 'routes.dart';
import 'constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 极光统计的崩溃统计
  Janalytics janalytics = new Janalytics();
  janalytics.setup(
    appKey: jpushAppKey,
    channel: "developer-default",
  );
  janalytics.initCrashHandler();
  if (Platform.isIOS) {
    // 注意：android的api key在AndroidManifest.xml中设置，ios和android的api key不一样
    BMFMapSDK.setApiKeyAndCoordType(baiduIOSAPIKey, BMF_COORD_TYPE.BD09LL);
  } else if (Platform.isAndroid) {
    BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
  }
  // 全局错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    HTTP.post('$baseURL$apiReportBug', {
      'summary': details.summary.toString(),
      'stacktrace': details.stack.toString(),
    }).catchError((onError) {});
    if (kReleaseMode) {
      exit(1);
    }
  };
  runApp(MultiProvider(
    providers: [
      Provider<NavigationStore>(create: (_) => NavigationStore()),
      Provider<MessageStore>(create: (_) => MessageStore()),
      Provider<AuthStore>(create: (_) => AuthStore()),
      Provider<AddressStore>(create: (_) => AddressStore()),
      Provider<ProductStore>(create: (_) => ProductStore()),
      Provider<OrderStore>(create: (_) => OrderStore()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      title: '万租',
      onGenerateRoute: CustomRouter.generateRoute,
      theme: ThemeData(
        primaryColor: colorPrimary,
        // accentColor 用来设置在按键激活时，或者expansion tile展开时的文字颜色
        // splashColor 用来显示按键时的动画颜色，设为transparent则不显示按键动画
        // splashColor: Colors.transparent,
      ),
    );
  }
}
