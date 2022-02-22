import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/stores/address.store.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/services/http.dart';

class UpdateAddress extends StatefulWidget {
  UpdateAddress();

  @override
  State<StatefulWidget> createState() => _UpdateAddressState();
}

class _UpdateAddressState extends State<UpdateAddress> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _addressTextController;
  TextEditingController _contactNameTextController;
  TextEditingController _phoneTextController;
  String _enteredAddress = '';
  String _enteredContactName = '';
  String _enteredPhone = '';
  String _addressID = '';
  bool _isDefault = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressTextController.clear();
    _addressTextController.dispose();
    _contactNameTextController.clear();
    _contactNameTextController.dispose();
    _phoneTextController.clear();
    _phoneTextController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final addressStore = Provider.of<AddressStore>(context, listen: false);
    _enteredAddress = addressStore.editingAddress.location;
    _enteredContactName = addressStore.editingAddress.contactName;
    _enteredPhone = addressStore.editingAddress.phone;
    _isDefault = addressStore.editingAddress.isDefault;

    _addressTextController = TextEditingController(text: _enteredAddress);
    _contactNameTextController =
        TextEditingController(text: _enteredContactName);
    _phoneTextController = TextEditingController(text: _enteredPhone);
    _addressID = addressStore.editingAddress.addressID;
  }

  @override
  Widget build(BuildContext context) {
    Widget addressInput = Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Padding(
        padding: EdgeInsets.only(
          left: padding8,
          right: padding8,
        ),
        child: TextField(
          controller: _addressTextController,
          textAlign: TextAlign.start,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '请输入您的地址，以方便我们的后续服务',
            border: InputBorder.none,
          ),
          onChanged: (text) {
            setState(() {
              _enteredAddress = text;
            });
          },
        ),
      ),
    );
    Widget contactNameInput = Padding(
      padding: EdgeInsets.only(top: padding16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(
            left: padding8,
            right: padding8,
          ),
          child: Row(
            children: <Widget>[
              Text(
                '联系人',
                style: TextStyle(fontSize: bodyTextSize),
              ),
              Flexible(
                child: TextField(
                  controller: _contactNameTextController,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: '请输入联系人名称',
                    border: InputBorder.none,
                  ),
                  onChanged: (text) {
                    _enteredContactName = text;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Widget phoneInput = Padding(
      padding: EdgeInsets.only(top: padding16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(
            left: padding8,
            right: padding8,
          ),
          child: Row(
            children: <Widget>[
              Text(
                '手机',
                style: TextStyle(fontSize: bodyTextSize),
              ),
              Flexible(
                child: TextField(
                  controller: _phoneTextController,
                  textAlign: TextAlign.end,
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '请输入手机号码',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (inputText) {
                    setState(() {
                      _enteredPhone = inputText;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Widget defaultAddressSwitch = Padding(
      padding: EdgeInsets.only(top: padding16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(
            left: padding8,
            right: padding8,
          ),
          child: Row(
            children: <Widget>[
              Text(
                '设为默认地址',
                style: TextStyle(fontSize: bodyTextSize),
              ),
              Expanded(
                child: Container(),
              ),
              CupertinoSwitch(
                value: _isDefault,
                onChanged: (v) {
                  setState(() {
                    _isDefault = v;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
    var validateInput = () {
      if (_enteredAddress == '' ||
          _enteredPhone == '' ||
          _enteredContactName == '') {
        return false;
      }
      if (!Util.isChinaPhoneLegal(_enteredPhone)) {
        return false;
      }
      return true;
    };
    Widget submitButton = SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        disabledColor: colorDisabled,
        color: colorPrimary,
        child: Text('提交'),
        borderRadius: BorderRadius.zero,
        onPressed: ((!validateInput()) || _isSubmitting)
            ? null
            : () async {
                setState(() {
                  _isSubmitting = true;
                });
                try {
                  await HTTP.postWithAuth('$baseURL$apiUpdateAddress', {
                    'addressID': _addressID,
                    'contactName': _enteredContactName,
                    'phone': _enteredPhone,
                    'location': _enteredAddress,
                    'isDefault': _isDefault ? '1' : '0',
                  });
                  setState(() {
                    _enteredAddress = '';
                    _addressTextController.clear();
                    _enteredContactName = '';
                    _contactNameTextController.clear();
                    _enteredPhone = '';
                    _phoneTextController.clear();
                    _isDefault = false;
                    _isSubmitting = false;
                  });
                  // 创建新地址成功
                  _scaffoldKey.currentState
                    ..hideCurrentSnackBar()
                    ..showSnackBar(Util().successSnackBar('修改地址成功'));
                } catch (e) {
                  setState(() {
                    _isSubmitting = false;
                  });
                  // 创建新地址失败
                  _scaffoldKey.currentState
                    ..hideCurrentSnackBar()
                    ..showSnackBar(Util().failureSnackBar(
                      e.toString().replaceAll('Exception: ', ''),
                    ));
                }
              },
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: TitleTopBar(
        title: '编辑地址',
        canGoBack: true,
        actionButtons: null,
      ),
      body: GestureDetector(
        onTap: () {
          Util().loseFocus(context);
        },
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - padding64 - padding16),
            child: Padding(
              padding: EdgeInsets.all(padding16),
              child: Column(
                children: <Widget>[
                  addressInput,
                  contactNameInput,
                  phoneInput,
                  defaultAddressSwitch,
                  Expanded(child: Container()),
                  submitButton,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
