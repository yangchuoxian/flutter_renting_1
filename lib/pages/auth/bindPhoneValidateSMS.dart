import 'package:flutter/cupertino.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/widgets/titles.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/services/util.dart';

import 'dart:async';

class BindPhoneValidateSMS extends StatefulWidget {
  BindPhoneValidateSMS();

  @override
  State<StatefulWidget> createState() => _BindPhoneValidateSMSState();
}

class _BindPhoneValidateSMSState extends State<BindPhoneValidateSMS> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _resendSMSCountdownText = '60';
  String _enteredPhone;
  bool _canResendSMS = false;
  Timer _t;

  @override
  void initState() {
    super.initState();
    final authStore = Provider.of<AuthStore>(context, listen: false);
    _enteredPhone = authStore.enteredPhone;
    int count = 60;
    _t = Timer.periodic(Duration(seconds: 1), (timer) {
      count--;
      setState(() {
        _resendSMSCountdownText = '$count';
      });
      if (count == 0) {
        setState(() {
          _resendSMSCountdownText = '重新发送验证码';
          _canResendSMS = true;
        });
        timer.cancel();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(Util().successSnackBar('发送短信验证码成功'));
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_t != null) {
      _t.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final navigationStore = Provider.of<NavigationStore>(context);

    var titles = Align(
      child: Titles('请输入短信验证码', '短信已发送至$_enteredPhone'),
      alignment: Alignment.centerLeft,
    );
    var resendButton = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          child: Text(
            '$_resendSMSCountdownText',
            style: TextStyle(
              color: colorBodyText,
              fontSize: bodyTextSize,
            ),
          ),
          onPressed: !_canResendSMS
              ? null
              : () async {
                  //
                  if (_t != null) {
                    _t.cancel();
                  }
                  // 向后端请求重新发送验证码
                  var requestData;
                  if (authStore.thirdPartyAuth == wechatAuth) {
                    requestData = {
                      'phoneNumber': authStore.enteredPhone,
                      'thirdPartyAuth': authStore.thirdPartyAuth,
                      'weixinOpenID': authStore.weixinOpenID,
                    };
                  } else if (authStore.thirdPartyAuth == alipayAuth) {
                    requestData = {
                      'phoneNumber': authStore.enteredPhone,
                      'thirdPartyAuth': authStore.thirdPartyAuth,
                      'alipayUserID': authStore.alipayUserID,
                    };
                  }
                  try {
                    await HTTP.post(
                      '$baseURL$apiSendSMSToBindPhone',
                      requestData,
                    );
                    _scaffoldKey.currentState
                      ..hideCurrentSnackBar()
                      ..showSnackBar(Util().successSnackBar('发送短信验证码成功'));
                  } catch (e) {
                    _scaffoldKey.currentState
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        Util().failureSnackBar(
                          e.toString().replaceAll('Exception: ', ''),
                        ),
                      );
                  }
                },
        )
      ],
    );
    var smsInput = Padding(
      padding: const EdgeInsets.only(
        left: padding16,
        right: padding16,
      ),
      child: TextField(
        maxLength: 6,
        onChanged: (inputText) async {
          if (inputText.length == 6) {
            // 向后端发送输入的验证码以完成第三方登录的手机号绑定
            var requestData;
            if (authStore.thirdPartyAuth == wechatAuth) {
              requestData = {
                'phoneNumber': authStore.enteredPhone,
                'thirdPartyAuth': authStore.thirdPartyAuth,
                'weixinOpenID': authStore.weixinOpenID,
                'SMSCode': inputText,
              };
            } else if (authStore.thirdPartyAuth == alipayAuth) {
              requestData = {
                'phoneNumber': authStore.enteredPhone,
                'thirdPartyAuth': authStore.thirdPartyAuth,
                'alipayUserID': authStore.alipayUserID,
                'SMSCode': inputText,
              };
            }
            try {
              var resp = await HTTP.post(
                  '$baseURL$apiValidateSMSToBindPhone', requestData);
              // 登录成功，将手机号、loginToken和用户的uuid保存在disk上用于登录保持
              await Util.setAuthInfo(resp['loginToken'], _enteredPhone, resp['uuid']);
              await Util.submitRegistrationID(authStore.jpushRegistrationID, resp['loginToken'], resp['uuid']);
              // 保存已登录的用户
              authStore.setLoggedInUser(resp);
              // 登录成功后默认显示首页
              navigationStore.selectTab(0, context);
              Navigator.pushNamed(context, RouteSkipAuth);
            } catch (e) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scaffoldKey.currentState
                  ..hideCurrentSnackBar()
                  ..showSnackBar(Util().failureSnackBar('验证失败'));
              });
            }
          }
        },
        keyboardType: TextInputType.number,
        autofocus: true,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: '6位数字',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorBodyText),
          ),
        ),
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar:
          TitleTopBar(title: '', canGoBack: true, actionButtons: <Widget>[]),
      body: GestureDetector(
        onTap: () => Util().loseFocus(context),
        child: Column(
          children: <Widget>[
            titles,
            resendButton,
            smsInput,
          ],
        ),
      ),
    );
  }
}
