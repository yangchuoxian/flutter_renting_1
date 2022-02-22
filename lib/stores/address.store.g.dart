// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AddressStore on _AddressStore, Store {
  final _$editingAddressAtom = Atom(name: '_AddressStore.editingAddress');

  @override
  UserAddress get editingAddress {
    _$editingAddressAtom.reportRead();
    return super.editingAddress;
  }

  @override
  set editingAddress(UserAddress value) {
    _$editingAddressAtom.reportWrite(value, super.editingAddress, () {
      super.editingAddress = value;
    });
  }

  final _$_AddressStoreActionController =
      ActionController(name: '_AddressStore');

  @override
  void setEditingAddress(UserAddress ua) {
    final _$actionInfo = _$_AddressStoreActionController.startAction(
        name: '_AddressStore.setEditingAddress');
    try {
      return super.setEditingAddress(ua);
    } finally {
      _$_AddressStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDestinationGeoCoordinates(double lat, double longi) {
    final _$actionInfo = _$_AddressStoreActionController.startAction(
        name: '_AddressStore.setDestinationGeoCoordinates');
    try {
      return super.setDestinationGeoCoordinates(lat, longi);
    } finally {
      _$_AddressStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWorkOrderAddress(UserAddress ua) {
    final _$actionInfo = _$_AddressStoreActionController.startAction(
        name: '_AddressStore.setWorkOrderAddress');
    try {
      return super.setWorkOrderAddress(ua);
    } finally {
      _$_AddressStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
editingAddress: ${editingAddress}
    ''';
  }
}
