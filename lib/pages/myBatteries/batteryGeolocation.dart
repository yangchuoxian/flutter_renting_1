import 'package:flutter/cupertino.dart';
import 'package:flutter_renting/services/mapUtil.dart';
import 'package:flutter_renting/widgets/horizontalLine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bmfmap/BaiduMap/bmfmap_map.dart';
import 'package:flutter_bmfbase/BaiduMap/bmfmap_base.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BatteryGeolocation extends StatefulWidget {
  BatteryGeolocation();

  @override
  State<StatefulWidget> createState() => _BatteryGeolocationState();
}

class _BatteryGeolocationState extends State<BatteryGeolocation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PanelController _pc = PanelController();
  double _longitude;
  double _latitude;

  Future<dynamic> getBatteryLocation(Order order) async {
    return HTTP.postWithAuth('$baseURL$apiGetBatteryLocation', {
      'batteryID': order.batteryID,
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderStore = Provider.of<OrderStore>(context, listen: false);
    var order = orderStore.selectedOrderForDetails;
    var futureBuilder = FutureBuilder<dynamic>(
      future: getBatteryLocation(order),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scaffoldKey.currentState
              ..hideCurrentSnackBar()
              ..showSnackBar(Util().failureSnackBar('电池定位失败'));
            return Container();
          });
        }
        if (snapshot.hasData) {
          if (snapshot.data['coordinates'] == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scaffoldKey.currentState
                ..hideCurrentSnackBar()
                ..showSnackBar(Util().failureSnackBar('电池定位失败'));
              return Container();
            });
          }
          if (snapshot.data['coordinates'][0] == null ||
              snapshot.data['coordinates'][1] == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scaffoldKey.currentState
                ..hideCurrentSnackBar()
                ..showSnackBar(Util().failureSnackBar('电池定位失败'));
              return Container();
            });
          }
          _longitude = snapshot.data['coordinates'][0];
          _latitude = snapshot.data['coordinates'][1];

          BMFMapOptions mapOptions = BMFMapOptions(
            center: BMFCoordinate(_latitude, _longitude),
            zoomLevel: 20,
            zoomEnabled: true,
            zoomEnabledWithTap: true,
            showMapScaleBar: true,
          );
          return Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                      left: padding16, right: padding16, top: padding16),
                  width: double.infinity,
                  child: BMFMapWidget(
                    onBMFMapCreated: (controller) {
                      BMFMarker marker = BMFMarker(
                        icon: 'assets/icons/geolocation.png',
                        position: BMFCoordinate(_latitude, _longitude),
                      );
                      controller.addMarker(marker);
                    },
                    mapOptions: mapOptions,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(padding16),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    disabledColor: colorDisabled,
                    color: colorPrimary,
                    child: Text('一键导航'),
                    borderRadius: BorderRadius.zero,
                    onPressed: () {
                      _pc.open();
                    },
                  ),
                ),
              ),
            ],
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    final double screenWidth = MediaQuery.of(context).size.width;
    var mapNavigationActionSheet = Container(
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
                  Text('百度导航'),
                ],
              ),
              onTap: () async {
                var canLaunchBaiduMap =
                    await MapUtil.gotoBaiduMap(_longitude, _latitude);
                if (!canLaunchBaiduMap) {
                  _pc.close();
                  _scaffoldKey.currentState
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      Util().failureSnackBar('未检测到百度地图'),
                    );
                }
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('高德导航'),
                ],
              ),
              onTap: () async {
                var canLaunchGaodeMap =
                    await MapUtil.gotoGaoDeMap(_longitude, _latitude);
                if (!canLaunchGaodeMap) {
                  _pc.close();
                  _scaffoldKey.currentState
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      Util().failureSnackBar('未检测到高德地图'),
                    );
                }
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
        panel: mapNavigationActionSheet,
        body: Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          appBar: TitleTopBar(
            title: '电池定位',
            canGoBack: true,
            actionButtons: [],
          ),
          body: futureBuilder,
        ),
      ),
    );
  }
}
