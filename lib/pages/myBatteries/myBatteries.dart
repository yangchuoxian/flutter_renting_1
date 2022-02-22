import 'package:flutter/material.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/widgets/bottomTabBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/models/product.model.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/widgets/emptyList.dart';
import 'package:flutter_renting/widgets/loading.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';

class MyBatteries extends StatefulWidget {
  MyBatteries();
  @override
  State<StatefulWidget> createState() => _MyBatteriesState();
}

class _MyBatteriesState extends State<MyBatteries> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int page = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();
  List<Order> _orders = <Order>[];

  void _loadOrders() async {
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }
    try {
      var resp = await HTTP.postWithAuth('$baseURL$apiGetOrders', {
        'type': '$orderTypeRentProductYearly,$orderTypeRentProductMonthly',
        'status': '$orderStatusOngoing',
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

  Widget showCloseToDueDateWarning(DateTime dueDate) {
    final today = DateTime.now();
    final difference = today.difference(dueDate).inDays;
    if (difference.abs() <= 5) {
      return Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: colorFailure),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('即将到期', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  List<Widget> showBatteries() {
    final orderStore = Provider.of<OrderStore>(context);
    List<Widget> batteriesWidget = <Widget>[];
    for (var order in _orders) {
      String priceText = '';
      String rentType = '';
      if (order.orderType == orderTypeRentProductYearly) {
        priceText = '${order.productData.pricePerYear}元/年';
        rentType = '年租';
      }
      if (order.orderType == orderTypeRentProductMonthly) {
        priceText = '${order.productData.pricePerMonth}元/月';
        rentType = '月租';
      }
      double leftPadding =
          (MediaQuery.of(context).size.width - 2 * blockSize) / 3;
      var rentedBatteryBlock = Padding(
        padding: EdgeInsets.only(left: leftPadding, top: leftPadding),
        child: GestureDetector(
          child: Container(
            width: blockSize,
            height: blockSize,
            decoration: BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ImageView(
                      width: largeAvatar,
                      height: largeAvatar,
                      uri: order.productData.coverImageURL,
                      imageType: ImageType.network,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: padding8, left: padding8, right: padding8),
                      child: Text(
                        order.productData.title,
                        style: TextStyle(
                          fontSize: bodyTextSize,
                        ),
                      ),
                    ),
                    Text(
                      '$rentType - $priceText',
                      style: TextStyle(
                        color: colorDisabled,
                      ),
                    ),
                  ],
                ),
                showCloseToDueDateWarning(order.dueDate),
              ],
            ),
          ),
          onTap: () {
            orderStore.selectOrderForDetails(order);
            Navigator.pushNamed(context, RouteBatteryStatus);
          },
        ),
      );
      batteriesWidget.add(rentedBatteryBlock);
    }
    return batteriesWidget;
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
    var batteriesWidget = showBatteries();
    final navigationStore =
        Provider.of<NavigationStore>(context, listen: false);
    Widget mainContent;
    if (batteriesWidget == null || batteriesWidget.length == 0) {
      mainContent = EmptyList(
        hintText1: '您尚未租赁电池',
        hintText2: '立刻去租赁',
        imageURL: 'assets/images/404.png',
        tabIndex: 0,
        routeToGo: RouteRentShop,
      );
    } else {
      mainContent = ListView(
        controller: _scrollController,
        children: <Widget>[
          Wrap(
            alignment: WrapAlignment.start,
            direction: Axis.horizontal,
            children: batteriesWidget,
          ),
          showLoading(),
        ],
      );
    }
    return Scaffold(
      backgroundColor: colorGeneralBackground,
      key: _scaffoldKey,
      appBar: TitleTopBar(
        title: '我的电池',
        canGoBack: false,
        actionButtons: <Widget>[
          IconButton(
            icon: Icon(RentingApp.add),
            onPressed: () {
              navigationStore.selectTab(0, context);
              Navigator.pushNamed(context, RouteRentShop);
            },
          ),
        ],
      ),
      body: mainContent,
      bottomNavigationBar: BottomTabBar(),
    );
  }
}
