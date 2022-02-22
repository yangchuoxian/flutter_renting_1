import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/widgets/orderBlock.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:provider/provider.dart';

class ServiceOrderDetails extends StatefulWidget {
  ServiceOrderDetails();

  @override
  State<StatefulWidget> createState() => _ServiceOrderDetailsState();
}

class _ServiceOrderDetailsState extends State<ServiceOrderDetails> {
  Order order;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final orderStore = Provider.of<OrderStore>(context, listen: false);
    order = orderStore.selectedOrderForDetails;
  }

  Widget cancelServiceOrderButton() {
    if (order.orderStatus == orderStatusPaid) {
      // 只有等待客服人员上门中的服务单可以取消
      return Padding(
        padding: const EdgeInsets.only(
          left: padding16,
          right: padding16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              color: colorFailure,
              textColor: Colors.white,
              child: Text('取消服务单'),
              onPressed: () async {
                try {
                  await HTTP.postWithAuth('$baseURL$apiCancelServiceOrder', {
                    'orderID': order.id,
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scaffoldKey.currentState
                      ..hideCurrentSnackBar()
                      ..showSnackBar(Util().successSnackBar('取消服务单成功'));
                  });
                  setState(() {
                    order.orderStatus = orderStatusCanceled;
                  });
                } catch (e) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scaffoldKey.currentState
                      ..hideCurrentSnackBar()
                      ..showSnackBar(Util().failureSnackBar(
                          e.toString().replaceAll('Exception: ', '')));
                  });
                }
              },
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget showServiceNumberWidget() {
    if (order.orderStatus == orderStatusPaid) {
      return Padding(
        padding: const EdgeInsets.all(padding16),
        child: Container(
          width: double.infinity,
          height: tableEntryHeight,
          color: Colors.white,
          alignment: Alignment.center,
          child: Text(
            '服务号 - ${order.serviceNumber}',
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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorGeneralBackground, 
      key: _scaffoldKey,
      appBar: TitleTopBar(
        title: '服务单详情',
        canGoBack: true,
        actionButtons: <Widget>[],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(padding16),
            child: OrderBlock(
              order: order,
              canTap: false,
            ),
          ),
          showServiceNumberWidget(),
          // 只有服务单是“待安装”的时候可以取消
          cancelServiceOrderButton(),
        ],
      ),
    );
  }
}
