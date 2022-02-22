import 'package:flutter/material.dart';
import 'package:flutter_renting/models/message.model.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/stores/message.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MessageOutline extends StatelessWidget {
  final Message message;

  MessageOutline({this.message});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double messageContainerWidth = screenWidth - padding16 * 2;
    String formattedDateTime =
        DateFormat('yyyy年MM月dd日 - kk:mm').format(message.when);
    ImageView messageCoverImage = ImageView(
      width: messageContainerWidth,
      height: 140,
      uri: 'assets/images/placeholder.png',
      imageType: ImageType.asset,
    );
    if (message.url != null && message.url != '') {
      messageCoverImage = ImageView(
        width: messageContainerWidth,
        height: 140,
        uri: message.url,
        imageType: ImageType.network,
      );
    }
    Widget imageWithReadStatusDot = Stack(
      children: <Widget>[
        Container(
          child: messageCoverImage,
          decoration: BoxDecoration(color: colorDarkGrey),
        ),
        Positioned(
          right: padding8,
          top: padding8,
          width: padding16,
          height: padding16,
          child: Container(
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: null,
          ),
        ),
      ],
    );
    if (message.isUnread == null || message.isUnread == false) {
      imageWithReadStatusDot = Container(
        child: messageCoverImage,
        decoration: BoxDecoration(color: colorDarkGrey),
      );
    }
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: padding16, bottom: padding8),
            child: Text(
              formattedDateTime,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            width: messageContainerWidth,
            child: Column(
              children: <Widget>[
                imageWithReadStatusDot,
                ListTile(
                  onTap: () {
                    final messageStore = Provider.of<MessageStore>(context, listen: false);
                    messageStore.setCurrentMessage(message);
                    Navigator.pushNamed(context, RouteMessageDetails);
                  },
                  title: Text(Util().showAbbreviatedText(10, message.title),
                      style: TextStyle(color: colorDisabled)),
                  trailing: Icon(RentingApp.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
