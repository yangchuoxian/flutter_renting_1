import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:provider/provider.dart';

import '../stores/navigation.store.dart';
import '../constants.dart';
import 'horizontalLine.dart';

import '../renting_app_icons.dart';

class BottomTabBar extends StatelessWidget {
  BottomTabBar();
  DateTime lastPopTime;
  @override
  Widget build(BuildContext context) {

    final navigationStore = Provider.of<NavigationStore>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    var container = Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          CustomPaint(
            size: Size(screenWidth, 0),
            painter: HorizontalLine(width: screenWidth, horizontalOffset: padding16, topOffset: 0),
          ),
          CupertinoTabBar(
            backgroundColor: Colors.white,
            border: Border(
                top: BorderSide(
                    color: Colors.transparent, width: 0)), // hide top border
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(RentingApp.shop), label: '首页'),
              BottomNavigationBarItem(
                  icon: Icon(RentingApp.shopping_bag), label: '订单'),
              BottomNavigationBarItem(
                  icon: Icon(RentingApp.battery), label: '电池'),
              BottomNavigationBarItem(
                  icon: Icon(RentingApp.user), label: '我的'),
            ],
            currentIndex: navigationStore.currentTabIndex,
            activeColor: colorPrimary,
            onTap: (index) {
              navigationStore.selectTab(index, context);
            },
          ),
        ],
      ),
    );
    if (Theme.of(context).platform == TargetPlatform.android) {
      return WillPopScope(
          child: container,
          onWillPop: () async {
            if (lastPopTime == null ||
                DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
              lastPopTime = DateTime.now();
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(Util().successSnackBar('再次按下返回键退出到桌面'));
            } else {
              lastPopTime = DateTime.now();
              // 退出app
              await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }
          });
    } else {
      return container;
    }
  }
  //
  // @override
  // State<StatefulWidget> createState()=>_BottomTabBar();
}

