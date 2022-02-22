import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:provider/provider.dart';

class EmptyList extends StatelessWidget {
  final String hintText1;
  final String hintText2;
  final String imageURL;
  final int tabIndex;
  final String routeToGo;
  EmptyList(
      {this.hintText1,
      this.hintText2,
      this.imageURL,
      this.tabIndex,
      this.routeToGo})
      : super();

  @override
  Widget build(BuildContext context) {
    final navigationStore =
        Provider.of<NavigationStore>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ImageView(
            width: illustrationSize,
            height: illustrationSize,
            uri: imageURL,
            imageType: ImageType.asset,
          ),
          Padding(
            padding: const EdgeInsets.only(top: padding16),
            child: Text(hintText1),
          ),
          GestureDetector(
            child: Text(
              hintText2,
              style: TextStyle(color: colorPrimary),
            ),
            onTap: () {
              navigationStore.selectTab(tabIndex, context);
              Navigator.pushReplacementNamed(context, routeToGo);
            },
          ),
        ],
      ),
    );
  }
}
