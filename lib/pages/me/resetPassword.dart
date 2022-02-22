import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/widgets/titles.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  ResetPassword();

  @override
  State<StatefulWidget> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _oldPasswordTextController = TextEditingController();
  final _newPasswordTextController = TextEditingController();
  String _enteredOldPassword = '';
  String _enteredNewPassword = '';
  bool _sendingRequest = false;

  @override
  void dispose() {
    _oldPasswordTextController.dispose();
    _newPasswordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    Widget titles = Align(
      child: Titles('重新设置您的登录密码', '密码长度6-20位，区分大小写'),
      alignment: Alignment.centerLeft,
    );
    Widget oldPasswordInput = Padding(
      padding: EdgeInsets.only(
        left: padding16,
        right: padding16,
        top: padding32,
      ),
      child: TextField(
        controller: _oldPasswordTextController,
        maxLength: 20,
        onChanged: (text) {
          setState(() {
            _enteredOldPassword = text;
          });
        },
        keyboardType: TextInputType.text,
        obscureText: true,
        autofocus: true,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          counterText: '',
          hintText: '请输入旧密码',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorBodyText),
          ),
        ),
      ),
    );
    Widget newPasswordInput = Padding(
      padding: EdgeInsets.only(
        left: padding16,
        right: padding16,
        top: padding16,
      ),
      child: TextField(
        controller: _newPasswordTextController,
        maxLength: 20,
        onChanged: (text) {
          setState(() {
            _enteredNewPassword = text;
          });
        },
        keyboardType: TextInputType.text,
        obscureText: true,
        autofocus: true,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          counterText: '',
          hintText: '请输入新密码',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorBodyText),
          ),
        ),
      ),
    );
    Widget forgotPasswordButton = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            authStore.setSMSProcessType(SMSProcessType.resetPassword);
            Navigator.pushNamed(context, RouteImageCaptcha);
          },
          child: Row(
            children: <Widget>[
              Text(
                '忘记密码?',
                style: TextStyle(
                  color: colorBodyText,
                  fontSize: bodyTextSize,
                ),
              ),
              Icon(
                RentingApp.chevron_right,
                color: colorBodyText,
              ),
            ],
          ),
        ),
      ],
    );
    Widget submitButton = Padding(
      padding: EdgeInsets.only(
        left: padding16,
        right: padding16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: colorPrimary,
          child: Text('确定'),
          disabledColor: colorDisabled,
          borderRadius: BorderRadius.zero,
          onPressed: (!Util.isPasswordValid(_enteredOldPassword) ||
                  !Util.isPasswordValid(_enteredNewPassword) ||
                  (_enteredOldPassword == _enteredNewPassword) ||
                  _sendingRequest)
              ? null
              : () async {
                  setState(() {
                    _sendingRequest = true;
                  });
                  try {
                    await HTTP.postWithAuth('$baseURL$apiResetPassword', {
                      'oldPassword': _enteredOldPassword,
                      'newPassword': _enteredNewPassword,
                    });
                    // 修改密码成功，退出登录，回到登陆界面
                    _enteredOldPassword = '';
                    _oldPasswordTextController.clear();
                    _enteredNewPassword = '';
                    _newPasswordTextController.clear();
                    await Util().logout(authStore);
                    authStore.setResetPasswordFlag(true);
                    Navigator.pushNamedAndRemoveUntil(context, RouteEnterPhone, (route) => false);
                  } catch (e) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scaffoldKey.currentState
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          Util().failureSnackBar(
                            e.toString().replaceAll('Exception: ', ''),
                          ),
                        );
                    });
                  }
                  setState(() {
                    _sendingRequest = false;
                  });
                },
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: TitleTopBar(
        title: '重置密码',
        canGoBack: true,
        actionButtons: null,
      ),
      body: Column(
        children: <Widget>[
          titles,
          oldPasswordInput,
          newPasswordInput,
          forgotPasswordButton,
          submitButton,
        ],
      ),
    );
  }
}
