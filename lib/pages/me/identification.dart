// 身份证认证页面
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/widgets/horizontalLine.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/services/http.dart';

class Identification extends StatefulWidget {
  Identification();

  @override
  State<StatefulWidget> createState() => _IdentificationState();
}

class _IdentificationState extends State<Identification> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameTextController = TextEditingController();
  final _idTextController = TextEditingController();
  String _enteredName = '';
  String _enteredID = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameTextController.dispose();
    _idTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authStore = Provider.of<AuthStore>(context, listen: false);
    if (authStore.loggedInUser != null) {
      if (authStore.loggedInUser.idNumber != null &&
          authStore.loggedInUser.idNumber != "") {
        _idTextController.text =
            Util.hideIdNumber(authStore.loggedInUser.idNumber);
      }
      if (authStore.loggedInUser.realname != null &&
          authStore.loggedInUser.realname != "") {
        _nameTextController.text =
            Util.hideRealName(authStore.loggedInUser.realname);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final authStore = Provider.of<AuthStore>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: TitleTopBar(title: '身份认证', canGoBack: true, actionButtons: null),
      body: GestureDetector(
        onTap: () {
          Util().loseFocus(context);
        },
        child: Padding(
          padding: EdgeInsets.all(padding16),
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.only(left: padding8, right: padding8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '姓名',
                        style: TextStyle(fontSize: bodyTextSize),
                      ),
                      Flexible(
                        child: TextField(
                          controller: _nameTextController,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: '请输入本人真实姓名',
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            setState(() {
                              _enteredName = text;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                size: Size(screenWidth, 0),
                painter: HorizontalLine(
                  width: screenWidth - 4 * padding8,
                  horizontalOffset: padding8,
                  topOffset: 0,
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.only(left: padding8, right: padding8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '身份证',
                        style: TextStyle(fontSize: bodyTextSize),
                      ),
                      Flexible(
                        child: TextField(
                          controller: _idTextController,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: '请输入本人身份证号',
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            setState(() {
                              _enteredID = text;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: padding16),
                  child: Text(
                    '仅用于证明您的真实身份，保障您的合法权益，请放心填写',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: colorDisabled),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  disabledColor: colorDisabled,
                  color: colorPrimary,
                  child: Text('提交'),
                  borderRadius: BorderRadius.zero,
                  onPressed:
                      (_enteredName == '' || _enteredID == '' || _isSubmitting)
                          ? null
                          : () async {
                              try {
                                setState(() {
                                  _isSubmitting = true;
                                });
                                await HTTP.postWithAuth(
                                    '$baseURL$apiSubmitIdentification', {
                                  'name': _enteredName,
                                  'identification': _enteredID,
                                });
                                authStore.loggedInUser.idNumber = _enteredID;
                                // 提交实名信息成功
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) {
                                    _scaffoldKey.currentState
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        Util().successSnackBar('身份认证成功'),
                                      );
                                  },
                                );
                                setState(() {
                                  _isSubmitting = false;
                                });
                              } catch (e) {
                                // 提交实名信息失败
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) {
                                    _scaffoldKey.currentState
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        Util().failureSnackBar(
                                          e
                                              .toString()
                                              .replaceAll('Exception: ', ''),
                                        ),
                                      );
                                  },
                                );
                                setState(() {
                                  _isSubmitting = false;
                                });
                              }
                              setState(() {
                                _enteredName = '';
                                _nameTextController.clear();
                                _enteredID = '';
                                _idTextController.clear();
                              });
                              Util().loseFocus(context);
                            },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
