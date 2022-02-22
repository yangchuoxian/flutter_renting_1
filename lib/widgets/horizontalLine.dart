import 'package:flutter/cupertino.dart';

class HorizontalLine extends CustomPainter {
  final double width;
  final double horizontalOffset;
  final double topOffset;

  HorizontalLine({
    this.width,
    this.horizontalOffset,
    this.topOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(horizontalOffset, topOffset),
      Offset(width - horizontalOffset, topOffset),
    ];
    final paint = Paint()
      ..color = CupertinoColors.separator
      ..strokeWidth = 1;
    canvas.drawLine(points[0], points[1], paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
