import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: padding8, bottom: padding8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '加载中...',
            style: TextStyle(color: colorDisabled),
          ),
        ],
      ),
    );
  }
}
