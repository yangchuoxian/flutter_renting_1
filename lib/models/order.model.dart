import 'package:flutter_renting/models/product.model.dart';

class Order {
  String id;
  String orderNumber;
  int orderType;
  int price;
  int deposit;
  DateTime dueDate;
  DateTime createdAt;
  String relatedProduct; // 商品的ObjectID
  int orderStatus;
  int paymentMethod;
  String thirdPartyPaymentID;
  Product productData;
  String batteryID;
  String serviceNumber;
  String addressID;

  Order({
    this.id,
    this.orderNumber,
    this.orderType,
    this.price,
    this.deposit,
    this.dueDate,
    this.createdAt,
    this.relatedProduct,
    this.orderStatus,
    this.paymentMethod,
    this.thirdPartyPaymentID,
    this.batteryID,
    this.serviceNumber,
    this.addressID,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'],
      orderType: json['type'],
      price: json['price'],
      deposit: json['deposit'],
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
      relatedProduct: json['relatedProduct'],
      orderStatus: json['status'],
      paymentMethod: json['paymentMethod'],
      thirdPartyPaymentID: json['thirdPartyPaymentID'],
      batteryID: json['batteryID'],
      serviceNumber: json['serviceNumber'],
      addressID: json['addressID'],
    );
  }
}
