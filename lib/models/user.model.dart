import 'package:flutter_renting/constants.dart';

class User {
  String username;
  String phone;
  UserRole role;
  String openID;
  Gender sex;
  String headImgURL;
  String nickname;
  String realname;
  String idNumber;

  User({
    this.username,
    this.phone,
    this.role,
    this.openID,
    this.sex,
    this.headImgURL,
    this.nickname,
    this.realname,
    this.idNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    Gender gender = Gender.values[json['sex']];
    UserRole role = UserRole.values[json['role']];
    return User(
      username: json['username'],
      phone: json['phone'],
      role: role,
      openID: json['openid'],
      sex: gender,
      headImgURL: json['headimgurl'],
      nickname: json['nickname'],
      realname: json['realname'],
      idNumber: json['idNumber'],
    );
  }
}