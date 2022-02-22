import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../constants.dart';
part 'navigation.store.g.dart';

class NavigationStore = _NavigationStore with _$NavigationStore;

abstract class _NavigationStore with Store {
  static const List<CustomTab> tabs = CustomTab.values;

  @observable
  int currentTabIndex = tabs.indexOf(CustomTab.Home);

  @observable
  int selectedSidebarIndex = 0;

  @observable
  int selectedAgreementType = 0;

  bool hasNextAfterFinishedReadingAgreement = false;

  String nextRouteAfterFinishedReadingAgreement = '';

  // 为了重复利用serviceLocation页面，在serviceLocation.dart页面针对不同订单有不同显示
  // serviceLocation页面在如下几个地方用到：
  // 1. 租电池
  // 2. 创建服务单
  // 3. 退租
  // 4. 为服务单修改地址
  String serviceLocationPageTitle = '';
  int serviceLocationOrderType = 0;
  ServiceLocationPlaces serviceLocationPlace;
  String serviceLocationSubmitButtonText = '';

  @action
  void selectTab(int index, BuildContext context) {
    currentTabIndex = index;
    switch (tabs[currentTabIndex]) {
      case CustomTab.Home:
        Navigator.pushReplacementNamed(context, RouteHome);
        break;
      case CustomTab.Orders:
        Navigator.pushReplacementNamed(context, RouteRentOrders);
        break;
      case CustomTab.MyBatteries:
        Navigator.pushReplacementNamed(context, RouteMyBatteries);
        break;
      case CustomTab.Me:
        Navigator.pushReplacementNamed(context, RouteMe);
        break;
      default:
    }
  }

  @action
  void selectSidebarEntry(int index) {
    selectedSidebarIndex = index;
  }

  @action
  void selectAgreementRelatedNavigation(
      int agreementType, bool hasNext, String nextRoute) {
    selectedAgreementType = agreementType;
    hasNextAfterFinishedReadingAgreement = hasNext;
    nextRouteAfterFinishedReadingAgreement = nextRoute;
  }

  @action
  void setServiceLocationParameters(ServiceLocationPlaces place,
      String pageTitle, int orderType, String buttonText) {
    serviceLocationPlace = place;
    serviceLocationPageTitle = pageTitle;
    serviceLocationOrderType = orderType;
    serviceLocationSubmitButtonText = buttonText;
  }
}
