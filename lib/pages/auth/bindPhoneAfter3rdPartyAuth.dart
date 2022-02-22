import 'package:flutter/cupertino.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/widgets/titles.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class BindPhoneAfter3rdPartyAuth extends StatefulWidget {
  BindPhoneAfter3rdPartyAuth();
  @override
  State<StatefulWidget> createState() => _BindPhoneAfter3rdPartyAuthState();
}

class _BindPhoneAfter3rdPartyAuthState
    extends State<BindPhoneAfter3rdPartyAuth> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);

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
              : () async {
                  if (!authStore.finishedReadingUserAgreement) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('提示'),
                          content: Text('请仔细阅读用户协议并勾选同意'),
                          actions: [
                            CupertinoButton(
                              disabledColor: colorDisabled,
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
                    // 向后端请求发送短信验证码以验证该手机号码
                    try {
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
                      await HTTP.post('$baseURL$apiSendSMSToBindPhone', requestData);
                      Navigator.pushNamed(context, RouteBindPhoneValidateSMS);
                    } catch (e) {
                      _scaffoldKey.currentState
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          Util().failureSnackBar(
                            e.toString().replaceAll('Exception: ', ''),
                          ),
                        );
                    }
                  }
                },
        ),
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
        canGoBack: true,
        actionButtons: <Widget>[],
      ),
      body: GestureDetector(
        onTap: () => Util().loseFocus(context),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 64),
            child: Column(
              children: <Widget>[
                titles,
                textInput,
                nextButton,
                Expanded(child: Container()),
                userAgreementCheckboxLine,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
