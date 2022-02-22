import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/widgets/separator.dart';
import 'package:flutter_renting/widgets/titles.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:tobias/tobias.dart' as tobias;

class EnterPhone extends StatefulWidget {
  EnterPhone();
  @override
  State<StatefulWidget> createState() => _EnterPhoneState();
}

class _EnterPhoneState extends State<EnterPhone> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _doing3rdPartyAuth = false;
  StreamSubscription _wxAuthListener;
  @override
  void initState() {
    super.initState();
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final navigationStore =
        Provider.of<NavigationStore>(context, listen: false);
    _wxAuthListener = fluwx.weChatResponseEventHandler
        .distinct((a, b) => a == b)
        .listen((res) async {
      if (res is fluwx.WeChatAuthResponse) {
        try {
          var resp = await HTTP.post('$baseURL$apiWXUserInfo', {
            'code': res.code,
          });
          setState(() {
            _doing3rdPartyAuth = false;
          });
          if (Util.isValueValid(resp['loginToken']) &&
              Util.isValueValid(resp['phone'])) {
            // 登录成功，将手机号、loginToken和用户的uuid保存在disk上用于登录保持
            await Util.setAuthInfo(resp['loginToken'], resp['phone'], resp['uuid']);
            await Util.submitRegistrationID(authStore.jpushRegistrationID, resp['loginToken'], resp['uuid']);
            // 保存已登录的用户
            authStore.setLoggedInUser(resp);
            // 登录后默认显示首页
            navigationStore.selectTab(0, context);
            Navigator.pushNamed(context, RouteSkipAuth);
          } else {
            // 首次通过微信登录，需要绑定手机号
            authStore.thirdPartyAuth = wechatAuth;
            authStore.weixinOpenID = resp['openid'];
            Navigator.pushNamed(context, RouteBindPhoneAfter3rdPartyAuth);
          }
        } catch (e) {
          setState(() {
            _doing3rdPartyAuth = false;
          });
          _scaffoldKey.currentState
            ..hideCurrentSnackBar()
            ..showSnackBar(
              Util()
                  .failureSnackBar(e.toString().replaceAll('Exception: ', '')),
            );
        }
      }
    });
  }

  @override
  void dispose() {
    if (_wxAuthListener != null) {
      _wxAuthListener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationStore = Provider.of<NavigationStore>(context);
    final authStore = Provider.of<AuthStore>(context);

    if (authStore.justSetNewPhone == true) {
      authStore.setSetNewPhoneFlag(false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState
          ..hideCurrentSnackBar()
          ..showSnackBar(Util().successSnackBar('修改手机号成功，请重新登录'));
      });
    } else if (authStore.justResetPassword == true) {
      authStore.setResetPasswordFlag(false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState
          ..hideCurrentSnackBar()
          ..showSnackBar(Util().successSnackBar('重置密码成功，请重新登录'));
      });
    }

    Widget titles = Align(
      child: Titles('请输入您的手机号', '为了方便进行联系，请输入您的常用手机号吗'),
      alignment: Alignment.centerLeft,
    );
    Widget textInput = Padding(
      padding: const EdgeInsets.only(
        left: padding16,
        right: padding16,
        top: padding64,
      ),
      child: TextFormField(
        initialValue: authStore.enteredPhone,
        maxLength: 11,
        onChanged: (inputText) {
          setState(() {
            authStore.setEnteredPhone(inputText);
          });
        },
        keyboardType: TextInputType.number,
        autofocus: false,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: '请输入手机号码',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorBodyText),
          ),
        ),
      ),
    );
    Widget nextButton = Padding(
      padding: const EdgeInsets.only(
        left: padding16,
        top: padding16,
        right: padding16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          disabledColor: colorDisabled,
          color: colorPrimary,
          child: Text('下一步'),
          borderRadius: BorderRadius.zero,
          onPressed: !Util.isChinaPhoneLegal(authStore.enteredPhone)
              ? null
              : () {
                  if (!authStore.finishedReadingUserAgreement) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('提示'),
                          content: Text('请仔细阅读用户协议并勾选同意'),
                          actions: [
                            CupertinoButton(
                              color: colorPrimary,
                              child: Text('确定'),
                              borderRadius: BorderRadius.zero,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.pushNamed(context, RouteEnterPassword);
                  }
                },
        ),
      ),
    );
    Widget separator = Padding(
      padding: const EdgeInsets.only(top: padding24),
      child: Separator('其它方式登录'),
    );
    Widget thirdPartyLoginButtons = Padding(
      padding: const EdgeInsets.only(top: padding24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 56,
            height: 56,
            child: FlatButton(
              onPressed: _doing3rdPartyAuth
                  ? null
                  : () async {
                      var hasAlipayInstalled = await tobias.isAliPayInstalled();
                      if (!hasAlipayInstalled) {
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(Util().failureSnackBar('请先安装支付宝'));
                        return;
                      }
                      setState(() {
                        _doing3rdPartyAuth = true;
                      });
                      var resp = await HTTP.get('$baseURL$apiAlipayAuthStr');
                      var infoStr = resp
                          .toString()
                          .replaceAll('{infoStr: ', '')
                          .replaceAll('}', '');
                      tobias.aliPayAuth(infoStr).then((value) async {
                        if (value['resultStatus'] == '9000') {
                          var uri = Uri.parse(baseURL + '?' + value['result']);
                          if (uri.queryParameters['result_code'] == '200' &&
                              uri.queryParameters['auth_code'] != '') {
                            try {
                              // 将auth_code和user_id提交给服务端，由服务端送交支付宝后端获取用户信息
                              var resp = await HTTP
                                  .post('$baseURL$apiAlipayUserInfo', {
                                'authCode': uri.queryParameters['auth_code'],
                                'userId': uri.queryParameters['user_id'],
                              });
                              setState(() {
                                _doing3rdPartyAuth = false;
                              });
                              if (Util.isValueValid(resp['loginToken']) &&
                                  Util.isValueValid(resp['phone'])) {
                                // 登录成功，将手机号、loginToken和用户的uuid保存在disk上用于登录保持
                                await Util.setAuthInfo(resp['loginToken'], resp['phone'], resp['uuid']);
                                await Util.submitRegistrationID(authStore.jpushRegistrationID, resp['loginToken'], resp['uuid']);
                                // 保存已登录的用户
                                authStore.setLoggedInUser(resp);
                                // 登录后默认显示首页
                                navigationStore.selectTab(0, context);
                                Navigator.pushNamed(context, RouteSkipAuth);
                              } else {
                                // 首次通过支付宝登录，需要绑定手机号
                                authStore.thirdPartyAuth = alipayAuth;
                                authStore.alipayUserID = resp['alipayUserID'];
                                Navigator.pushNamed(
                                    context, RouteBindPhoneAfter3rdPartyAuth);
                              }
                            } catch (e) {
                              setState(() {
                                _doing3rdPartyAuth = false;
                              });
                              _scaffoldKey.currentState
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  Util().failureSnackBar(e
                                      .toString()
                                      .replaceAll('Exception: ', '')),
                                );
                            }
                          }
                        } else {
                          setState(() {
                            _doing3rdPartyAuth = false;
                          });
                          _scaffoldKey.currentState
                            ..hideCurrentSnackBar()
                            ..showSnackBar(Util().failureSnackBar('支付宝登录失败'));
                        }
                      }).catchError((err) {
                        setState(() {
                          _doing3rdPartyAuth = false;
                        });
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(Util().failureSnackBar('支付宝登录失败'));
                      });
                    },
              color: colorDarkGrey,
              child: Icon(RentingApp.alipay, size: 24, color: Colors.white),
              shape: CircleBorder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: padding24),
            child: SizedBox(
              width: 56,
              height: 56,
              child: FlatButton(
                onPressed: _doing3rdPartyAuth
                    ? null
                    : () async {
                        var hasWechatInstalled = await fluwx.isWeChatInstalled;
                        if (!hasWechatInstalled) {
                          _scaffoldKey.currentState
                            ..hideCurrentSnackBar()
                            ..showSnackBar(Util().failureSnackBar('请先安装微信'));
                          return;
                        }
                        setState(() {
                          _doing3rdPartyAuth = true;
                        });
                        fluwx.sendWeChatAuth(scope: "snsapi_userinfo");
                      },
                color: colorDarkGrey,
                child: Icon(RentingApp.wechat, size: 24, color: Colors.white),
                shape: CircleBorder(),
              ),
            ),
          )
        ],
      ),
    );
    Widget userAgreementCheckboxLine = Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: padding16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Checkbox(
              activeColor: colorPrimary,
              value: authStore.finishedReadingUserAgreement,
              onChanged: (bool value) {
                setState(() {
                  authStore.toggleFinishedReadingUserAgreement();
                });
              },
            ),
            GestureDetector(
              child: Text(
                '我已阅读并同意《用户协议》',
                style: TextStyle(color: colorDarkGrey, fontSize: bodyTextSize),
              ),
              onTap: () {
                Util().loseFocus(context);
                Navigator.pushNamed(context, RouteUserAgreement);
              },
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: TitleTopBar(
        title: '',
        canGoBack: false,
        actionButtons: <Widget>[
          IconButton(
            icon: Icon(RentingApp.cross),
            // 取消登录/注册流程，先逛逛
            onPressed: () {
              navigationStore.selectTab(0, context);
              Navigator.pushNamed(context, RouteSkipAuth);
            },
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => Util().loseFocus(context),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - padding64),
            child: Column(
              children: <Widget>[
                titles,
                textInput,
                nextButton,
                separator,
                Expanded(child: thirdPartyLoginButtons),
                userAgreementCheckboxLine,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
