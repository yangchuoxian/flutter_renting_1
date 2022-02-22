import 'package:flutter/cupertino.dart';
import 'package:flutter_renting/services/mapUtil.dart';
import 'package:flutter_renting/stores/address.store.dart';
import 'package:flutter_renting/widgets/horizontalLine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bmfmap/BaiduMap/bmfmap_map.dart';
import 'package:flutter_bmfbase/BaiduMap/bmfmap_base.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ClientGeolocation extends StatefulWidget {
  ClientGeolocation();

  @override
  State<StatefulWidget> createState() => _ClientGeolocationState();
}

class _ClientGeolocationState extends State<ClientGeolocation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PanelController _pc = PanelController();
  double _longitude;
  double _latitude;

  @override
  void initState() {
    super.initState();
    final addressStore = Provider.of<AddressStore>(context, listen: false);
    try {
      _latitude = double.parse(addressStore.workOrderAddress.latitude);
      _longitude = double.parse(addressStore.workOrderAddress.longitude);
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState
          ..hideCurrentSnackBar()
          ..showSnackBar(Util().failureSnackBar('无效的经纬度坐标'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    BMFMapOptions mapOptions = BMFMapOptions(
      center: BMFCoordinate(_latitude, _longitude),
      zoomLevel: 20,
      zoomEnabled: true,
      zoomEnabledWithTap: true,
      showMapScaleBar: true,
    );
    var mainColumn = Column(
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
            title: '用户位置',
            canGoBack: true,
            actionButtons: [],
          ),
          body: mainColumn,
        ),
      ),
    );
  }
}
