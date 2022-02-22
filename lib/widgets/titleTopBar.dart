import 'package:flutter/material.dart';
import 'package:flutter_renting/renting_app_icons.dart';

class TitleTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool canGoBack;
  final List<Widget> actionButtons;
  TitleTopBar({
    this.title,
    this.canGoBack,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    if (canGoBack) {
      Widget leading = IconButton(
        icon: Icon(
          RentingApp.chevron_left,
          color: Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      );
      return AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: leading,
        actions: actionButtons,
      );
    } else {
      return AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: actionButtons,
      );
    }
  }

  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }
}
