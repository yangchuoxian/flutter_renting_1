import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/widgets/titles.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:provider/provider.dart';

class EnterOldAndNewPhone extends StatefulWidget {
  EnterOldAndNewPhone();

  @override
  State<StatefulWidget> createState() => _EnterOldAndNewPhoneState();
}

class _EnterOldAndNewPhoneState extends State<EnterOldAndNewPhone> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _enteredOldPhone = '';
  String _enteredNewPhone = '';

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    Widget titles = Align(
      child: Titles('请输入旧手机号和新手机号', '请确保您的新手机号能够接收到短信'),
      alignment: Alignment.centerLeft,
    );
    Widget oldPhoneInput = Padding(
      padding: EdgeInsets.only(
        left: padding16,
        right: padding16,
        top: padding32,
      ),
      child: TextField(
        maxLength: 11,
        onChanged: (text) {
          setState(() {
            _enteredOldPhone = text;
          });
        },
        keyboardType: TextInputType.number,
        autofocus: true,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: '请输入之前使用的手机号',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorBodyText),
          ),
        ),
      ),
    );
    Widget newPhoneInput = Padding(
      padding:
          EdgeInsets.only(left: padding16, right: padding16, top: padding16),
      child: TextField(
        maxLength: 11,
        onChanged: (text) {
          setState(() {
            _enteredNewPhone = text;
          });
        },
        keyboardType: TextInputType.number,
        autofocus: true,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: '请输入新的手机号',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorBodyText),
          ),
        ),
      ),
    );
    Widget nextButton = Padding(
      padding: EdgeInsets.only(
        left: padding16,
        right: padding16,
        top: padding16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          disabledColor: colorDisabled,
          color: colorPrimary,
          child: Text('下一步'),
          borderRadius: BorderRadius.zero,
          onPressed: !Util.isChinaPhoneLegal(_enteredOldPhone) ||
                  !Util.isChinaPhoneLegal(_enteredNewPhone) ||
                  (_enteredOldPhone == _enteredNewPhone)
              ? null
              : () async {
                  try {
                    await HTTP
                        .postWithAuth('$baseURL$apiValidateOldPhoneToSetNewPhone', {
                      'oldPhone': _enteredOldPhone,
                      'newPhone': _enteredNewPhone,
                    });
                    authStore.setEnteredNewPhone(_enteredNewPhone);
                    authStore.setSMSProcessType(SMSProcessType.setNewPhone);
                    // 验证旧手机和新手机成功，显示图片验证码
                    Navigator.pushNamed(context, RouteImageCaptcha);
                  } catch (e) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scaffoldKey.currentState
                        ..hideCurrentSnackBar()
                        ..showSnackBar(Util().failureSnackBar('验证失败'));
                    });
                  }
                },
        ),
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: TitleTopBar(title: '', canGoBack: true, actionButtons: null),
      body: GestureDetector(
        onTap: () => Util().loseFocus(context),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 64),
            child: Column(
              children: <Widget>[
                titles,
                oldPhoneInput,
                newPhoneInput,
                nextButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
