import 'package:mobx/mobx.dart';
import 'package:flutter_renting/models/product.model.dart';

part 'product.store.g.dart';

class ProductStore = _ProductStore with _$ProductStore;

abstract class _ProductStore with Store {
  @observable
  Product selectedProduct;

  @action
  void selectProduct(Product p) {
    selectedProduct = p;
  }
}