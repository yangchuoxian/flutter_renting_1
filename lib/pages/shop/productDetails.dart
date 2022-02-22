import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/models/product.model.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/stores/product.store.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_renting/services/util.dart';

class ProductDetails extends StatefulWidget {
  ProductDetails();
  @override
  State<StatefulWidget> createState() => _ProductDetailsState();
}

enum ConfirmAction { CANCEL, ACCEPT }
Future<ConfirmAction> _asyncConfirmDialog(BuildContext context) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('实名认证'),
        content: const Text('请填写身份证信息已完成身份认证'),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              '取消',
              style: TextStyle(color: colorDisabled),
            ),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          FlatButton(
            child: Text(
              '确定',
              style: TextStyle(color: Colors.white),
            ),
            color: colorPrimary,
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          )
        ],
      );
    },
  );
}

class _ProductDetailsState extends State<ProductDetails> {
  PageController _pageViewController = PageController();
  double _currentPageIndex = 0.0;
  bool _isLoading = false;

  Widget progressBar() {
    if (_isLoading == true) {
      return LinearProgressIndicator(
        backgroundColor: Colors.lightBlue,
      );
    } else {
      return Container();
    }
  }

  showImagePageView(Product p) {
    if (p.carouselImageURLs.length > 0) {
      var imageViews = <Widget>[];
      for (var cURL in p.carouselImageURLs) {
        imageViews.add(
          ImageView(
            width: double.infinity,
            height: 200.0,
            uri: cURL,
            imageType: ImageType.network,
          ),
        );
      }
      return Container(
        width: double.infinity,
        height: 200.0,
        child: Stack(
          children: [
            PageView(
              controller: _pageViewController,
              children: imageViews,
              onPageChanged: (pageIndex) {
                setState(() {
                  _currentPageIndex = pageIndex.toDouble();
                });
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: DotsIndicator(
                dotsCount: p.carouselImageURLs.length,
                position: _currentPageIndex,
                decorator: DotsDecorator(
                  color: colorGeneralBackground,
                  activeColor: colorPrimary,
                ),
                onTap: (position) {
                  setState(() {
                    _pageViewController.animateToPage(
                      position.toInt(),
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 500),
                    );
                    _currentPageIndex = position;
                  });
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productStore = Provider.of<ProductStore>(context);
    final authStore = Provider.of<AuthStore>(context);
    final navigationStore = Provider.of<NavigationStore>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TitleTopBar(
        title: '商品详情',
        canGoBack: true,
        actionButtons: <Widget>[],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          showImagePageView(productStore.selectedProduct),
          Expanded(
            child: Stack(
              children: <Widget>[
                WebView(
                  initialUrl: Util.replaceHTTPProtocol(productStore.selectedProduct.detailsURL),
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageStarted: (String url) {
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onPageFinished: (String url) {
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
                progressBar(),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(padding16),
              child: CupertinoButton(

                disabledColor: colorDisabled,
                color: colorPrimary,
                child: Text('立刻租赁'),
                borderRadius: BorderRadius.zero,
                onPressed: () async {
                  // 首先检查用户是否登录，如果没有，跳转到登陆界面
                  if (authStore.loggedInUser == null) {
                    Future.delayed(Duration.zero, () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, RouteEnterPhone, (route) => false);
                    });
                    return;
                  }
                  // 检查用户是否已进行实名认证，如果没有，要求实名认证
                  bool hasUserIDVerified =
                      (authStore.loggedInUser.idNumber != "" &&
                          authStore.loggedInUser.idNumber != null);
                  if (!hasUserIDVerified) {
                    final ConfirmAction action =
                        await _asyncConfirmDialog(context);
                    if (action == ConfirmAction.ACCEPT) {
                      Navigator.pushNamed(context, RouteIdentification);
                    }
                  } else {
                    navigationStore.selectAgreementRelatedNavigation(
                        articleTypeRentAgreement, true, RouteRentLength);
                    Navigator.pushNamed(context, RouteAgreement);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
