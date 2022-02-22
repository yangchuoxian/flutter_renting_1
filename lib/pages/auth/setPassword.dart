import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/widgets/titles.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/util.dart';

class SetPassword extends StatefulWidget {
  SetPassword();
  @override
  State<StatefulWidget> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _enteredPassword = '';
  String _smsType;
  bool _sendingPassword = false;

  @override
  void initState() {
    super.initState();
    final authStore = Provider.of<AuthStore>(context, listen: false);
    if (authStore.smsProcessType == SMSProcessType.loginOrRegistration) {
      _smsType = smsTypeRegistrationOrLogin;
    } else if (authStore.smsProcessType == SMSProcessType.resetPassword) {
      _smsType = smsTypeResetPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationStore = Provider.of<NavigationStore>(context);
    final authStore = Provider.of<AuthStore>(context);
    Widget titles = Align(
      child: Titles('请设置您的登录密码', '之后您便可通过手机号+密码登录'),
      alignment: Alignment.centerLeft,
    );
    Widget passwordInput = Padding(
      padding: const EdgeInsets.only(
        left: padding16,
        right: padding16,
        top: padding64,
      ),
      child: TextField(
        maxLength: 20,
        onChanged: (inputText) async {
          setState(() {
            _enteredPassword = inputText;
          });
        },
        keyboardType: TextInputType.text,
        obscureText: true,
        autofocus: true,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: '6-20位密码，区分大小写',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorBodyText),
          ),
        ),
      ),
    );
    Widget submitButton = Padding(
      padding: const EdgeInsets.only(
        left: padding16,
        right: padding16,
        top: padding16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          disabledColor: colorDisabled,
          color: colorPrimary,
          child: Text('确定'),
          borderRadius: BorderRadius.zero,
          onPressed:
              (!Util.isPasswordValid(_enteredPassword) || _sendingPassword)
                  ? null
                  : () async {
                      // disable submit button
                      setState(() {
                        _sendingPassword = true;
                      });
                      try {
                        await HTTP.postWithAuth('$baseURL$apiSetPassword', {
                          'newPassword': _enteredPassword,
                        });
                        if (_smsType == smsTypeRegistrationOrLogin) {
                          // ************ 登录/注册流程之后的设置密码 ************
                          // 登录成功后默认显示首页
                          navigationStore.selectTab(0, context);
                          Navigator.pushNamed(context, RouteSkipAuth);
                        } else if (_smsType == smsTypeResetPassword) {
                          // ********* 重置密码流程，短信验证通过后的设置密码 *********
                          // 退出登录，回到登录界面，提示用户密码重置成功，需要重新登录
                          Util().logout(authStore);
                          authStore.setResetPasswordFlag(true);
                          Navigator.pushNamedAndRemoveUntil(
                              context, RouteEnterPhone, (route) => false);
                        }
                      } catch (e) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scaffoldKey.currentState
                            ..hideCurrentSnackBar()
                            ..showSnackBar(Util().failureSnackBar(
                                e.toString().replaceAll('Exception: ', '')));
                        });
                      }
                      // enable submit button
                      setState(() {
                        _sendingPassword = false;
                      });
                    },
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
            passwordInput,
            submitButton,
          ],
        ),
      ),
    );
  }
}
