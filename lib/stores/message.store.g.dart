// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MessageStore on _MessageStore, Store {
  final _$currentMessageAtom = Atom(name: '_MessageStore.currentMessage');

  @override
  Message get currentMessage {
    _$currentMessageAtom.reportRead();
    return super.currentMessage;
  }

  @override
  set currentMessage(Message value) {
    _$currentMessageAtom.reportWrite(value, super.currentMessage, () {
      super.currentMessage = value;
    });
  }

  final _$_MessageStoreActionController =
      ActionController(name: '_MessageStore');

  @override
  void setCurrentMessage(Message m) {
    final _$actionInfo = _$_MessageStoreActionController.startAction(
        name: '_MessageStore.setCurrentMessage');
    try {
      return super.setCurrentMessage(m);
    } finally {
      _$_MessageStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentMessage: ${currentMessage}
    ''';
  }
}
