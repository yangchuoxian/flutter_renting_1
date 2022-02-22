import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/models/address.model.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/stores/address.store.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/widgets/orderBlock.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:provider/provider.dart';

class WorkOrderDetails extends StatefulWidget {
  WorkOrderDetails();

  @override
  State<StatefulWidget> createState() => _WorkOrderDetailsState();
}

class _WorkOrderDetailsState extends State<WorkOrderDetails> {
  Order order;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool orderAddressFetched = false;
  UserAddress orderAddress;

  @override
  void initState() {
    super.initState();
    final orderStore = Provider.of<OrderStore>(context, listen: false);
    order = orderStore.selectedOrderForDetails;
    getOrderAddress();
  }

  void getOrderAddress() async {
    try {
      var resp = await HTTP.postWithAuth('$baseURL$apiGetAddressForWorkOrder', {
        'orderID': order.id,
        'addressID': order.addressID,
      });
      setState(() {
        orderAddress = UserAddress.fromJson(resp);
        orderAddressFetched = true;
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState
          ..hideCurrentSnackBar()
          ..showSnackBar(Util()
              .failureSnackBar(e.toString().replaceAll('Exception: ', '')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressStore = Provider.of<AddressStore>(context, listen: false);
    List<Widget> mainColumnChildren = <Widget>[
      OrderBlock(
        order: order,
        canTap: false,
      ),
      Padding(
        padding: const EdgeInsets.only(top: padding16),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(padding16),
          child: Row(
            children: <Widget>[
              ImageView(
                width: 24,
                height: 24,
                uri: 'assets/icons/number.png',
                imageType: ImageType.asset,
              ),
              Padding(
                padding: const EdgeInsets.only(left: padding16),
                child: Text(
                  '订单号',
                  style: TextStyle(fontSize: subtitleTextSize),
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.only(left: padding16),
                child: Text(
                  '${order.orderNumber}',
                  style: TextStyle(
                    fontSize: bodyTextSize,
                    color: colorDisabled,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
    if (orderAddressFetched && orderAddress != null) {
      mainColumnChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: padding16, bottom: padding8),
          child: Text(
            '服务地址',
            style: TextStyle(
              color: colorDisabled,
            ),
          ),
        ),
      );
      mainColumnChildren.add(
        GestureDetector(
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
                          '${orderAddress.location}',
                          style: TextStyle(fontSize: subtitleTextSize),
                          softWrap: true,
                        ),
                        Text(
                          '${orderAddress.contactName}/${orderAddress.phone}',
                          style: TextStyle(color: colorDarkGrey),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(RentingApp.chevron_right, color: colorDisabled),
              ],
            ),
          ),
          onTap: () {
            addressStore.setWorkOrderAddress(orderAddress);
            Navigator.pushNamed(context, RouteClientGeolocation);
          },
        ),
      );
    }
    mainColumnChildren.add(
      Expanded(child: Container()),
    );
    mainColumnChildren.add(
      SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          disabledColor: colorDisabled,
          color: colorPrimary,
          child: Text('完成订单'),
          borderRadius: BorderRadius.zero,
          onPressed: () {
            Navigator.pushNamed(context, RouteFinishWorkOrder);
          },
        ),
      ),
    );
    Widget mainColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: mainColumnChildren,
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: TitleTopBar(
        title: '工单详情',
        canGoBack: true,
        actionButtons: <Widget>[],
      ),
      body: Padding(
        padding: const EdgeInsets.all(padding16),
        child: mainColumn,
      ),
    );
  }
}
