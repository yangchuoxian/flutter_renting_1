import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/widgets/titles.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/widgets/titleTopbar.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/util.dart';

class UserAgreement extends StatefulWidget {
  UserAgreement();
  @override
  State<StatefulWidget> createState() => _UserAgreementState();
}

class _UserAgreementState extends State<UserAgreement> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double _webviewHeight;
  WebViewController _webviewController;
  bool _scrolledToBottom = false;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
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

  Future<dynamic> getUserAgreementURL() {
    return HTTP.get(
        '$baseURL$apiGetAgreementURL?articleType=$articleTypeUserAgreement');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: TitleTopBar(
        title: '',
        canGoBack: false,
        actionButtons: <Widget>[
          IconButton(
            icon: Icon(RentingApp.cross),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: padding16),
              child: Titles('用户协议', '欢迎使用万租'),
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                FutureBuilder(
                  future: getUserAgreementURL(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(Util().failureSnackBar('获取用户协议失败'));
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
          SizedBox(
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
                        authStore.toggleFinishedReadingUserAgreement();
                        Navigator.pushNamed(
                            context, RouteFinishedUserAgreement);
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
