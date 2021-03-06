import 'package:flutter/material.dart';
import 'package:flutter_renting/widgets/horizontalLine.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/widgets/emptyList.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/models/product.model.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:provider/provider.dart';

class WorkOrders extends StatefulWidget {
  WorkOrders();

  @override
  State<StatefulWidget> createState() => _WorkOrdersState();
}

class _WorkOrdersState extends State<WorkOrders> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget mainContent;
  List<Order> _workOrders = [];

  @override
  void dispose() {
    if (_workOrders != null) {
      _workOrders.clear();
    }
    super.dispose();
  }

  void getAssignedOrdersForServicePersonnel(OrderStore orderStore) async {
    try {
      var resp = await HTTP
          .postWithAuth('$baseURL$apiGetAssignedOrdersForServicePersonnel', {});
      if (resp != null && resp.length > 0) {
        List<Order> workOrders = <Order>[];
        for (var o in resp) {
          var order = Order.fromJson(o);
          order.productData = Product.fromJson(o['productData'][0]);
          workOrders.add(order);
        }
        if (mounted) {
          setState(() {
            _workOrders = workOrders;
            orderStore.setWorkOrders(_workOrders);
          });
        }
      } else {
        setState(() {
          _workOrders.clear();
          orderStore.setWorkOrders(_workOrders);
        });
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

  Widget workOrderEntry(BuildContext context, OrderStore orderStore, Order wo,
      String title, String subtitle) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(padding16),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$title',
                  style: TextStyle(
                    color: colorDisabled,
                    fontSize: subtitleTextSize,
                  ),
                ),
                Text(
                  '$subtitle',
                  style:
                      TextStyle(color: colorDarkGrey, fontSize: bodyTextSize),
                ),
              ],
            ),
            Expanded(child: Container()),
            Text(
              '?????????',
              style: TextStyle(color: Colors.red),
            ),
            Icon(RentingApp.chevron_right),
          ],
        ),
      ),
      onTap: () {
        orderStore.selectOrderForDetails(wo);
        Navigator.pushNamed(context, RouteWorkOrderDetails).then((_) {
          // ????????????????????????????????????????????????pop????????????????????????????????????work orders??????
          getAssignedOrdersForServicePersonnel(orderStore);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderStore = Provider.of<OrderStore>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    if (orderStore.workOrders == null || orderStore.workOrders.length == 0) {
      mainContent = EmptyList(
        hintText1: '????????????????????????????????????',
        hintText2: '',
        imageURL: 'assets/images/404.png',
      );
    } else {
      _workOrders = orderStore.workOrders;
      List<Widget> serviceOrders = <Widget>[];
      List<Widget> rentOrders = <Widget>[];
      List<Widget> cancelLeaseOrders = <Widget>[];
      for (var wo in _workOrders) {
        if (wo.orderStatus == orderStatusCancelingLease) {
          // ????????????
          if (cancelLeaseOrders.length > 0) {
            cancelLeaseOrders.add(
              CustomPaint(
                size: Size(screenWidth, 0),
                painter: HorizontalLine(
                  width: screenWidth - padding32,
                  horizontalOffset: padding16,
                  topOffset: 0,
                ),
              ),
            );
          }
          cancelLeaseOrders.add(
            workOrderEntry(context, orderStore, wo, wo.productData.title,
                '??????: ${wo.orderNumber}'),
          );
        } else if (wo.orderType == orderTypeRentProductYearly ||
            wo.orderType == orderTypeRentProductMonthly) {
          // ????????????
          if (rentOrders.length > 0) {
            rentOrders.add(
              CustomPaint(
                size: Size(screenWidth, 0),
                painter: HorizontalLine(
                  width: screenWidth - padding32,
                  horizontalOffset: padding16,
                  topOffset: 0,
                ),
              ),
            );
          }
          rentOrders.add(
            workOrderEntry(context, orderStore, wo, wo.productData.title,
                '??????: ${wo.orderNumber}'),
          );
        } else {
          // ?????????
          String serviceText;
          switch (wo.orderType) {
            case orderTypeFixBattery:
              serviceText = '??????????????????';
              break;
            case orderTypeRoadRescue:
              serviceText = '????????????';
              break;
            case orderTypeBatteryMissing:
              serviceText = '??????????????????';
              break;
            default:
              break;
          }
          if (serviceOrders.length > 0) {
            serviceOrders.add(
              CustomPaint(
                size: Size(screenWidth, 0),
                painter: HorizontalLine(
                  width: screenWidth - padding32,
                  horizontalOffset: padding16,
                  topOffset: 0,
                ),
              ),
            );
          }
          serviceOrders.add(
            workOrderEntry(
                context, orderStore, wo, serviceText, '??????: ${wo.orderNumber}'),
          );
        }
      }
      if (serviceOrders.length > 0) {
        serviceOrders.insert(
          0,
          Padding(
            padding: const EdgeInsets.only(bottom: padding8),
            child: Text(
              '?????????',
              style: TextStyle(color: colorDisabled),
              textAlign: TextAlign.left,
            ),
          ),
        );
        serviceOrders.add(
          Padding(
            padding: const EdgeInsets.only(top: padding16),
            child: Container(),
          ),
        );
      }
      if (rentOrders.length > 0) {
        rentOrders.insert(
          0,
          Padding(
            padding: const EdgeInsets.only(bottom: padding8),
            child: Text(
              '?????????',
              style: TextStyle(color: colorDisabled),
              textAlign: TextAlign.left,
            ),
          ),
        );
        rentOrders.add(
          Padding(
            padding: const EdgeInsets.only(top: padding16),
            child: Container(),
          ),
        );
      }
      if (cancelLeaseOrders.length > 0) {
        cancelLeaseOrders.insert(
          0,
          Padding(
            padding: const EdgeInsets.only(bottom: padding8),
            child: Text(
              '????????????',
              style: TextStyle(color: colorDisabled),
              textAlign: TextAlign.left,
            ),
          ),
        );
      }
      mainContent = ListView(
        children: List.from(serviceOrders)
          ..addAll(rentOrders)
          ..addAll(cancelLeaseOrders),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorGeneralBackground,
      appBar: TitleTopBar(
        title: '????????????',
        canGoBack: true,
        actionButtons: <Widget>[],
      ),
      body: Padding(
        padding: const EdgeInsets.all(padding16),
        child: mainContent,
      ),
    );
  }
}
