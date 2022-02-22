import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/renting_app_icons.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/widgets/horizontalLine.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

class UserSettings extends StatelessWidget {
  UserSettings();
  final PanelController _pc = PanelController();

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    // retrieve user avatar from authStore
    var showAvatar = () {
      if (authStore.loggedInUser != null) {
        if (authStore.loggedInUser.headImgURL != '') {
          return ImageView(
            width: largeAvatar,
            height: largeAvatar,
            uri: authStore.loggedInUser.headImgURL,
            imageType: ImageType.network,
          );
        }
      }
      return Container(
        decoration: BoxDecoration(
          color: colorDarkGrey,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ImageView(
            width: smallAvatar,
            height: smallAvatar,
            uri: 'assets/images/placeholder.png',
            imageType: ImageType.asset,
          ),
        ),
      );
    };
    var showNickname = () {
      if (authStore.loggedInUser == null) {
        return Text('');
      }
      if (authStore.loggedInUser.nickname == null ||
          authStore.loggedInUser.nickname == '') {
        return Text('');
      }
      authStore.updateNickname(authStore.loggedInUser.nickname);
      return Text(
        '${authStore.nickname}',
        style: TextStyle(color: colorDisabled),
      );
    };
    var listView = Observer(
      builder: (_) => ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: padding16,
              left: padding16,
              right: padding16,
            ),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: ListTile(
                  leading: Text('头像'),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      showAvatar(),
                    ],
                  ),
                  trailing: Icon(RentingApp.chevron_right),
                  onTap: () {
                    _pc.open();
                  }),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: padding16, right: padding16),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: ListTile(
                leading: Text('昵称'),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    showNickname(),
                  ],
                ),
                trailing: Icon(RentingApp.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, RouteNickname);
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: padding16,
              left: padding16,
              right: padding16,
            ),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: ListTile(
                leading: Text('手机号'),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    (authStore.loggedInUser != null &&
                            authStore.loggedInUser.phone != null)
                        ? Text(
                            '${Util.hidePhone(authStore.loggedInUser.phone)}',
                            style: TextStyle(color: colorDisabled),
                          )
                        : Text(''),
                  ],
                ),
                trailing: Icon(RentingApp.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, RouteEnterOldAndNewPhone);
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: padding16,
              right: padding16,
            ),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: ListTile(
                leading: Text('修改密码'),
                trailing: Icon(RentingApp.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, RouteResetPassword);
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: padding16,
              right: padding16,
            ),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: ListTile(
                  leading: Text('地址'),
                  trailing: Icon(RentingApp.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, RouteAddressList);
                  }),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: padding16,
              left: padding16,
              right: padding16,
            ),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '退出登录',
                      style: TextStyle(color: colorFailure),
                    ),
                  ],
                ),
                onTap: () async {
                  Util().logout(authStore);
                  Navigator.pushNamedAndRemoveUntil(
                      context, RouteEnterPhone, (route) => false);
                },
              ),
            ),
          ),
        ],
      ),
    );
    Function pickImageAndUpload = (ImagePickerType pickerType) async {
      File _file;
      final picker = ImagePicker();
      var pickedFile;
      if (pickerType == ImagePickerType.byCamera) {
        pickedFile = await picker.getImage(
          source: ImageSource.camera,
          maxHeight: maxUploadImageSize,
          maxWidth: maxUploadImageSize,
        );
      } else {
        pickedFile = await picker.getImage(
          source: ImageSource.gallery,
          maxHeight: maxUploadImageSize,
          maxWidth: maxUploadImageSize,
        );
      }
      if (pickedFile == null) {
        // 用户取消了选取图片或拍照
        return;
      }
      _file = File(pickedFile.path);
      final prefs = await SharedPreferences.getInstance();
      var userInfo = {
        'uuid': prefs.getString('uuid'),
        'loginToken': prefs.getString('loginToken'),
      };
      var resp = await Util.uploadFile(
        _file,
        '$baseURL$apiUploadAvatar',
        userInfo,
      );
      resp.stream.transform(utf8.decoder).listen((value) {
        var avatarURL = json.decode(value)['uploadedImageURL'];
        if (avatarURL != null) {
          // 上传成功，显示上传的用户头像
          authStore.updateAvatarURL('$baseURL$avatarURL');
        }
        _pc.close();
      });
    };
    final double screenWidth = MediaQuery.of(context).size.width;
    var changeAvatarActionSheet = Container(
      decoration: BoxDecoration(color: Colors.white),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('拍照'),
                ],
              ),
              onTap: () {
                pickImageAndUpload(ImagePickerType.byCamera);
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('从相册中选取'),
                ],
              ),
              onTap: () {
                pickImageAndUpload(ImagePickerType.fromGallery);
              },
            ),
            CustomPaint(
              size: Size(screenWidth, 0),
              painter: HorizontalLine(
                width: screenWidth,
                horizontalOffset: padding16,
                topOffset: 0,
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('取消'),
                ],
              ),
              onTap: () {
                _pc.close();
              },
            ),
          ],
        ),
      ),
    );
    return Material(
      child: SlidingUpPanel(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        renderPanelSheet: false,
        controller: _pc,
        maxHeight: 3 * defaultListTileHeight,
        minHeight: 0,
        backdropEnabled: true,
        panel: changeAvatarActionSheet,
        body: Scaffold(
          backgroundColor: colorGeneralBackground,
          appBar:
              TitleTopBar(title: '个人设置', canGoBack: true, actionButtons: null),
          body: listView,
        ),
      ),
    );
  }
}
