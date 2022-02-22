import 'package:mobx/mobx.dart';
import 'package:flutter_renting/models/order.model.dart';
import 'package:flutter_renting/models/address.model.dart';

part 'order.store.g.dart';

class OrderStore = _OrderStore with _$OrderStore;

abstract class _OrderStore with Store {
  @observable
  Order newOrder;

  UserAddress orderAddress;

  int serviceOrderType;

  String selectedOrderForService;

  // 在订单列表页面选定订单以显示订单细节
  Order selectedOrderForDetails;

  // 指派给已登录的服务人员的工单
  List<Order> workOrders = <Order>[];

  @action
  void createNewOrder(int orderType, String productID) {
    newOrder = Order(
      orderType: orderType,
      relatedProduct: productID,
    );
  }

  @action
  void setOrderAddress(
    String addressID,
    String location,
    String contactName,
    String phone,
  ) {
    // 新填写的用户地址
    orderAddress = UserAddress(
      addressID: addressID,
      location: location,
      contactName: contactName,
      phone: phone,
    );
  }

  @action
  void setSelectedBattery(String orderID) {
    selectedOrderForService = orderID;
  }

  @action
  void selectOrderForDetails(Order orderToShowDetails) {
    selectedOrderForDetails = orderToShowDetails;
  }

  @action
  void setWorkOrders(List<Order> wos) {
    workOrders = wos;
  }
}
