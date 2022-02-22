import 'package:mobx/mobx.dart';
import 'package:flutter_renting/models/message.model.dart';

part 'message.store.g.dart';

class MessageStore = _MessageStore with _$MessageStore;

abstract class _MessageStore with Store {
  @observable
  Message currentMessage;

  @action
  void setCurrentMessage(Message m) {
    currentMessage = m;
  }
}