import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/services/util.dart';

class OrderBlock extends StatelessWidget {
  final Order order;
  final bool canTap;
  OrderBlock({this.order, this.canTap}) : super();

  Widget detailsIcon() {
    if (canTap) {
      return Icon(
        RentingApp.chevron_right,
        color: colorDisabled,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (order.orderType == orderTypeFixBattery ||
        order.orderType == orderTypeRoadRescue ||
        order.orderType == orderTypeBatteryMissing) {
      // ************************** 服务订单
      Color statusColor = colorPrimary;
      String statusText = '待安装';
      if (order.orderStatus == orderStatusFinished) {
        statusColor = colorDisabled;
        statusText = '已完成';
      }
      if (order.orderStatus == orderStatusPaid) {
        statusColor = Colors.red;
        statusText = '待安装';
      }
      if (order.orderStatus == orderStatusCanceled) {
        statusColor = colorDarkGrey;
        statusText = '已取消';
      }

      String serviceText;
      switch (order.orderType) {
        case orderTypeFixBattery:
          serviceText = '电池故障报修';
          break;
        case orderTypeRoadRescue:
          serviceText = '道路救援';
          break;
        case orderTypeBatteryMissing:
          serviceText = '电池丢失报警';
          break;
        default:
          break;
      }
      return Container(
        padding: const EdgeInsets.all(padding16),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ImageView(
              width: largeAvatar,
              height: largeAvatar,
              // ycx!!!!!! TODO: 服务订单要用另外的图片，而不是电池商品图片
              uri: order.productData.coverImageURL,
              imageType: ImageType.network,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: padding16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$serviceText',
                      style: TextStyle(fontSize: titleTextSize),
                    ),
                    Text(
                      '无需支付',
                      style: TextStyle(color: colorDisabled),
                    ),
                    Text(
                      '${Util().getDateStringOfDateTime(order.createdAt)}创建',
                      style: TextStyle(color: colorDisabled),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              statusText,
              style: TextStyle(color: statusColor),
            ),
            detailsIcon(),
          ],
        ),
      );
    } else {
      // ************************** 租赁订单
      String payType, priceText;
      if (order.orderType == orderTypeRentProductYearly) {
        priceText = '${order.productData.pricePerYear}元/年';
        payType = '年付';
      } else if (order.orderType == orderTypeRentProductMonthly) {
        priceText = '${order.productData.pricePerMonth}元/月';
        payType = '月付';
      }
      Color statusColor = colorPrimary;
      String statusText = '进行中';
      if (order.orderStatus == orderStatusFinished) {
        statusColor = colorDisabled;
        statusText = '已完成';
      }
      if (order.orderStatus == orderStatusPaid) {
        statusColor = Colors.red;
        statusText = '待安装';
      }
      if (order.orderStatus == orderStatusCancelingLease) {
        statusColor = Colors.red;
        statusText = '退租中';
      }
      if (order.orderStatus == orderStatusWaitingForRefund) {
        statusColor = Colors.red;
        statusText = '退款中';
      }
      return Container(
        padding: const EdgeInsets.all(padding16),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ImageView(
              width: largeAvatar,
              height: largeAvatar,
              uri: order.productData.coverImageURL,
              imageType: ImageType.network,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: padding16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${order.productData.title}',
                      style: TextStyle(fontSize: titleTextSize),
                    ),
                    Text(
                      '押金${order.deposit}元, $payType$priceText',
                      style: TextStyle(color: colorDisabled),
                    ),
                    Text(
                      '${Util().getDateStringOfDateTime(order.dueDate)}到期',
                      style: TextStyle(color: colorDisabled),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              statusText,
              style: TextStyle(color: statusColor),
            ),
            detailsIcon(),
          ],
        ),
      );
    }
  }
}
