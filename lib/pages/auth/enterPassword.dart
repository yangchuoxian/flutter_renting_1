import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/widgets/titles.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/services/http.dart';

class EnterPassword extends StatefulWidget {
  EnterPassword();
  @override
  State<StatefulWidget> createState() => _EnterPasswordState();
}

class _EnterPasswordState extends State<EnterPassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _enteredPhone;
  String _enteredPassword = '';
  bool _sendingLoginRequest = false;

  @override
  void initState() {
    super.initState();
    _enteredPhone = Provider.of<AuthStore>(context, listen: false).enteredPhone;
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final navigationStore = Provider.of<NavigationStore>(context);
    Widget titles = Align(
      child: Titles('请输入您的密码', '请使用账号密码登录'),
      alignment: Alignment.centerLeft,
    );
    Widget textInput = Padding(
      padding: const EdgeInsets.only(
        left: padding16,
        right: padding16,
        top: padding64,
      ),
      child: TextField(
        maxLength: 20,
        onChanged: (inputText) {
          setState(() => _enteredPassword = inputText);
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
        top: padding16,
        right: padding16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: colorPrimary,
          child: Text('确定'),
          disabledColor: colorDisabled,
          borderRadius: BorderRadius.zero,
          onPressed: (!Util.isPasswordValid(_enteredPassword) ||
                  _sendingLoginRequest)
              ? null
              : () async {
                  setState(() {
                    _sendingLoginRequest = true;
                  });
                  try {
                    var resp =
                        await HTTP.post('$baseURL$apiLoginWithPassword', {
                      'phoneNumber': _enteredPhone,
                      'password': _enteredPassword,
                    });
                    // 登录成功，将手机号、loginToken和用户的uuid保存在disk上用于登录保持
                    await Util.setAuthInfo(resp['loginToken'], _enteredPhone, resp['uuid']);
                    await Util.submitRegistrationID(authStore.jpushRegistrationID, resp['loginToken'], resp['uuid']);
                    // 保存已登录的用户
                    authStore.setLoggedInUser(resp);
                    // 登录后默认显示首页
                    navigationStore.selectTab(0, context);
                    Navigator.pushNamed(context, RouteSkipAuth);
                  } catch (e) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) {
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            Util().failureSnackBar(
                              e.toString().replaceAll('Exception: ', ''),
                            ),
                          );
                      },
                    );
                  }
                  setState(() {
                    _sendingLoginRequest = false;
                  });
                },
        ),
      ),
    );

    Widget loginViaSMSButton = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            authStore.setSMSProcessType(SMSProcessType.loginOrRegistration);
            Navigator.pushNamed(context, RouteImageCaptcha);
          },
          child: Row(
            children: <Widget>[
              Text(
                '验证码登录',
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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: TitleTopBar(
        title: '',
        canGoBack: true,
        actionButtons: <Widget>[],
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
                submitButton,
                loginViaSMSButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
