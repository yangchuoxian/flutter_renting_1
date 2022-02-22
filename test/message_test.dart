import 'package:flutter_renting/constants.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:flutter_renting/models/message.model.dart';

void main() {
  test('A Message model should initialized', () {
    var currentTime = DateTime.now();
    final message = Message.fromJson(<String, dynamic>{
      'when': currentTime.toString(),
      'title': 'Test knowledge message',
      'content': 'This is just a short message for testing purpose',
      'url': 'http://baidu.com',
      'isUnread': 'true',
      'messageType': 2,
    });
    expect(message.title, 'Test knowledge message');
    expect(message.when, currentTime);
    expect(message.isUnread, true);
    print(DateFormat('yyyy年MM月dd日 - kk:mm').format(message.when));
    expect(message.messageType, MessageType.Knowledge);
  });
}