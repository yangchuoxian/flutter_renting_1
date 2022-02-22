import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/models/message.model.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/widgets/loading.dart';
import 'package:flutter_renting/widgets/messageOutline.dart';
import 'package:flutter_renting/services/util.dart';

class MessagesTab extends StatefulWidget {
  final MessageType messageType;
  final GlobalKey<ScaffoldState> scaffoldKey;
  MessagesTab({this.messageType, this.scaffoldKey}) : super();

  @override
  State<StatefulWidget> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  GlobalKey<ScaffoldState> scaffoldKey;
  MessageType messageType;
  int page = 0;
  bool _isLoadingMoreMessages = false;
  bool _hasMore = true;
  List<Message> _messages = <Message>[];
  ScrollController _scrollController = ScrollController();

  void _loadMessages() async {
    if (mounted) {
      setState(() {
        _isLoadingMoreMessages = true;
      });
    }
    int mtype = 0;
    switch (messageType) {
      case MessageType.System:
        mtype = 0;
        break;
      case MessageType.Knowledge:
        mtype = 1;
        break;
      case MessageType.Promotion:
        mtype = 2;
        break;
      default:
        break;
    }
    try {
      var resp = await HTTP.postWithAuth('$baseURL$apiGetMessages', {
        'page': '$page',
        'type': '$mtype',
      });
      var messages = resp['paginatedMessages'];
      var readMessages = resp['readMessages'];
      if (messages == null || messages.length == 0) {
        _hasMore = false;
      } else {
        _hasMore = true;
        List<String> readMessageIDs = <String>[];
        if (readMessages != null) {
          for (var rm in readMessages) {
            readMessageIDs.add(rm['messageID']);
          }
        }
        for (var m in messages) {
          var receivedMessage = Message.fromJson(m);
          if (readMessageIDs.contains(receivedMessage.id)) {
            receivedMessage.isUnread = false;
          } else {
            receivedMessage.isUnread = true;
          }
          _messages.add(receivedMessage);
        }
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scaffoldKey.currentState
          ..hideCurrentSnackBar()
          ..showSnackBar(Util()
              .failureSnackBar(e.toString().replaceAll('Exception: ', '')));
      });
    }
    if (mounted) {
      setState(() {
        _isLoadingMoreMessages = false;
      });
    }
  }

  Widget showLoading() {
    if (_isLoadingMoreMessages) {
      return Loading();
    } else {
      return Padding(
        padding: EdgeInsets.only(top: padding8, bottom: padding8),
        child: Text(' '),
      );
    }
  }

  List<Widget> showMessages() {
    List<Widget> messageOutlines = <Widget>[];
    for (var message in _messages) {
      var mo = MessageOutline(message: message);
      messageOutlines.add(mo);
    }
    return messageOutlines;
  }

  @override
  void initState() {
    super.initState();
    messageType = widget.messageType;
    scaffoldKey = widget.scaffoldKey;

    _loadMessages();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        // 消息的listView滚动到了最底部，开始加载更多消息
        if (_hasMore) {
          page++;
          _loadMessages();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messages.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var messageOutlines = showMessages();
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: messageOutlines,
          ),
        ),
        showLoading(),
      ],
    );
  }
}
