import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/stores/address.store.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/models/address.model.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:provider/provider.dart';

class AddressList extends StatefulWidget {
  AddressList();

  @override
  State<StatefulWidget> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<dynamic> _futureAddressList;

  Future<dynamic> _getUserAddresses() async {
    return HTTP.postWithAuth('$baseURL$apiGetUserAddresses', {});
  }

  @override
  void initState() {
    super.initState();
    _futureAddressList = _getUserAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final addressStore = Provider.of<AddressStore>(context);
    var futureBuilder = FutureBuilder<dynamic>(
      future: _futureAddressList,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          // ycx!!!!!! TODO::: 该用户没有地址，需要有个插画提示用户设置地址
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(padding16),
                child: Text(
                  '暂无地址',
                  style: TextStyle(color: colorDisabled),
                ),
              ),
            ],
          );
        }
        if (snapshot.hasData) {
          var addressWidgets = <Widget>[];
          for (var a in snapshot.data) {
            var address = UserAddress.fromJson(a);
            Widget defaultText = Text('');
            if (address.isDefault == true) {
              defaultText = Text(
                '默认地址',
                style: TextStyle(color: Colors.red),
              );
            }
            var addressWidget = Padding(
              padding: EdgeInsets.only(
                top: padding16,
                left: padding16,
                right: padding16,
              ),
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.all(0),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: padding8,
                      right: padding8,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                address.location,
                                style: TextStyle(fontSize: titleTextSize),
                              ),
                              Text(
                                '${address.contactName}/${address.phone}',
                                style: TextStyle(color: colorDisabled),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                defaultText,
                                IconButton(
                                  icon: Icon(RentingApp.edit),
                                  onPressed: () {
                                    addressStore.setEditingAddress(address);
                                    Navigator.pushNamed(
                                      context,
                                      RouteUpdateAddress,
                                    ).then((_) {
                                      setState(() {
                                        _futureAddressList =
                                            _getUserAddresses();
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            addressWidgets.add(addressWidget);
          }
          return ListView(
            children: addressWidgets,
          );
        }
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scaffoldKey.currentState
              ..hideCurrentSnackBar()
              ..showSnackBar(Util().failureSnackBar('获取用户地址列表失败'));
          });
          return Container();
        }
        return Padding(
          padding: EdgeInsets.all(padding16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Theme(
                data: Theme.of(context).copyWith(accentColor: colorPrimary),
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        );
      },
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: TitleTopBar(
        title: '地址管理',
        canGoBack: true,
        actionButtons: <Widget>[
          IconButton(
              icon: Icon(RentingApp.add),
              onPressed: () {
                Navigator.pushNamed(context, RouteNewAddress).then((_) {
                  // 当这个navigator去到的route pop back时，这个then会被调用，此处用setState强行调用initState来获取更新后的addresslist
                  setState(() {
                    _futureAddressList = _getUserAddresses();
                  });
                });
              }),
        ],
      ),
      body: futureBuilder,
    );
  }
}
