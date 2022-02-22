import 'package:flutter/material.dart';
import 'package:flutter_renting/stores/message.store.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/models/message.model.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MessageDetails extends StatefulWidget {
  MessageDetails();
  @override
  State<StatefulWidget> createState() => _MessageDetailsState();
}

class _MessageDetailsState extends State<MessageDetails> {
  Message message;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final messageStore = Provider.of<MessageStore>(context, listen: false);
    message = messageStore.currentMessage;
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = '';
    switch (message.messageType) {
      case MessageType.System:
        pageTitle = '系统消息';
        break;
      case MessageType.Promotion:
        pageTitle = '锂电小贴士';
        break;
      case MessageType.Knowledge:
        pageTitle = '促销信息';
        break;
      default:
        break;
    }

    String readStatus = 'false';
    var popupMenuItem = PopupMenuItem<MessageStatus>(
      value: MessageStatus.unread,
      child: Text('标记为未读'),
    );
    if (message.isUnread != null && message.isUnread == true) {
      readStatus = 'true';
      popupMenuItem = PopupMenuItem<MessageStatus>(
        value: MessageStatus.read,
        child: Text('标记为已读'),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: TitleTopBar(
        title: pageTitle,
        canGoBack: true,
        actionButtons: <Widget>[
          PopupMenuButton(
            onSelected: (value) async {
              // 将消息设置为已读/未读的状态发送给后端
              try {
                await HTTP.postWithAuth('$baseURL$apiMarkAsReadOrUnread', {
                  'messageID': message.id,
                  'read': readStatus,
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scaffoldKey.currentState
                    ..hideCurrentSnackBar()
                    ..showSnackBar(Util().successSnackBar('设置成功'));
                });
                setState(() {
                  if (message.isUnread == null) {
                    message.isUnread = true;
                  } else {
                    message.isUnread = !message.isUnread;
                  }
                });
              } catch (e) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scaffoldKey.currentState
                    ..hideCurrentSnackBar()
                    ..showSnackBar(Util().failureSnackBar(
                        e.toString().replaceAll('Exception: ', '')));
                });
              }
            },
            icon: Icon(RentingApp.vertical_dots),
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<MessageStatus>>[
              popupMenuItem,
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: WebView(
          initialUrl: message.address,
          javascriptMode: JavascriptMode.unrestricted,
          onWebResourceError: (error) {
            print(error);
            print(error.description);
          },
          onPageStarted: (String url) {
            // ycx:::TODO::: 添加loader
          },
          onPageFinished: (String url) {
            // ycx:::TODO::: 停止loader
          },
        ),
      ),
    );
  }
}
