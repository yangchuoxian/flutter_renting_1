import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';

class ImageView extends StatelessWidget {
  final double width;
  final double height;
  final String uri;
  final ImageType imageType;

  const ImageView({this.width, this.height, this.uri, this.imageType});

  @override
  Widget build(BuildContext context) {
    if (imageType == ImageType.asset) {
      return Image.asset(
        uri,
        height: height,
        width: width,
        fit: BoxFit.fill,
      );
    } else {
      return Image.network(
        uri,
        height: height,
        width: width,
        fit: BoxFit.fill,
      );
    }
  }
}
