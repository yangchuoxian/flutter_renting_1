import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';

class TabTopBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> entries;
  final List<String> routes;
  final int selectedIndex;

  TabTopBar({this.entries, this.routes, this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    List<Widget> entryWidgets = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      Widget entry;
      if (i == selectedIndex) {
        entry = Column(
          children: <Widget>[
            Container(
              width: 56.0,
              height: kToolbarHeight - 2,
              child: Center(
                child: Text(
                  '${entries[i]}',
                  style: TextStyle(
                    fontSize: titleTextSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              color: colorPrimary,
              width: 56.0,
              height: 2.0,
            ),
          ],
        );
      } else {
        entry = GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, routes[i]);
          },
          child: Column(
            children: <Widget>[
              Container(
                width: kToolbarHeight,
                height: kToolbarHeight,
                child: Center(
                  child: Text(
                    '${entries[i]}',
                    style: TextStyle(
                      fontSize: bodyTextSize,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Divider(height: 2.0, color: colorPrimary),
            ],
          ),
        );
      }
      entryWidgets.add(entry);
    }
    return Container(
      width: double.infinity,
      height: kToolbarHeight,
      child: Row(children: entryWidgets),
    );
  }

  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }
}
