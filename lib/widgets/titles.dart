import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';

class Titles extends StatelessWidget {
  final String mainTitle;
  final String subTitle;

  const Titles(this.mainTitle, this.subTitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              mainTitle,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 24),
            child: Text(
              subTitle,
              style: TextStyle(
                color: Colors.grey,
                fontSize: bodyTextSize,
              ),
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
