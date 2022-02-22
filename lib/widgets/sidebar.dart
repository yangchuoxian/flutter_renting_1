import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:provider/provider.dart';

class CustomSidebar extends StatefulWidget {
  final List<String> entries;
  final int selectedIndex;

  CustomSidebar({this.entries, this.selectedIndex}) : super();

  @override
  State<StatefulWidget> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  int selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    var navigationStore = Provider.of<NavigationStore>(context);
    List<Widget> entryWidgets = <Widget>[];
    for (var i = 0; i < widget.entries.length; i++) {
      Widget entry;
      if (i == selected) {
        entry = Container(
          width: double.infinity,
          height: 40,
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Container(
                color: colorPrimary,
                width: 2.0,
                height: double.infinity,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${widget.entries[i]}',
                    style: TextStyle(
                      fontSize: titleTextSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        entry = GestureDetector(
          child: Container(
            width: double.infinity,
            height: 40,
            color: Colors.transparent,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Text(
                      '${widget.entries[i]}',
                      style: TextStyle(
                        fontSize: titleTextSize,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            setState(() {
              selected = i;
              navigationStore.selectSidebarEntry(selected);
            });
          },
        );
      }
      entryWidgets.add(entry);
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/sidebar_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      width: sidebarWidth,
      height: double.infinity,
      // color: colorDarkGrey,
      child: Padding(
        padding: EdgeInsets.only(top: padding48, bottom: padding48),
        child: Column(
          children: entryWidgets,
        ),
      ),
    );
  }
}
