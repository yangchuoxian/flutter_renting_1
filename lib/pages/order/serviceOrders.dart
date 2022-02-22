import 'package:flutter/material.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/widgets/emptyList.dart';
import 'package:flutter_renting/widgets/orderBlock.dart';
import 'package:flutter_renting/widgets/tabTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/models/product.model.dart';
import 'package:flutter_renting/widgets/bottomTabBar.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/stores/order.store.dart';

class ServiceOrders extends StatefulWidget {
  ServiceOrders();

  @override
  State<StatefulWidget> createState() => _ServiceOrdersState();
}

class _ServiceOrdersState extends State<ServiceOrders> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedOrderStatus = '全部订单';
  String dropdownValue = '全部订单';
  List<Order> _orders = <Order>[];
  ScrollController _scrollController = ScrollController();
  int page = 0;
  bool _isLoadingMore = false;
  bool _filtered = false;
  bool _hasMore = true;

  void _loadOrders() async {
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }
    try {
      var resp = await HTTP.postWithAuth('$baseURL$apiGetOrders', {
        'type':
            '$orderTypeRoadRescue,$orderTypeFixBattery,$orderTypeBatteryMissing',
        'page': '$page',
      });
      if (resp == null || resp.length == 0) {
        _hasMore = false;
      } else {
        _hasMore = true;
        for (var o in resp) {
          var order = Order.fromJson(o);
          order.productData = Product.fromJson(o['productData'][0]);
          _orders.add(order);
        }
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState
          ..hideCurrentSnackBar()
          ..showSnackBar(Util()
              .failureSnackBar(e.toString().replaceAll('Exception: ', '')));
      });
    }
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Widget showLoading() {
    if (_isLoadingMore) {
      return Loading();
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: padding8, bottom: padding8),
        child: Text(' '),
      );
    }
  }

  List<Widget> showOrders() {
    final orderStore = Provider.of<OrderStore>(context);
    List<Widget> ordersWidget = <Widget>[];
    for (var order in _orders) {
      String statusText = '待安装';
      if (order.orderStatus == orderStatusFinished) {
        statusText = '已完成';
      }
      if (order.orderStatus == orderStatusPaid) {
        statusText = '待安装';
      }
      if (order.orderStatus == orderStatusCanceled) {
        statusText = '已取消';
      }
      if (selectedOrderStatus != '全部订单' && selectedOrderStatus != statusText) {
        continue;
      }
      var serviceOrderBlock = Padding(
        padding: EdgeInsets.only(
          bottom: padding16,
          left: padding16,
          right: padding16,
        ),
        child: GestureDetector(
          child: OrderBlock(
            order: order,
            canTap: true,
          ),
          onTap: () {
            // 显示服务单细节
            orderStore.selectOrderForDetails(order);
            Navigator.pushNamed(context, RouteServiceOrderDetails);
          },
        ),
      );
      ordersWidget.add(serviceOrderBlock);
    }
    return ordersWidget;
  }

  @override
  void initState() {
    super.initState();

    // 如果用户没有登录，不做任何事情，否则从后端获取用户订单
    final authStore = Provider.of<AuthStore>(context, listen: false);
    if (authStore.loggedInUser == null) {
      return;
    }
    _loadOrders();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        if (_hasMore) {
          // listView滚动到了最底部，开始加载更多订单
          page++;
          _loadOrders();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _orders.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ordersWidget = showOrders();
    Widget filterWidget = Padding(
      padding: EdgeInsets.all(padding16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            elevation: 0,
            value: dropdownValue,
            items: <String>['全部订单', '待安装', '已取消', '已完成']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: EdgeInsets.only(left: padding16),
                  child: Text(value),
                ),
              );
            }).toList(),
            icon: Icon(RentingApp.chevron_down),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
                selectedOrderStatus = newValue;
                if (dropdownValue == '全部订单') {
                  _filtered = false;
                } else {
                  _filtered = true;
                }
              });
            },
            isExpanded: true,
            dropdownColor: Colors.white,
          ),
        ),
      ),
    );
    Widget mainContent;
    if (!_filtered && (ordersWidget == null || ordersWidget.length == 0)) {
      mainContent = Expanded(
        child: EmptyList(
          hintText1: '您尚未提交任何服务单',
          hintText2: '立刻开启服务',
          imageURL: 'assets/images/404.png',
          tabIndex: 0,
          routeToGo: RouteServiceShop,
        ),
      );
    } else {
      mainContent = Expanded(
        child: Column(
          children: <Widget>[
            filterWidget,
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: ordersWidget,
              ),
            ),
            showLoading(),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: colorGeneralBackground, 
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TabTopBar(
              entries: <String>['租赁', '服务'],
              routes: <String>[
                RouteRentOrders,
                RouteServiceOrders,
              ],
              selectedIndex: 1,
            ),
            mainContent,
          ],
        ),
      ),
      bottomNavigationBar: BottomTabBar(),
    );
  }
}
