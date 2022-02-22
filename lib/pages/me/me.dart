import 'package:flutter/material.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/models/product.model.dart';
import 'package:flutter_renting/models/user.model.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/widgets/bottomTabBar.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/widgets/horizontalLine.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/stores/order.store.dart';

class Me extends StatefulWidget {
  Me();
  @override
  State<StatefulWidget> createState() => _MeState();
}

class _MeState extends State<Me> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // 服务人员的工单数
  int numOfWorkOrders = 0;

  @override
  void initState() {
    super.initState();
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final orderStore = Provider.of<OrderStore>(context, listen: false);
    if (authStore.loggedInUser != null) {
      if (authStore.loggedInUser.role == UserRole.servicePersonnel) {
        getAssignedOrdersForServicePersonnel(orderStore);
      }
    }
  }

  void getAssignedOrdersForServicePersonnel(OrderStore orderStore) async {
    try {
      var resp = await HTTP
          .postWithAuth('$baseURL$apiGetAssignedOrdersForServicePersonnel', {});
      if (resp != null && resp.length > 0) {
        if (mounted) {
          setState(() {
            numOfWorkOrders = resp.length;
          });
        }
        List<Order> workOrders = <Order>[];
        for (var o in resp) {
          var order = Order.fromJson(o);
          order.productData = Product.fromJson(o['productData'][0]);
          workOrders.add(order);
        }
        orderStore.setWorkOrders(workOrders);
      } else {
        if (mounted) {
          setState(() {
            numOfWorkOrders = 0;
          });
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
  }

  Future<dynamic> _getUnreadMessagesForUser() async {
    return HTTP.postWithAuth('$baseURL$apiCountUnreadMessages', {});
  }

  // 显示服务人员专属的选项
  Widget showServicePersonnelEntry(AuthStore authStore, OrderStore orderStore) {
    User loggedInUser = authStore.loggedInUser;
    if (loggedInUser == null) {
      return Container();
    }
    if (loggedInUser.role == UserRole.servicePersonnel) {
      return GestureDetector(
        child: Container(
          padding: const EdgeInsets.only(top: padding16, bottom: padding16),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(
              left: padding32,
              right: padding32,
            ),
            child: Row(
              children: <Widget>[
                ImageView(
                  height: 24,
                  width: 24,
                  uri: 'assets/icons/work_list.png',
                  imageType: ImageType.asset,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: padding32),
                  child: Text(
                    '我的工单',
                    style: TextStyle(
                      fontSize: subtitleTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                numOfWorkOrders > 0
                    ? Container(
                        padding: EdgeInsets.all(4),
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints:
                            BoxConstraints(minWidth: 24, minHeight: 24),
                        child: Text(
                          '$numOfWorkOrders',
                          style: TextStyle(
                              color: Colors.white, fontSize: bodyTextSize),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),
                Icon(RentingApp.chevron_right, color: Colors.black54),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, RouteWorkOrders).then((_) {
            getAssignedOrdersForServicePersonnel(orderStore);
          });
        },
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final navigationStore = Provider.of<NavigationStore>(context);
    final orderStore = Provider.of<OrderStore>(context);
    // 在此处先检查用户登录没有，没有登录的话跳转到登录界面
    if (authStore.loggedInUser == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamedAndRemoveUntil(
            context, RouteEnterPhone, (route) => false);
      });
      return Scaffold(
        appBar: TitleTopBar(title: '', canGoBack: false, actionButtons: null),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;

    // retrieve user avatar from authStore
    var showAvatar = () {
      if (authStore.loggedInUser != null) {
        if (authStore.loggedInUser.headImgURL != '') {
          return ImageView(
            width: largeAvatar,
            height: largeAvatar,
            uri: authStore.loggedInUser.headImgURL,
            imageType: ImageType.network,
          );
        }
      }
      return Container(
        decoration: BoxDecoration(
          color: colorDarkGrey,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ImageView(
            width: largeAvatar,
            height: largeAvatar,
            uri: 'assets/images/placeholder.png',
            imageType: ImageType.asset,
          ),
        ),
      );
    };
    var listView = Observer(
      builder: (_) => ListView(
        children: <Widget>[
          Container(
            height: 82.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/me_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: ListTile(
                leading: showAvatar(),
                title: (authStore.loggedInUser != null &&
                        authStore.loggedInUser.phone != null)
                    ? Text(
                        Util.hidePhone(authStore.loggedInUser.phone),
                        style: TextStyle(color: Colors.white),
                      )
                    : Text(''),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: padding24, left: padding16, right: padding16),
            child: ListTile(
              leading: ImageView(
                  width: 24,
                  height: 24,
                  uri: 'assets/icons/customer_service.png',
                  imageType: ImageType.asset),
              title: Text('客服与帮助'),
              trailing: Icon(RentingApp.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, RouteFAQ);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: padding16, right: padding16),
            child: ListTile(
              leading: ImageView(
                  width: 24,
                  height: 24,
                  uri: 'assets/icons/questionnaire.png',
                  imageType: ImageType.asset),
              title: Text('意见反馈'),
              trailing: Icon(RentingApp.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, RouteFeedback);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: padding16, bottom: padding16),
            child: CustomPaint(
              size: Size(screenWidth, 0),
              painter: HorizontalLine(
                  width: screenWidth,
                  horizontalOffset: padding16,
                  topOffset: 0),
            ),
          ),
          showServicePersonnelEntry(authStore, orderStore),
          Padding(
            padding: const EdgeInsets.only(
              left: padding16,
              right: padding16,
            ),
            child: ListTile(
              leading: ImageView(
                  width: 24,
                  height: 24,
                  uri: 'assets/icons/setting.png',
                  imageType: ImageType.asset),
              title: Text('个人设置'),
              trailing: Icon(RentingApp.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, RouteUserSettings);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: padding16, right: padding16),
            child: ListTile(
              leading: ImageView(
                  width: 24,
                  height: 24,
                  uri: 'assets/icons/id_card.png',
                  imageType: ImageType.asset),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('身份认证'),
                  // check whether user id has been verified
                  (authStore.loggedInUser != null &&
                          authStore.loggedInUser.idNumber != "" &&
                          authStore.loggedInUser.idNumber != null)
                      ? Text('')
                      : Text(
                          '未认证',
                          style: TextStyle(color: colorFailure),
                        ),
                ],
              ),
              trailing: Icon(RentingApp.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, RouteIdentification);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: padding16, bottom: padding16),
            child: CustomPaint(
              size: Size(screenWidth, 0),
              painter: HorizontalLine(
                width: screenWidth - 2 * padding16,
                horizontalOffset: padding16,
                topOffset: 0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: padding16,
              right: padding16,
            ),
            child: ListTile(
              leading: ImageView(
                  width: 24,
                  height: 24,
                  uri: 'assets/icons/law_file.png',
                  imageType: ImageType.asset),
              title: Text('用户协议'),
              trailing: Icon(RentingApp.chevron_right),
              onTap: () {
                navigationStore.selectAgreementRelatedNavigation(
                    articleTypeUserAgreement, false, '');
                Navigator.pushNamed(context, RouteAgreement);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: padding16,
              right: padding16,
            ),
            child: ListTile(
              leading: ImageView(
                  width: 24,
                  height: 24,
                  uri: 'assets/icons/suitcase.png',
                  imageType: ImageType.asset),
              title: Text('服务政策'),
              trailing: Icon(RentingApp.chevron_right),
              onTap: () {
                navigationStore.selectAgreementRelatedNavigation(
                    articleTypeServiceAgreement, false, '');
                Navigator.pushNamed(context, RouteAgreement);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: padding16,
              right: padding16,
            ),
            child: ListTile(
              leading: ImageView(
                  width: 24,
                  height: 24,
                  uri: 'assets/icons/article.png',
                  imageType: ImageType.asset),
              title: Text('租赁协议'),
              trailing: Icon(RentingApp.chevron_right),
              onTap: () {
                navigationStore.selectAgreementRelatedNavigation(
                    articleTypeRentAgreement, false, '');
                Navigator.pushNamed(context, RouteAgreement);
              },
            ),
          ),
        ],
      ),
    );
    return FutureBuilder<dynamic>(
      future: _getUnreadMessagesForUser(),
      builder: (context, snapshot) {
        Positioned badge;
        var actionButtons;
        int numOfUnreadMessages = 0;
        if (snapshot.hasData) {
          numOfUnreadMessages = int.parse(snapshot.data['unreadCount']);
        } else {
          numOfUnreadMessages = 0;
        }
        if (numOfUnreadMessages > 0) {
          badge = Positioned(
            right: 0,
            top: padding16,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: new BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: BoxConstraints(minWidth: 24, minHeight: 24),
              child: Text(
                '$numOfUnreadMessages',
                style: TextStyle(color: Colors.white, fontSize: bodyTextSize),
                textAlign: TextAlign.center,
              ),
            ),
          );
          actionButtons = <Widget>[
            new Stack(
              children: <Widget>[
                IconButton(
                  icon: Icon(RentingApp.mail),
                  onPressed: () {
                    Navigator.pushNamed(context, RouteMessages);
                  },
                ),
                badge,
              ],
            ),
          ];
        } else {
          actionButtons = <Widget>[
            IconButton(
                icon: Icon(RentingApp.mail),
                onPressed: () {
                  Navigator.pushNamed(context, RouteMessages);
                }),
          ];
        }
        return Scaffold(
          key: _scaffoldKey,
          appBar: TitleTopBar(
            title: '',
            canGoBack: false,
            actionButtons: actionButtons,
          ),
          body: Container(
            color: Colors.white,
            child: listView,
          ),
          bottomNavigationBar: BottomTabBar(),
        );
      },
    );
  }
}
