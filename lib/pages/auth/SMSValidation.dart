import 'package:flutter/material.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/widgets/titles.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/services/util.dart';

import 'dart:async';

class SMSValidation extends StatefulWidget {
  SMSValidation();
  @override
  State<StatefulWidget> createState() => _SMSValidationState();
}

class _SMSValidationState extends State<SMSValidation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _enteredPhone;
  String _smsType;
  String _resendSMSCountdownText = '60';
  bool _canResendSMS = false;
  Timer _t;

  void askForSMSCode() {
    HTTP.post(
      '$baseURL$apiSMSCode',
      {"phoneNumber": _enteredPhone, "type": _smsType},
    ).then((value) {
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
      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(Util().successSnackBar('发送短信验证码成功'));
    }).catchError((e) {
      setState(() {
        _resendSMSCountdownText = '重新发送短信';
        _canResendSMS = true;
      });
      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(Util().failureSnackBar('发送短信验证码失败'));
    });
  }

  @override
  void initState() {
    super.initState();
    final authStore = Provider.of<AuthStore>(context, listen: false);
    if (authStore.smsProcessType == SMSProcessType.loginOrRegistration) {
      _enteredPhone = authStore.enteredPhone;
      _smsType = smsTypeRegistrationOrLogin;
    } else if (authStore.smsProcessType == SMSProcessType.setNewPhone) {
      _enteredPhone = authStore.enteredNewPhone;
      _smsType = smsTypeSetNewPhone;
    } else {
      _enteredPhone = authStore.loggedInUser.phone;
      _smsType = smsTypeResetPassword;
    }
    askForSMSCode();
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
    final navigationStore = Provider.of<NavigationStore>(context);
    final authStore = Provider.of<AuthStore>(context);
    var titles = Align(
      child: Titles('请输入短信验证码', '短信已发送至$_enteredPhone'),
      alignment: Alignment.centerLeft,
    );

    Widget resendButton = Row(
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
              : () {
                  // 重新发送验证码，重新发送验证码需要再次输入图片验证码
                  if (_t != null) {
                    _t.cancel();
                  }
                  Navigator.pop(context);
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
            try {
              if (_smsType == smsTypeRegistrationOrLogin) {
                // ****************** 登录/注册流程的验证短信 ******************
                var resp = await HTTP
                    .post('$baseURL$apiValidateSMSCodeForLoginOrRegistration', {
                  "phoneNumber": _enteredPhone,
                  "SMSCode": inputText,
                });
                // 登录成功，将手机号、loginToken和用户的uuid保存在disk上用于登录保持
                await Util.setAuthInfo(resp['loginToken'], _enteredPhone, resp['uuid']);
                await Util.submitRegistrationID(authStore.jpushRegistrationID, resp['loginToken'], resp['uuid']);
                // 保存已登录的用户
                authStore.setLoggedInUser(resp);
                // 短信验证成功，如果这是用户第一次登录，也就是用户注册，跳转到设置密码界面，否则直接进入app的首页
                if (resp['shouldSetPassword'] == true) {
                  Navigator.pushNamed(context, RouteSetPassword);
                } else {
                  // 登录成功后默认显示首页
                  navigationStore.selectTab(0, context);
                  Navigator.pushNamed(context, RouteSkipAuth);
                }
              } else if (_smsType == smsTypeSetNewPhone) {
                // ****************** 修改手机号流程的验证短信 ******************
                await HTTP.postWithAuth('$baseURL$apiValidateSMSCodeForSetNewPhone', {
                  'phone': _enteredPhone,
                  'SMSCode': inputText,
                  'type': _smsType,
                });
                // 设置新手机号成功，退出登录，重新回到登录界面，然后显示snackbar
                Util().logout(authStore);
                authStore.setSetNewPhoneFlag(true);
                Navigator.pushNamedAndRemoveUntil(
                    context, RouteEnterPhone, (route) => false);
              } else if (_smsType == smsTypeResetPassword) {
                await HTTP.postWithAuth('$baseURL$apiValidateSMSCodeForResetPassword', {
                  'phone': _enteredPhone,
                  'SMSCode': inputText,
                  'type': _smsType,
                });
                // 用短信重置密码时的短信验证码验证成功，接下来跳转到输入新密码的界面
                Navigator.pushNamed(context, RouteSetPassword);
              }
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
