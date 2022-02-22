import 'package:flutter/material.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/widgets/tabTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/widgets/bottomTabBar.dart';
import 'package:provider/provider.dart';

class ServiceShop extends StatelessWidget {
  const ServiceShop();

  @override
  Widget build(BuildContext context) {
    final navigationStore = Provider.of<NavigationStore>(context);
    return Scaffold(
      backgroundColor: colorGeneralBackground, 
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TabTopBar(
              entries: <String>['租赁', '服务'],
              routes: <String>[
                RouteRentShop,
                RouteServiceShop,
              ],
              selectedIndex: 1,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(padding16),
                child: ListView(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: ListTile(
                        leading: ImageView(width: 24, height: 24, uri: 'assets/icons/exclamation.png', imageType: ImageType.asset),
                        title: Text('电池丢失'),
                        trailing: Icon(RentingApp.chevron_right),
                        onTap: () {
                          navigationStore.setServiceLocationParameters(ServiceLocationPlaces.creatingServiceOrder, '电池丢失', orderTypeBatteryMissing, '一键报警');
                          Navigator.pushNamed(context, RouteRentedBattery);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: padding16),
                      child: Container(),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: ListTile(
                        leading: ImageView(width: 24, height: 24, uri: 'assets/icons/broken.png', imageType: ImageType.asset),
                        title: Text('电池故障'),
                        trailing: Icon(RentingApp.chevron_right),
                        onTap: () {
                          navigationStore.setServiceLocationParameters(ServiceLocationPlaces.creatingServiceOrder, '电池故障', orderTypeFixBattery, '一键报修');
                          Navigator.pushNamed(context, RouteRentedBattery);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: padding16),
                      child: Container(),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: ListTile(
                        leading: ImageView(width: 24, height: 24, uri: 'assets/icons/battery_low.png', imageType: ImageType.asset),
                        title: Text('道路救援'),
                        trailing: Icon(RentingApp.chevron_right),
                        onTap: () {
                          navigationStore.setServiceLocationParameters(ServiceLocationPlaces.creatingServiceOrder, '道路救援', orderTypeRoadRescue, '一键救援');
                          Navigator.pushNamed(context, RouteRentedBattery);
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomTabBar(),
    );
  }
}
