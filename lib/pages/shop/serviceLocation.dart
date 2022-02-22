import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_renting/models/address.model.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:provider/provider.dart';

class ServiceLocation extends StatefulWidget {
  ServiceLocation();
  @override
  State<StatefulWidget> createState() => _ServiceLocationState();
}

class _ServiceLocationState extends State<ServiceLocation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;
  TextEditingController _addressTextController;
  TextEditingController _contactNameTextController;
  TextEditingController _phoneTextController;
  String _enteredAddress = '';
  String _enteredContactName = '';
  String _enteredPhone = '';
  String _existedAddressID = '';

  void _getUserAddresses() async {
    var resp = await HTTP.postWithAuth('$baseURL$apiGetUserAddresses', {});
    UserAddress addressToUse;
    bool addressDecided = false;
    if (resp != null) {
      List<UserAddress> addressesFromBackend = <UserAddress>[];
      for (var a in resp) {
        var address = UserAddress.fromJson(a);
        addressesFromBackend.add(address);
        if (address.isDefault == true) {
          addressDecided = true;
          addressToUse = address;
          break;
        }
      }
      if (!addressDecided && addressesFromBackend.length >= 1) {
        addressDecided = true;
        addressToUse = addressesFromBackend[0];
      }
    }
    if (addressToUse != null) {
      // 从后台找到了可用的联系地址，在文本框中设置可用地址
      _enteredAddress = addressToUse.location;
      _enteredContactName = addressToUse.contactName;
      _enteredPhone = addressToUse.phone;
      _existedAddressID = addressToUse.addressID;
    }
    setState(() {
      _addressTextController.text = _enteredAddress;
      _contactNameTextController.text = _enteredContactName;
      _phoneTextController.text = _enteredPhone;
    });
  }

  @override
  void dispose() {
    if (_addressTextController != null) {
      _addressTextController.clear();
      _addressTextController.dispose();
    }
    if (_contactNameTextController != null) {
      _contactNameTextController.clear();
      _contactNameTextController.dispose();
    }
    if (_phoneTextController != null) {
      _phoneTextController.clear();
      _phoneTextController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _addressTextController = TextEditingController(text: _enteredAddress);
    _contactNameTextController =
        TextEditingController(text: _enteredContactName);
    _phoneTextController = TextEditingController(text: _enteredPhone);
    // 从后台获取默认地址，如果没有默认地址，获取用户的第一条地址，如果还是没有，那就要提示用户输入地址了
    _getUserAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final orderStore = Provider.of<OrderStore>(context);
    final navigationStore = Provider.of<NavigationStore>(context);

    Widget addressInput = Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Padding(
        padding: EdgeInsets.only(
          left: padding8,
          right: padding8,
        ),
        child: TextField(
          controller: _addressTextController,
          textAlign: TextAlign.start,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '请输入您的地址，以方便我们的后续服务',
            border: InputBorder.none,
          ),
          onChanged: (text) {
            _enteredAddress = text;
          },
        ),
      ),
    );
    Widget contactNameInput = Padding(
      padding: EdgeInsets.only(top: padding16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(
            left: padding8,
            right: padding8,
          ),
          child: Row(
            children: <Widget>[
              Text(
                '联系人',
                style: TextStyle(fontSize: bodyTextSize),
              ),
              Flexible(
                child: TextField(
                  controller: _contactNameTextController,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: '请输入联系人名称',
                    border: InputBorder.none,
                  ),
                  onChanged: (text) {
                    _enteredContactName = text;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Widget phoneInput = Padding(
      padding: EdgeInsets.only(top: padding16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(
            left: padding8,
            right: padding8,
          ),
          child: Row(
            children: <Widget>[
              Text(
                '手机',
                style: TextStyle(fontSize: bodyTextSize),
              ),
              Flexible(
                child: TextField(
                  controller: _phoneTextController,
                  textAlign: TextAlign.end,
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '请输入手机号码',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (inputText) {
                    _enteredPhone = inputText;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    var validateInput = () {
      if (_enteredAddress == '' ||
          _enteredPhone == '' ||
          _enteredContactName == '') {
        return false;
      }
      if (!Util.isChinaPhoneLegal(_enteredPhone)) {
        return false;
      }
      return true;
    };
    Widget submitButton = SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        disabledColor: colorDisabled,
        color: colorPrimary,
        child: Text(navigationStore.serviceLocationSubmitButtonText),
        borderRadius: BorderRadius.zero,
        onPressed: ((!validateInput()) || _isSubmitting)
            ? null
            : () async {
                String addressID = "";
                if (_existedAddressID != '') {
                  addressID = _existedAddressID;
                }
                orderStore.setOrderAddress(addressID, _enteredAddress,
                    _enteredContactName, _enteredPhone);

                switch (navigationStore.serviceLocationPlace) {
                  case ServiceLocationPlaces.rentingBattery:
                    // 是租赁电池的订单，跳转到确认订单和支付页面
                    Navigator.pushNamed(context, RouteConfirmRentOrder);
                    break;
                  case ServiceLocationPlaces.creatingServiceOrder:
                    // 是后续的服务订单，将该订单连同用户地址一起直接提交到后台
                    try {
                      _isSubmitting = true;
                      await HTTP.postWithAuth('$baseURL$apiCreateServiceOrder', {
                        'type': '${navigationStore.serviceLocationOrderType}',
                        'rentOrderID': orderStore.selectedOrderForService,
                        'contactName': orderStore.orderAddress.contactName,
                        'phone': orderStore.orderAddress.phone,
                        'location': orderStore.orderAddress.location,
                        'addressID': orderStore.orderAddress.addressID,
                      });
                      _isSubmitting = false;
                      Navigator.pushNamed(context, RouteSubmitOrderSucceeded);
                    } catch (e) {
                      _scaffoldKey.currentState
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          Util().failureSnackBar(
                            e.toString().replaceAll('Exception: ', ''),
                          ),
                        );
                      _isSubmitting = false;
                    }
                    break;
                  case ServiceLocationPlaces.cancelingLease:
                    try {
                      _isSubmitting = true;
                      await HTTP.postWithAuth('$baseURL$apiCancelOrUncancelLease', {
                        'orderID': orderStore.selectedOrderForDetails.id,
                        'action': 'cancelLease',
                      });
                      _isSubmitting = false;
                      Navigator.pushNamed(context, RouteSubmitOrderSucceeded);
                    } catch (e) {
                      _scaffoldKey.currentState
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          Util().failureSnackBar(
                            e.toString().replaceAll('Exception: ', ''),
                          ),
                        );
                      _isSubmitting = false;
                    }
                    break;
                  default:
                    break;
                }
              },
      ),
    );
    return Scaffold(
      backgroundColor: colorGeneralBackground,
      key: _scaffoldKey,
      appBar: TitleTopBar(
        title: navigationStore.serviceLocationPageTitle,
        canGoBack: true,
        actionButtons: <Widget>[],
      ),
      body: GestureDetector(
        onTap: () {
          Util().loseFocus(context);
        },
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - padding64 - padding16),
            child: Padding(
              padding: EdgeInsets.all(padding16),
              child: Column(
                children: <Widget>[
                  addressInput,
                  contactNameInput,
                  phoneInput,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: padding16),
                        child: Text(
                          '稍后将会有客服人员致电确认您的所在地址',
                          style: TextStyle(
                            color: colorDisabled,
                            fontSize: bodyTextSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
                  submitButton,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
