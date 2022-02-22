import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:provider/provider.dart';

class SubmitOrderSucceeded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navigationStore = Provider.of<NavigationStore>(context);
    Future.delayed(const Duration(seconds: defaultTimeDelay), () {
      Navigator.pushReplacementNamed(context, RouteAfterSubmitOrderSucceeded);
      navigationStore.selectTab(0, context);
    });
    return Scaffold(
      appBar: TitleTopBar(
        title: '提交成功',
        canGoBack: false,
        actionButtons: <Widget>[],
      ),
      body: Column(
        children: [
          ImageView(
            width: double.infinity,
            height: 207.0,
            uri: 'assets/images/payment_succeeded.png',
            imageType: ImageType.asset,
          ),
          Padding(
            padding: const EdgeInsets.only(top: padding32),
            child: Center(
              child: Text('提交订单成功，服务人员将会马上联系您'),
            ),
          ),
        ],
      ),
    );
  }
}
