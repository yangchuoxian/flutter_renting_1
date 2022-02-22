import 'package:flutter_renting/models/address.model.dart';
import 'package:mobx/mobx.dart';

part 'address.store.g.dart';

class AddressStore = _AddressStore with _$AddressStore;

abstract class _AddressStore with Store {
  @observable
  UserAddress editingAddress;

  double latitude;
  double longitude;

  UserAddress workOrderAddress;
  bool geoCoordinatesSet = false;

  @action
  void setEditingAddress(UserAddress ua) {
    editingAddress = ua;
  }

  @action
  void setDestinationGeoCoordinates(double lat, double longi) {
    latitude = lat;
    longitude = longi;
    geoCoordinatesSet = true;
  }

  @action
  void setWorkOrderAddress(UserAddress ua) {
    workOrderAddress = ua;
    geoCoordinatesSet = false;
  }
}
