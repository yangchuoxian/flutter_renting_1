class UserAddress {
  String addressID;
  String userID;
  String location;
  String contactName;
  String phone;
  String latitude;
  String longitude;
  bool isDefault;

  UserAddress({
    this.addressID,
    this.userID,
    this.location,
    this.contactName,
    this.phone,
    this.latitude,
    this.longitude,
    this.isDefault,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    bool isDefault = false;
    if (json['isDefault'] == 'true' || json['isDefault'] == '1' || json['isDefault'] == true) {
      isDefault = true;
    }
    var lat = '', lng = '';
    if (json['lat'] != null && json['lat'] != '') {
      lat = '${json['lat']}';
    }
    if (json['lng'] != null && json['lng'] != '') {
      lng = '${json['lng']}';
    }
    return UserAddress(
      addressID: json['id'],
      userID: json['userID'],
      location: json['location'],
      contactName: json['contactName'],
      phone: json['phone'],
      latitude: lat,
      longitude: lng,
      isDefault: isDefault,
    );
  }
}
