// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$OrderStore on _OrderStore, Store {
  final _$newOrderAtom = Atom(name: '_OrderStore.newOrder');

  @override
  Order get newOrder {
    _$newOrderAtom.reportRead();
    return super.newOrder;
  }

  @override
  set newOrder(Order value) {
    _$newOrderAtom.reportWrite(value, super.newOrder, () {
      super.newOrder = value;
    });
  }

  final _$_OrderStoreActionController = ActionController(name: '_OrderStore');

  @override
  void createNewOrder(int orderType, String productID) {
    final _$actionInfo = _$_OrderStoreActionController.startAction(
        name: '_OrderStore.createNewOrder');
    try {
      return super.createNewOrder(orderType, productID);
    } finally {
      _$_OrderStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOrderAddress(
      String addressID, String location, String contactName, String phone) {
    final _$actionInfo = _$_OrderStoreActionController.startAction(
        name: '_OrderStore.setOrderAddress');
    try {
      return super.setOrderAddress(addressID, location, contactName, phone);
    } finally {
      _$_OrderStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedBattery(String orderID) {
    final _$actionInfo = _$_OrderStoreActionController.startAction(
        name: '_OrderStore.setSelectedBattery');
    try {
      return super.setSelectedBattery(orderID);
    } finally {
      _$_OrderStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectOrderForDetails(Order orderToShowDetails) {
    final _$actionInfo = _$_OrderStoreActionController.startAction(
        name: '_OrderStore.selectOrderForDetails');
    try {
      return super.selectOrderForDetails(orderToShowDetails);
    } finally {
      _$_OrderStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWorkOrders(List<Order> wos) {
    final _$actionInfo = _$_OrderStoreActionController.startAction(
        name: '_OrderStore.setWorkOrders');
    try {
      return super.setWorkOrders(wos);
    } finally {
      _$_OrderStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
newOrder: ${newOrder}
    ''';
  }
}
