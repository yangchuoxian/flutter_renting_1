import 'package:flutter/material.dart';
import 'package:flutter_renting/models/battery.model.dart';
import 'package:flutter_renting/widgets/horizontalLine.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/services/http.dart';

class BatteryStatus extends StatefulWidget {
  BatteryStatus();

  @override
  State<StatefulWidget> createState() => _BatteryStatusState();
}

class _BatteryStatusState extends State<BatteryStatus> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Order order;
  Battery battery = Battery(
    id: '-',
    batterySerialNo: '-',
    status: '-',
    soc: '-',
    totalVoltage: '-',
    temperature: '-',
    longitude: '-',
    latitude: '-',
  );

  @override
  void initState() {
    super.initState();
    final orderStore = Provider.of<OrderStore>(context, listen: false);
    order = orderStore.selectedOrderForDetails;
    getBatteryStatus();
  }

  void getBatteryStatus() async {
    try {
      var resp = await HTTP.postWithAuth('$baseURL$apiGetBatteryStatus', {
        'batteryID': order.batteryID,
      });
      setState(() {
        battery = Battery.fromJson(resp);
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scaffoldKey != null) {
          if (_scaffoldKey.currentState != null) {
            _scaffoldKey.currentState
              ..hideCurrentSnackBar()
              ..showSnackBar(Util()
                  .failureSnackBar(e.toString().replaceAll('Exception: ', '')));
          }
        }
      });
    }
  }

  Widget batteryStatusDataEntry(
      String iconImagePath, String title, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.all(padding16),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: padding16,
            ),
            child: ImageView(
                width: 24,
                height: 24,
                uri: iconImagePath,
                imageType: ImageType.asset),
          ),
          Padding(
            padding: const EdgeInsets.only(left: padding16),
            child: Text(
              title,
              style: TextStyle(
                color: colorDisabled,
              ),
            ),
          ),
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.only(left: padding16, right: padding16),
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    String priceText = '';
    String rentPeriodText =
        '${Util().getDateStringOfDateTime(order.createdAt)}-${Util().getDateStringOfDateTime(order.dueDate)}';
    if (order.orderType == orderTypeRentProductYearly) {
      priceText = '年租${order.productData.pricePerYear}元/年';
    } else {
      priceText = '月租${order.productData.pricePerMonth}元/月}';
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: TitleTopBar(
        title: '电池详情',
        canGoBack: true,
        actionButtons: <Widget>[],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              height: 82.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/battery_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: padding32,
                  top: 12.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ImageView(
                      width: largeAvatar,
                      height: largeAvatar,
                      uri: order.productData.coverImageURL,
                      imageType: ImageType.network,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: padding16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              order.productData.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleTextSize,
                              ),
                            ),
                            Text(
                              priceText,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              rentPeriodText,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            batteryStatusDataEntry('assets/icons/number.png', '电池ID',
                battery.batterySerialNo, colorDisabled),
            batteryStatusDataEntry(
                'assets/icons/setting.png',
                '状态',
                battery.status,
                (battery.status == '正常' ? colorPrimary : colorFailure)),
            CustomPaint(
              size: Size(screenWidth, 0),
              painter: HorizontalLine(
                width: screenWidth,
                horizontalOffset: padding16,
                topOffset: 0,
              ),
            ),
            batteryStatusDataEntry('assets/icons/battery_low.png', '电量SOC',
                battery.soc, colorDisabled),
            batteryStatusDataEntry('assets/icons/lightning.png', '总电压',
                battery.totalVoltage, colorDisabled),
            batteryStatusDataEntry('assets/icons/temperature.png', '电池温度',
                battery.temperature, colorDisabled),
            CustomPaint(
              size: Size(screenWidth, 0),
              painter: HorizontalLine(
                width: screenWidth,
                horizontalOffset: padding16,
                topOffset: 0,
              ),
            ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(padding16),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: padding16),
                      child: ImageView(
                          width: 24,
                          height: 24,
                          uri: 'assets/icons/location_on.png',
                          imageType: ImageType.asset),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: padding16),
                      child: Text(
                        '电池定位',
                        style: TextStyle(
                          color: colorDisabled,
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: const EdgeInsets.only(right: padding16),
                      child:
                          Icon(RentingApp.chevron_right, color: colorDisabled),
                    ),
                  ],
                ),
              ),
              onTap: () async {
                Navigator.pushNamed(context, RouteBatteryGeolocation);
              },
            ),
          ],
        ),
      ),
    );
  }
}
