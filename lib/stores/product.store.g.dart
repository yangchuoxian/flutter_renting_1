// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ProductStore on _ProductStore, Store {
  final _$selectedProductAtom = Atom(name: '_ProductStore.selectedProduct');

  @override
  Product get selectedProduct {
    _$selectedProductAtom.reportRead();
    return super.selectedProduct;
  }

  @override
  set selectedProduct(Product value) {
    _$selectedProductAtom.reportWrite(value, super.selectedProduct, () {
      super.selectedProduct = value;
    });
  }

  final _$_ProductStoreActionController =
      ActionController(name: '_ProductStore');

  @override
  void selectProduct(Product p) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.selectProduct');
    try {
      return super.selectProduct(p);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedProduct: ${selectedProduct}
    ''';
  }
}
