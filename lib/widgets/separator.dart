import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'horizontalLine.dart';

class Separator extends StatelessWidget {
  final String description;
  Separator(this.description);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        CustomPaint(
          size: Size(screenWidth, 20),
          painter: HorizontalLine(
            width: screenWidth,
            horizontalOffset: padding16,
            topOffset: 10,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.only(left: padding16, right: padding16),
              child: Text(
                description,
                style: TextStyle(color: colorDarkGrey, fontSize: bodyTextSize),
              )),
        )
      ],
    );
  }
}
