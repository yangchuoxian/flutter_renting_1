import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:provider/provider.dart';

class FinishWorkOrder extends StatefulWidget {
  FinishWorkOrder();

  @override
  State<StatefulWidget> createState() => _FinishWorkOrderState();
}

class _FinishWorkOrderState extends State<FinishWorkOrder> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _enteredServiceNumber = '';
  String _enteredBatteryID = '';
  bool _isSubmitting = false;
  final _serviceNumberTextFieldController = TextEditingController();
  final _batteryIDTextFieldController = TextEditingController();
  Order order;

  @override
  void initState() {
    super.initState();
    final orderStore = Provider.of<OrderStore>(context, listen: false);
    order = orderStore.selectedOrderForDetails;
  }

  @override
  void dispose() {
    _serviceNumberTextFieldController.dispose();
    _batteryIDTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var batteryIDHintText = '请输入更换的电池ID';
    if (order.orderType == orderTypeRentProductYearly ||
        order.orderType == orderTypeRentProductMonthly) {
      batteryIDHintText = '请输入租赁的电池ID';
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorGeneralBackground,
      appBar: TitleTopBar(
        title: '完成工单',
        canGoBack: true,
        actionButtons: [],
      ),
      body: GestureDetector(
        onTap: () => Util().loseFocus(context),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height - padding64 - padding16),
            child: Padding(
              padding: const EdgeInsets.all(padding16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: padding8, right: padding8),
                      child: Row(
                        children: [
                          Text('服务码', style: TextStyle(fontSize: bodyTextSize)),
                          Flexible(
                            child: TextField(
                              controller: _serviceNumberTextFieldController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintText: '请输入服务码',
                                border: InputBorder.none,
                              ),
                              onChanged: (text) {
                                setState(() {
                                  _enteredServiceNumber = text;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: padding16),
                    child: Text(
                      '请向用户索要服务码，服务码可在用户的订单详情处查看',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: colorBodyText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: padding16),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: padding8, right: padding8),
                        child: Row(
                          children: [
                            Text('电池ID',
                                style: TextStyle(fontSize: bodyTextSize)),
                            Flexible(
                              child: TextField(
                                controller: _batteryIDTextFieldController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  hintText: batteryIDHintText,
                                  border: InputBorder.none,
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    _enteredBatteryID = text;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: padding16),
                              child: IconButton(
                                  icon: Icon(
                                    RentingApp.qr_scan,
                                    size: 24,
                                    color: colorBodyText,
                                  ),
                                  onPressed: () async {
                                    try {
                                      var result = await BarcodeScanner.scan();
                                      if (result.type == ResultType.Barcode) {
                                        setState(() {
                                          _batteryIDTextFieldController.text =
                                              result.rawContent;
                                          _enteredBatteryID = result.rawContent;
                                        });
                                      }
                                    } catch (e) {
                                      _scaffoldKey.currentState
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          Util().failureSnackBar('扫描二维码失败'),
                                        );
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      disabledColor: colorDisabled,
                      color: colorPrimary,
                      child: Text('提交'),
                      borderRadius: BorderRadius.zero,
                      onPressed: (_enteredServiceNumber == '' ||
                              _enteredBatteryID == '' ||
                              _isSubmitting)
                          ? null
                          : () async {
                              setState(() {
                                _isSubmitting = true;
                              });
                              try {
                                await HTTP.postWithAuth(
                                    '$baseURL$apiFinishWorkOrder', {
                                  'orderID': order.id,
                                  'serviceNumber': _enteredServiceNumber,
                                  'batteryID': _enteredBatteryID,
                                });
                                _scaffoldKey.currentState
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    Util().successSnackBar('完成工单成功'),
                                  );
                                _serviceNumberTextFieldController.clear();
                                _batteryIDTextFieldController.clear();
                                setState(() {
                                  _enteredServiceNumber = '';
                                  _enteredBatteryID = '';
                                });
                                setState(() {
                                  _isSubmitting = false;
                                });
                                Future.delayed(
                                    Duration(seconds: defaultTimeDelay), () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
                              } catch (e) {
                                setState(() {
                                  _isSubmitting = false;
                                });
                                _scaffoldKey.currentState
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    Util().failureSnackBar(
                                      e
                                          .toString()
                                          .replaceAll('Exception: ', ''),
                                    ),
                                  );
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
