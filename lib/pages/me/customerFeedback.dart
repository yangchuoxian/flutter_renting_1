import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/util.dart';

class CustomerFeedback extends StatefulWidget {
  CustomerFeedback();

  @override
  State<StatefulWidget> createState() => _CustomerFeedbackState();
}

class _CustomerFeedbackState extends State<CustomerFeedback> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _textFieldController = TextEditingController();
  String _enteredFeedback = '';

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textArea = Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: TextField(
            controller: _textFieldController,
            decoration: InputDecoration.collapsed(hintText: '请输入您的宝贵意见'),
            maxLines: 8,
            onChanged: (text) {
              setState(() {
                _enteredFeedback = text;
              });
            },
          ),
        ),
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: TitleTopBar(title: '意见反馈', canGoBack: true, actionButtons: null),
      body: GestureDetector(
        onTap: () {
          Util().loseFocus(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            textArea,
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: padding16),
                child: Text(
                  '您的宝贵意见对我们非常重要，非常感谢',
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding16),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  disabledColor: colorDisabled,
                  color: colorPrimary,
                  child: Text('提交'),
                  borderRadius: BorderRadius.zero,
                  onPressed: _enteredFeedback == ''
                      ? null
                      : () async {
                          try {
                            await HTTP.postWithAuth('$baseURL$apiSubmitFeedback', {
                              'content': _enteredFeedback,
                            });
                            // 提交反馈成功
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) {
                                _scaffoldKey.currentState
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    Util().successSnackBar('提交反馈成功'),
                                  );
                              },
                            );
                          } catch (e) {
                            // 提交反馈失败
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) {
                                _scaffoldKey.currentState
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    Util().failureSnackBar('提交反馈失败'),
                                  );
                              },
                            );
                          }
                          setState(() {
                            _enteredFeedback = '';
                            _textFieldController.clear();
                          });
                          Util().loseFocus(context);
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
