import 'package:flutter_renting/constants.dart';

class Message {
  String id;
  DateTime when;
  String title;
  String content;
  String url; 
  String address;
  bool isUnread;
  MessageType messageType;  

  Message({
    this.id,
    this.when,
    this.title,
    this.content,
    this.url,
    this.address,
    this.isUnread,
    this.messageType,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    bool isUnread = json['isUnread'].toString().toLowerCase() == 'true';
    DateTime when = DateTime.parse(json['when']);
    MessageType t = MessageType.values[json['messageType']];
    return Message(
      id: json['id'],
      when: when,
      title: json['title'],
      content: json['content'],
      url: json['url'],
      address: json['address'],
      isUnread: isUnread,
      messageType: t,
    );
  }
}