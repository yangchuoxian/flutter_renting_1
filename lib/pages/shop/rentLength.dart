import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/stores/order.store.dart';
import 'package:flutter_renting/stores/product.store.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:provider/provider.dart';

class RentLength extends StatefulWidget {
  RentLength();
  @override
  State<StatefulWidget> createState() => _RentLengthState();
}

class _RentLengthState extends State<RentLength> {
  bool _yearSelected = true;
  bool _monthSelected = false;

  @override
  Widget build(BuildContext context) {
    final productStore = Provider.of<ProductStore>(context);
    final orderStore = Provider.of<OrderStore>(context);
    final navigationStore = Provider.of<NavigationStore>(context);
    var selectedProduct = productStore.selectedProduct;
    return Scaffold(
      backgroundColor: colorGeneralBackground,
      appBar: TitleTopBar(
        title: '租赁周期',
        canGoBack: true,
        actionButtons: <Widget>[],
      ),
      body: Padding(
        padding: EdgeInsets.all(padding16),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Padding(
                padding: EdgeInsets.only(left: padding8, right: padding8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Checkbox(
                      activeColor: colorPrimary,
                      value: _yearSelected,
                      onChanged: (bool value) {
                        setState(() {
                          _yearSelected = value;
                          _monthSelected = !value;
                        });
                      },
                    ),
                    Text('年租 ¥${selectedProduct.pricePerYear}元/年'),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Padding(
                padding: EdgeInsets.only(left: padding8, right: padding8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Checkbox(
                      activeColor: colorPrimary,
                      value: _monthSelected,
                      onChanged: (bool value) {
                        setState(() {
                          _monthSelected = value;
                          _yearSelected = !value;
                        });
                      },
                    ),
                    Text('月租 ¥${selectedProduct.pricePerMonth}元/月'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                disabledColor: colorDisabled,
                color: colorPrimary,
                child: Text('下一步'),
                borderRadius: BorderRadius.zero,
                onPressed: () {
                  int orderType;
                  if (_yearSelected) {
                    orderType = orderTypeRentProductYearly;
                  } else {
                    orderType = orderTypeRentProductMonthly;
                  }
                  orderStore.createNewOrder(
                      orderType, productStore.selectedProduct.productID);

                  navigationStore.setServiceLocationParameters(
                      ServiceLocationPlaces.rentingBattery, '联系方式', -1, '下一步');
                  Navigator.pushNamed(context, RouteServiceLocation);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
