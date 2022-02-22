import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_renting/widgets/horizontalLine.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:flutter_renting/stores/product.store.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:provider/provider.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:tobias/tobias.dart' as tobias;

class ConfirmRentOrder extends StatefulWidget {
  ConfirmRentOrder();
  @override
  State<StatefulWidget> createState() => _ConfirmRentOrderState();
}

class _ConfirmRentOrderState extends State<ConfirmRentOrder> {
  bool _isMakingPayment = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription _wxPayListener;
  String orderTypeText = '';
  String monthlyTypeText = '';
  String yearlyTypeText = '';
  bool _yearSelected = false;
  bool _monthSelected = false;
  int totalAmountToPay = 0;
  bool _isSubmitting = false;

  final PanelController _pc = PanelController();

  @override
  void initState() {
    super.initState();
    final productStore = Provider.of<ProductStore>(context, listen: false);
    final orderStore = Provider.of<OrderStore>(context, listen: false);
    _wxPayListener = fluwx.weChatResponseEventHandler.listen((res) {
      if (res is fluwx.WeChatPaymentResponse) {
        if (res.isSuccessful) {
          setState(() {
            _isMakingPayment = false;
          });
          // 支付成功
          Navigator.pushNamed(context, RouteSubmitOrderSucceeded);
        } else {
          setState(() {
            _isMakingPayment = false;
          });
          _scaffoldKey.currentState
            ..hideCurrentSnackBar()
            ..showSnackBar(
              Util().failureSnackBar('微信支付失败'),
            );
        }
      }
    });

    yearlyTypeText = '年租 ¥${productStore.selectedProduct.pricePerYear}元/年';
    monthlyTypeText = '月租 ¥${productStore.selectedProduct.pricePerMonth}元/月';
    if (orderStore.newOrder.orderType == orderTypeRentProductYearly) {
      orderTypeText = yearlyTypeText;
      _yearSelected = true;
      _monthSelected = false;
      totalAmountToPay = productStore.selectedProduct.pricePerYear +
          productStore.selectedProduct.generalPrice;
    } else {
      orderTypeText = monthlyTypeText;
      _yearSelected = false;
      _monthSelected = true;
      totalAmountToPay = productStore.selectedProduct.pricePerMonth +
          productStore.selectedProduct.generalPrice;
    }
  }

  @override
  void dispose() {
    if (_wxPayListener != null) {
      _wxPayListener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productStore = Provider.of<ProductStore>(context, listen: false);
    final orderStore = Provider.of<OrderStore>(context, listen: false);

    final double screenWidth = MediaQuery.of(context).size.width;
    var paymentMethodsActionSheet = Container(
      decoration: BoxDecoration(color: Colors.white),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('支付宝支付'),
                ],
              ),
              onTap: _isMakingPayment
                  ? null
                  : () async {
                      var hasAlipayInstalled = await tobias.isAliPayInstalled();
                      if (!hasAlipayInstalled) {
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(Util().failureSnackBar('请先安装支付宝'));
                        return;
                      }
                      setState(() {
                        _isSubmitting = true;
                        _isMakingPayment = true;
                        _pc.close();
                      });
                      try {
                        var resp = await HTTP
                            .postWithAuth('$baseURL$apiCreateOrderAndPay', {
                          'type': '${orderStore.newOrder.orderType}',
                          'relatedProduct':
                              productStore.selectedProduct.productID,
                          'contactName': orderStore.orderAddress.contactName,
                          'phone': orderStore.orderAddress.phone,
                          'location': orderStore.orderAddress.location,
                          'addressID': orderStore.orderAddress.addressID,
                          'paymentMethod': '$paymentAlipay',
                        });
                        var alipayStr = resp
                            .toString()
                            .replaceAll('{payStr: ', '')
                            .replaceAll('}', '');
                        tobias.aliPay(alipayStr).then((value) {
                          setState(() {
                            _isMakingPayment = false;
                          });
                          if (value['resultStatus'] == '9000') {
                            if (json.decode(value['result'])[
                                    'alipay_trade_app_pay_response']['code'] ==
                                '10000') {
                              Navigator.pushNamed(
                                  context, RouteSubmitOrderSucceeded);
                              return;
                            }
                          }
                          _scaffoldKey.currentState
                            ..hideCurrentSnackBar()
                            ..showSnackBar(Util().failureSnackBar('支付宝支付失败'));
                        }).catchError((err) {
                          setState(() {
                            _isMakingPayment = false;
                          });
                          _scaffoldKey.currentState
                            ..hideCurrentSnackBar()
                            ..showSnackBar(Util().failureSnackBar('支付宝支付失败'));
                        });
                      } catch (e) {
                        setState(() {
                          _isMakingPayment = false;
                        });
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            Util().failureSnackBar(
                              e.toString().replaceAll('Exception: ', ''),
                            ),
                          );
                      }
                      setState(() {
                        _isSubmitting = false;
                      });
                    },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('微信支付'),
                ],
              ),
              onTap: _isMakingPayment
                  ? null
                  : () async {
                      var hasWechatInstalled = await fluwx.isWeChatInstalled;
                      if (!hasWechatInstalled) {
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(Util().failureSnackBar('请先安装微信'));
                        _pc.close();
                        return;
                      }
                      setState(() {
                        _isSubmitting = true;
                        _isMakingPayment = true;
                        _pc.close();
                      });
                      try {
                        var wxUnifiedOrderResp = await HTTP
                            .postWithAuth('$baseURL$apiCreateOrderAndPay', {
                          'type': '${orderStore.newOrder.orderType}',
                          'relatedProduct':
                              productStore.selectedProduct.productID,
                          'contactName': orderStore.orderAddress.contactName,
                          'phone': orderStore.orderAddress.phone,
                          'location': orderStore.orderAddress.location,
                          'addressID': orderStore.orderAddress.addressID,
                          'paymentMethod': '$paymentWechatPay',
                        });
                        fluwx.payWithWeChat(
                          appId: wxUnifiedOrderResp['appid'].toString(),
                          partnerId: wxUnifiedOrderResp['partnerid'].toString(),
                          prepayId: wxUnifiedOrderResp['prepayid'].toString(),
                          packageValue:
                              wxUnifiedOrderResp['package'].toString(),
                          nonceStr: wxUnifiedOrderResp['noncestr'].toString(),
                          timeStamp: int.parse(
                              wxUnifiedOrderResp['timestamp'].toString()),
                          sign: wxUnifiedOrderResp['sign'].toString(),
                        );
                      } catch (e) {
                        setState(() {
                          _isMakingPayment = false;
                        });
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            Util().failureSnackBar(
                              e.toString().replaceAll('Exception: ', ''),
                            ),
                          );
                      }
                      setState(() {
                        _isSubmitting = false;
                      });
                    },
            ),
            CustomPaint(
              size: Size(screenWidth, 0),
              painter: HorizontalLine(
                width: screenWidth,
                horizontalOffset: padding16,
                topOffset: 0,
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('取消'),
                ],
              ),
              onTap: () {
                _pc.close();
              },
            ),
          ],
        ),
      ),
    );

    return Material(
      child: SlidingUpPanel(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        renderPanelSheet: false,
        controller: _pc,
        maxHeight: 3 * defaultListTileHeight,
        minHeight: 0,
        backdropEnabled: true,
        panel: paymentMethodsActionSheet,
        body: Scaffold(
          backgroundColor: colorGeneralBackground,
          key: _scaffoldKey,
          appBar: TitleTopBar(
            title: '确认订单',
            canGoBack: true,
            actionButtons: <Widget>[],
          ),
          body: Padding(
            padding: EdgeInsets.all(padding16),
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: EdgeInsets.all(padding16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ImageView(
                          width: largeAvatar,
                          height: largeAvatar,
                          uri: productStore.selectedProduct.coverImageURL,
                          imageType: ImageType.network,
                        ),
                        Text(
                          productStore.selectedProduct.title,
                          style: TextStyle(
                            fontSize: bodyTextSize,
                            color: colorDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: padding32),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Theme(
                      data: ThemeData(accentColor: colorPrimary),
                      child: ExpansionTile(
                        title: Text(
                          '$orderTypeText',
                          style: TextStyle(
                            color: colorDisabled,
                          ),
                        ),
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: padding16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Checkbox(
                                  activeColor: colorPrimary,
                                  value: _yearSelected,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _yearSelected = value;
                                      _monthSelected = !value;
                                      orderTypeText = yearlyTypeText;
                                      totalAmountToPay = productStore
                                              .selectedProduct.generalPrice +
                                          productStore
                                              .selectedProduct.pricePerYear;
                                    });
                                  },
                                ),
                                Text('$yearlyTypeText'),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: padding16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Checkbox(
                                  activeColor: colorPrimary,
                                  value: _monthSelected,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _monthSelected = value;
                                      _yearSelected = !value;
                                      orderTypeText = monthlyTypeText;
                                      totalAmountToPay = productStore
                                              .selectedProduct.generalPrice +
                                          productStore
                                              .selectedProduct.pricePerMonth;
                                    });
                                  },
                                ),
                                Text('$monthlyTypeText'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: padding16),
                  child: Container(
                    padding: const EdgeInsets.all(padding16),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ImageView(
                          width: 24,
                          height: 24,
                          uri: 'assets/icons/location_on.png',
                          imageType: ImageType.asset,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: padding16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${orderStore.orderAddress.location}',
                                  style: TextStyle(
                                    fontSize: titleTextSize,
                                    color: colorDisabled,
                                  ),
                                ),
                                Text(
                                  '${orderStore.orderAddress.contactName}/${orderStore.orderAddress.phone}',
                                  style: TextStyle(color: colorDarkGrey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: padding16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '+押金 ¥${productStore.selectedProduct.generalPrice}元，共计 ¥$totalAmountToPay元',
                        style: TextStyle(color: colorDisabled),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Container()),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    disabledColor: colorDisabled,
                    color: colorPrimary,
                    child: Text('支付'),
                    borderRadius: BorderRadius.zero,
                    onPressed: (!_isSubmitting)
                        ? () {
                            _pc.open();
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
