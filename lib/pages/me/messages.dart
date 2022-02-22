import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/widgets/messagesTab.dart';
import 'package:flutter_renting/renting_app_icons.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage();

  @override
  State<StatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Tab> messageTabs = <Tab>[
    Tab(text: '系统消息'),
    Tab(text: '锂电小贴士'),
    Tab(text: '优惠促销'),
  ];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: messageTabs.length,
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(RentingApp.chevron_left, color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        title: Text(
          '我的消息',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          indicatorColor: colorPrimary,
          labelColor: Colors.black,
          controller: _tabController,
          tabs: messageTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          MessagesTab(
              messageType: MessageType.System, scaffoldKey: _scaffoldKey),
          MessagesTab(
              messageType: MessageType.Knowledge, scaffoldKey: _scaffoldKey),
          MessagesTab(
              messageType: MessageType.Promotion, scaffoldKey: _scaffoldKey),
        ],
      ),
    );
  }
}
