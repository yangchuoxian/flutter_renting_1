import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/services/http.dart';

class Nickname extends StatefulWidget {
  Nickname();

  @override
  State<StatefulWidget> createState() => _NicknameState();
}

class _NicknameState extends State<Nickname> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nicknameTextController = TextEditingController();
  String _enteredNickname = '';

  @override
  void dispose() {
    _nicknameTextController.clear();
    _nicknameTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authStore = Provider.of<AuthStore>(context, listen: false);
    if (authStore.loggedInUser != null) {
      if (authStore.loggedInUser.nickname != null &&
          authStore.loggedInUser.nickname != "") {
        _nicknameTextController.text = authStore.loggedInUser.nickname;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: TitleTopBar(title: '昵称', canGoBack: true, actionButtons: null),
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
                        '昵称',
                        style: TextStyle(fontSize: bodyTextSize),
                      ),
                      Flexible(
                        child: TextField(
                          controller: _nicknameTextController,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: '请输入您的昵称',
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            setState(() {
                              _enteredNickname = text;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  disabledColor: colorDisabled,
                  color: colorPrimary,
                  child: Text('提交'),
                  borderRadius: BorderRadius.zero,
                  onPressed: (_enteredNickname == '')
                      ? null
                      : () async {
                          try {
                            await HTTP
                                .postWithAuth('$baseURL$apiUpdateNickname', {
                              'nickname': _enteredNickname,
                            });
                            authStore.updateNickname(_enteredNickname);
                            setState(() {
                              _enteredNickname = '';
                              _nicknameTextController.clear();
                            });
                            Util().loseFocus(context);
                            // 提交昵称成功
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scaffoldKey.currentState
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  Util().successSnackBar('修改昵称成功'),
                                );
                            });
                          } catch (e) {
                            // 提交昵称失败
                            _scaffoldKey.currentState
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                Util().failureSnackBar('修改昵称失败'),
                              );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
