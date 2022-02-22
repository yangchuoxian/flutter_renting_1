import 'package:mobx/mobx.dart';
import 'package:flutter_renting/models/user.model.dart';
import 'package:flutter_renting/constants.dart';

part 'auth.store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  @observable
  String enteredPhone = '';

  @observable
  String weixinOpenID = '';

  @observable
  String alipayUserID = '';

  @observable
  int thirdPartyAuth;

  @observable
  SMSProcessType smsProcessType;

  @observable
  // 设置新手机号码要用到
  String enteredNewPhone = '';

  @observable
  bool finishedReadingUserAgreement = false;

  @observable
  bool justSetNewPhone = false;

  @observable
  bool justResetPassword = false;

  @observable
  User loggedInUser;

  @observable
  String avatarURL = '';

  @observable
  String nickname = '';

  @observable
  String jpushRegistrationID = '';

  @action
  void setSetNewPhoneFlag(bool flag) {
    justSetNewPhone = flag;
  }

  @action
  void setResetPasswordFlag(bool flag) {
    justResetPassword = flag;
  }

  @action
  void setEnteredPhone(String p) {
    enteredPhone = p;
  }

  @action
  void setSMSProcessType(SMSProcessType t) {
    smsProcessType = t;
  }

  @action void setEnteredNewPhone(String p) {
    enteredNewPhone = p;
  }

  @action
  void toggleFinishedReadingUserAgreement() {
    finishedReadingUserAgreement = !finishedReadingUserAgreement;
  }

  @action
  void setLoggedInUser(Map<String, dynamic> json) {
    loggedInUser = User.fromJson(json);
    if (loggedInUser.headImgURL != '') {
      avatarURL = loggedInUser.headImgURL;
    }
  }

  @action void clearLoggedInUser() {
    loggedInUser = null;
  }

  @action
  void updateAvatarURL(String url) {
    loggedInUser.headImgURL = url;
    avatarURL = url;
  }

  @action
  void updateNickname(String nn) {
    loggedInUser.nickname = nn;
    nickname = nn;
  }

  @action
  void setRegistrationID(String rID) {
    jpushRegistrationID = rID;
  }
}
