import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/services/util.dart';

class Agreement extends StatefulWidget {
  Agreement();

  @override
  State<StatefulWidget> createState() => _AgreementState();
}

class _AgreementState extends State<Agreement> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double _webviewHeight;
  WebViewController _webviewController;
  bool _scrolledToBottom = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> getAgreementURL(int articleType) {
    return HTTP.get('$baseURL$apiGetAgreementURL?articleType=$articleType');
  }

  Widget progressBar() {
    if (_isLoading == true) {
      return LinearProgressIndicator(
        backgroundColor: Colors.lightBlue,
      );
    } else {
      return Container();
    }
  }

  Widget build(BuildContext context) {
    final navigationStore = Provider.of<NavigationStore>(context);
    String title;
    switch (navigationStore.selectedAgreementType) {
      case articleTypeUserAgreement:
        title = '用户协议';
        break;
      case articleTypeServiceAgreement:
        title = '服务政策';
        break;
      case articleTypeRentAgreement:
        title = '租赁协议';
        break;
      default:
        break;
    }
    Widget nextButtonOrNull;
    if (navigationStore.hasNextAfterFinishedReadingAgreement) {
      nextButtonOrNull = SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(padding16),
          child: CupertinoButton(
            disabledColor: colorDisabled,
            color: colorPrimary,
            child: Text('已阅'),
            borderRadius: BorderRadius.zero,
            onPressed: !_scrolledToBottom
                ? null
                : () {
                    Navigator.pushNamed(context,
                        navigationStore.nextRouteAfterFinishedReadingAgreement);
                  },
          ),
        ),
      );
    } else {
      nextButtonOrNull = Container();
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: TitleTopBar(
        title: title,
        canGoBack: true,
        actionButtons: <Widget>[],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                FutureBuilder(
                  future:
                      getAgreementURL(navigationStore.selectedAgreementType),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(Util().failureSnackBar('获取协议失败'));
                      });
                      return Container();
                    }
                    if (snapshot.hasData) {
                      return WebView(
                        initialUrl: snapshot.data['url'],
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated: (controller) {
                          _webviewController = controller;
                        },
                        onPageStarted: (String url) {
                          setState(() {
                            _isLoading = true;
                          });
                        },
                        onPageFinished: (String url) async {
                          setState(() {
                            _isLoading = false;
                          });
                          final scrollHeight =
                              await _webviewController?.evaluateJavascript(
                                  '(() => document.body.scrollHeight)();');
                          if (scrollHeight != null) {
                            _webviewHeight = double.parse(scrollHeight);
                          }
                        },
                        gestureNavigationEnabled: true,
                        gestureRecognizers: Set()
                          ..add(
                            Factory<VerticalDragGestureRecognizer>(
                              () {
                                return VerticalDragGestureRecognizer()
                                  ..onDown = (DragDownDetails details) async {
                                    var yOffsetStr = await _webviewController
                                        .evaluateJavascript(
                                            '(() => window.pageYOffset)();');
                                    var windowHeightStr =
                                        await _webviewController
                                            .evaluateJavascript(
                                                '(() => window.innerHeight)();');
                                    if (yOffsetStr != null &&
                                        windowHeightStr != null &&
                                        _webviewHeight != null) {
                                      var yOffset = double.parse(yOffsetStr);
                                      var windowHeight =
                                          double.parse(windowHeightStr);
                                      if ((yOffset + windowHeight) >=
                                          (_webviewHeight - padding64)) {
                                        // scrolled to bottom
                                        setState(() {
                                          _scrolledToBottom = true;
                                        });
                                      }
                                    }
                                  };
                              },
                            ),
                          ),
                      );
                    }
                    return Container();
                  },
                ),
                progressBar(),
              ],
            ),
          ),
          nextButtonOrNull,
        ],
      ),
    );
  }
}
