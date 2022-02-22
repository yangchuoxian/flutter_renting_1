import 'package:flutter/material.dart';
import 'package:flutter_renting/widgets/titles.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:provider/provider.dart';

class ImageCaptcha extends StatefulWidget {
  ImageCaptcha();
  @override
  State<StatefulWidget> createState() => _ImageCaptchaState();
}

class _ImageCaptchaState extends State<ImageCaptcha> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _enteredPhone;
  Future<dynamic> _futureImageCaptcha;

  Future<dynamic> _getImageCaptcha() {
    return HTTP.post(
      '$baseURL$apiImageCaptcha',
      {"phoneNumber": _enteredPhone},
    );
  }

  @override
  void initState() {
    super.initState();
    // 在initState中访问store时，必须关闭监听(listen: false)，否则会报错
    final authStore = Provider.of<AuthStore>(context, listen: false);
    if (authStore.smsProcessType == SMSProcessType.loginOrRegistration) {
      _enteredPhone = authStore.enteredPhone;
    } else if (authStore.smsProcessType == SMSProcessType.setNewPhone) {
      _enteredPhone = authStore.enteredNewPhone;
    } else {
      _enteredPhone = authStore.loggedInUser.phone;
    }
    _futureImageCaptcha = _getImageCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    Widget titles = Align(
      child: Titles('请输入图形验证码', '点击图片可刷新'),
      alignment: Alignment.centerLeft,
    );
    Widget futureBuilder = FutureBuilder<dynamic>(
      future: _futureImageCaptcha,
      builder: (context, snapshot) {
        double screenWidth = MediaQuery.of(context).size.width;
        double captchaWidth = screenWidth - padding16 * 2;
        if (snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(color: colorDarkGrey),
            child: ImageView(
              width: captchaWidth,
              height: captchaHeight,
              uri: '$baseURL' + snapshot.data['imageURL'],
              imageType: ImageType.network,
            ),
          );
        }
        if (snapshot.hasError) {
          // handle http exception
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(Util().failureSnackBar('获取图片验证码失败'));
          });
          return Container(
            decoration: BoxDecoration(color: colorDarkGrey),
            child: ImageView(
              width: captchaWidth,
              height: captchaHeight,
              uri: 'assets/images/placeholder.png',
              imageType: ImageType.asset,
            ),
          );
        }
        return Theme(
          data: Theme.of(context).copyWith(accentColor: colorPrimary),
          child: CircularProgressIndicator(),
        );
      },
    );
    Widget showedImageCaptcha = Padding(
      padding: EdgeInsets.only(top: padding16),
      child: GestureDetector(
        onTap: () {
          // 允许点击图片刷新
          setState(() {
            _futureImageCaptcha = _getImageCaptcha();
          });
        },
        child: futureBuilder,
      ),
    );
    Widget textInput = Padding(
      padding: const EdgeInsets.only(
        left: padding16,
        right: padding16,
      ),
      child: TextField(
        maxLength: 4,
        onChanged: (inputText) async {
          if (inputText.length == 4) {
            try {
              await HTTP.post('$baseURL$apiValidateImageCaptcha', {
                "phoneNumber": _enteredPhone,
                "captchaString": inputText,
              });
              Navigator.pushNamed(context, RouteSMSValidation);
            } catch (e) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scaffoldKey.currentState
                  ..hideCurrentSnackBar()
                  ..showSnackBar(Util().failureSnackBar(
                      e.toString().replaceAll('Exception: ', '')));
                setState(() {
                  _futureImageCaptcha = _getImageCaptcha();
                });
              });
            }
          }
        },
        keyboardType: TextInputType.number,
        autofocus: true,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: '4位数字',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorBodyText),
          ),
        ),
      ),
    );

    Widget scaffold = Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar:
          TitleTopBar(title: '', canGoBack: true, actionButtons: <Widget>[]),
      body: GestureDetector(
        onTap: () => Util().loseFocus(context),
        child: Column(
          children: <Widget>[
            titles,
            showedImageCaptcha,
            textInput,
          ],
        ),
      ),
    );
    return scaffold;
  }
}
