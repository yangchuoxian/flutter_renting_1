import 'package:flutter/material.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/stores/product.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/widgets/orderBlock.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:provider/provider.dart';

class RentOrderDetails extends StatefulWidget {
  RentOrderDetails();

  @override
  State<StatefulWidget> createState() => _RentOrderDetailsState();
}

class _RentOrderDetailsState extends State<RentOrderDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Order currentOrder;

  @override
  void initState() {
    super.initState();
    final orderStore = Provider.of<OrderStore>(context, listen: false);
    currentOrder = orderStore.selectedOrderForDetails;
  }

  Widget showServiceNumberWidget() {
    if (currentOrder.orderStatus == orderStatusPaid) {
      return Padding(
        padding: const EdgeInsets.only(top: padding32),
        child: Container(
          width: double.infinity,
          height: tableEntryHeight,
          color: Colors.white,
          alignment: Alignment.center,
          child: Text(
            '服务号 - ${currentOrder.serviceNumber}',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationStore = Provider.of<NavigationStore>(context);
    final productStore = Provider.of<ProductStore>(context);
    Widget cancelOrContinueLeaseButtons = Padding(
      padding: const EdgeInsets.only(top: padding16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
            color: colorDisabled,
            textColor: colorDarkGrey,
            child: Text('退租'),
            onPressed: () {
              navigationStore.setServiceLocationParameters(
                  ServiceLocationPlaces.cancelingLease, '联系方式', -1, '一键退租');
              Navigator.pushNamed(context, RouteServiceLocation);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: padding16),
            child: FlatButton(
              color: colorPrimary,
              textColor: Colors.white,
              child: Text('续租'),
              onPressed: () {
                productStore.selectProduct(currentOrder.productData);
                Navigator.pushNamed(context, RouteContinueLease);
              },
            ),
          ),
        ],
      ),
    );
    Widget undoCancelLeaseButton = Padding(
      padding: const EdgeInsets.only(top: padding16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
              color: colorDisabled,
              textColor: colorDarkGrey,
              child: Text('取消退租'),
              onPressed: () async {
                try {
                  await HTTP.postWithAuth('$baseURL$apiCancelOrUncancelLease', {
                    'orderID': currentOrder.id,
                    'action': 'undoCancel',
                  });
                  _scaffoldKey.currentState
                    ..hideCurrentSnackBar()
                    ..showSnackBar(Util().successSnackBar('取消退租成功'));
                  setState(() {
                    currentOrder.orderStatus = orderStatusOngoing;
                  });
                } catch (e) {
                  _scaffoldKey.currentState
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      Util().failureSnackBar(
                        e.toString().replaceAll('Exception: ', ''),
                      ),
                    );
                }
              }),
        ],
      ),
    );
    // 根据订单的不同状态显示不同的可操作按键
    Widget showRelatedButtons() {
      if (currentOrder.orderStatus == orderStatusOngoing) {
        return cancelOrContinueLeaseButtons;
      }
      if (currentOrder.orderStatus == orderStatusCancelingLease) {
        return undoCancelLeaseButton;
      }
      return Container();
    }

    return Scaffold(
      backgroundColor: colorGeneralBackground, 
      key: _scaffoldKey,
      appBar: TitleTopBar(
        title: '租赁订单详情',
        canGoBack: true,
        actionButtons: <Widget>[],
      ),
      body: Padding(
        padding: const EdgeInsets.all(padding16),
        child: Column(
          children: <Widget>[
            OrderBlock(
              order: currentOrder,
              canTap: false,
            ),
            showServiceNumberWidget(),
            Padding(
              padding: const EdgeInsets.only(top: padding16, bottom: padding8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('租赁期限'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(padding16),
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                children: <Widget>[
                  ImageView(width: 24, height: 24, uri: 'assets/icons/date.png', imageType: ImageType.asset),
                  Padding(
                    padding: const EdgeInsets.only(left: padding16),
                    child: Text(
                      '${Util().getDateStringOfDateTime(currentOrder.createdAt)}-${Util().getDateStringOfDateTime(currentOrder.dueDate)}',
                      style: TextStyle(color: colorDisabled),
                    ),
                  ),
                ],
              ),
            ),
            showRelatedButtons(),
          ],
        ),
      ),
    );
  }
}
