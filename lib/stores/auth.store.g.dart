// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AuthStore on _AuthStore, Store {
  final _$enteredPhoneAtom = Atom(name: '_AuthStore.enteredPhone');

  @override
  String get enteredPhone {
    _$enteredPhoneAtom.reportRead();
    return super.enteredPhone;
  }

  @override
  set enteredPhone(String value) {
    _$enteredPhoneAtom.reportWrite(value, super.enteredPhone, () {
      super.enteredPhone = value;
    });
  }

  final _$weixinOpenIDAtom = Atom(name: '_AuthStore.weixinOpenID');

  @override
  String get weixinOpenID {
    _$weixinOpenIDAtom.reportRead();
    return super.weixinOpenID;
  }

  @override
  set weixinOpenID(String value) {
    _$weixinOpenIDAtom.reportWrite(value, super.weixinOpenID, () {
      super.weixinOpenID = value;
    });
  }

  final _$alipayUserIDAtom = Atom(name: '_AuthStore.alipayUserID');

  @override
  String get alipayUserID {
    _$alipayUserIDAtom.reportRead();
    return super.alipayUserID;
  }

  @override
  set alipayUserID(String value) {
    _$alipayUserIDAtom.reportWrite(value, super.alipayUserID, () {
      super.alipayUserID = value;
    });
  }

  final _$thirdPartyAuthAtom = Atom(name: '_AuthStore.thirdPartyAuth');

  @override
  int get thirdPartyAuth {
    _$thirdPartyAuthAtom.reportRead();
    return super.thirdPartyAuth;
  }

  @override
  set thirdPartyAuth(int value) {
    _$thirdPartyAuthAtom.reportWrite(value, super.thirdPartyAuth, () {
      super.thirdPartyAuth = value;
    });
  }

  final _$smsProcessTypeAtom = Atom(name: '_AuthStore.smsProcessType');

  @override
  SMSProcessType get smsProcessType {
    _$smsProcessTypeAtom.reportRead();
    return super.smsProcessType;
  }

  @override
  set smsProcessType(SMSProcessType value) {
    _$smsProcessTypeAtom.reportWrite(value, super.smsProcessType, () {
      super.smsProcessType = value;
    });
  }

  final _$enteredNewPhoneAtom = Atom(name: '_AuthStore.enteredNewPhone');

  @override
  String get enteredNewPhone {
    _$enteredNewPhoneAtom.reportRead();
    return super.enteredNewPhone;
  }

  @override
  set enteredNewPhone(String value) {
    _$enteredNewPhoneAtom.reportWrite(value, super.enteredNewPhone, () {
      super.enteredNewPhone = value;
    });
  }

  final _$finishedReadingUserAgreementAtom =
      Atom(name: '_AuthStore.finishedReadingUserAgreement');

  @override
  bool get finishedReadingUserAgreement {
    _$finishedReadingUserAgreementAtom.reportRead();
    return super.finishedReadingUserAgreement;
  }

  @override
  set finishedReadingUserAgreement(bool value) {
    _$finishedReadingUserAgreementAtom
        .reportWrite(value, super.finishedReadingUserAgreement, () {
      super.finishedReadingUserAgreement = value;
    });
  }

  final _$justSetNewPhoneAtom = Atom(name: '_AuthStore.justSetNewPhone');

  @override
  bool get justSetNewPhone {
    _$justSetNewPhoneAtom.reportRead();
    return super.justSetNewPhone;
  }

  @override
  set justSetNewPhone(bool value) {
    _$justSetNewPhoneAtom.reportWrite(value, super.justSetNewPhone, () {
      super.justSetNewPhone = value;
    });
  }

  final _$justResetPasswordAtom = Atom(name: '_AuthStore.justResetPassword');

  @override
  bool get justResetPassword {
    _$justResetPasswordAtom.reportRead();
    return super.justResetPassword;
  }

  @override
  set justResetPassword(bool value) {
    _$justResetPasswordAtom.reportWrite(value, super.justResetPassword, () {
      super.justResetPassword = value;
    });
  }

  final _$loggedInUserAtom = Atom(name: '_AuthStore.loggedInUser');

  @override
  User get loggedInUser {
    _$loggedInUserAtom.reportRead();
    return super.loggedInUser;
  }

  @override
  set loggedInUser(User value) {
    _$loggedInUserAtom.reportWrite(value, super.loggedInUser, () {
      super.loggedInUser = value;
    });
  }

  final _$avatarURLAtom = Atom(name: '_AuthStore.avatarURL');

  @override
  String get avatarURL {
    _$avatarURLAtom.reportRead();
    return super.avatarURL;
  }

  @override
  set avatarURL(String value) {
    _$avatarURLAtom.reportWrite(value, super.avatarURL, () {
      super.avatarURL = value;
    });
  }

  final _$nicknameAtom = Atom(name: '_AuthStore.nickname');

  @override
  String get nickname {
    _$nicknameAtom.reportRead();
    return super.nickname;
  }

  @override
  set nickname(String value) {
    _$nicknameAtom.reportWrite(value, super.nickname, () {
      super.nickname = value;
    });
  }

  final _$_AuthStoreActionController = ActionController(name: '_AuthStore');

  @override
  void setSetNewPhoneFlag(bool flag) {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.setSetNewPhoneFlag');
    try {
      return super.setSetNewPhoneFlag(flag);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setResetPasswordFlag(bool flag) {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.setResetPasswordFlag');
    try {
      return super.setResetPasswordFlag(flag);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEnteredPhone(String p) {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.setEnteredPhone');
    try {
      return super.setEnteredPhone(p);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSMSProcessType(SMSProcessType t) {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.setSMSProcessType');
    try {
      return super.setSMSProcessType(t);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEnteredNewPhone(String p) {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.setEnteredNewPhone');
    try {
      return super.setEnteredNewPhone(p);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleFinishedReadingUserAgreement() {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.toggleFinishedReadingUserAgreement');
    try {
      return super.toggleFinishedReadingUserAgreement();
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoggedInUser(Map<String, dynamic> json) {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.setLoggedInUser');
    try {
      return super.setLoggedInUser(json);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearLoggedInUser() {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.clearLoggedInUser');
    try {
      return super.clearLoggedInUser();
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateAvatarURL(String url) {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.updateAvatarURL');
    try {
      return super.updateAvatarURL(url);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateNickname(String nn) {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.updateNickname');
    try {
      return super.updateNickname(nn);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
enteredPhone: ${enteredPhone},
weixinOpenID: ${weixinOpenID},
alipayUserID: ${alipayUserID},
thirdPartyAuth: ${thirdPartyAuth},
smsProcessType: ${smsProcessType},
enteredNewPhone: ${enteredNewPhone},
finishedReadingUserAgreement: ${finishedReadingUserAgreement},
justSetNewPhone: ${justSetNewPhone},
justResetPassword: ${justResetPassword},
loggedInUser: ${loggedInUser},
avatarURL: ${avatarURL},
nickname: ${nickname}
    ''';
  }
}
