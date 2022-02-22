import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_renting/widgets/titleTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/models/faq.model.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQ extends StatefulWidget {
  FAQ();

  @override
  State<StatefulWidget> createState() => _FAQState();
}

class _FAQState extends State<FAQ> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<dynamic> _futureFAQs;

  Future<dynamic> _getFAQs() {
    return HTTP.get('$baseURL$apiListFAQs');
  }

  @override
  void initState() {
    super.initState();
    _futureFAQs = _getFAQs();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = FutureBuilder<dynamic>(
      future: _futureFAQs,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          CustomerFAQ faq;
          var faqWidgets = <Widget>[];
          for (var faqJson in snapshot.data) {
            faq = CustomerFAQ.fromJson(faqJson);
            var faqWidget = Padding(
              padding: EdgeInsets.only(bottom: padding16),
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Theme(
                  data: ThemeData(accentColor: colorPrimary),
                  child: ExpansionTile(
                    title: Text('Q: ${faq.title}'),
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              left: padding16,
                              right: padding16,
                              bottom: padding16,
                            ),
                            child: Text(
                              faq.content,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
            faqWidgets.add(faqWidget);
          }
          return Padding(
            padding: EdgeInsets.only(bottom: padding16),
            child: ListView(
              children: faqWidgets,
            ),
          );
        }
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scaffoldKey.currentState
              ..hideCurrentSnackBar()
              ..showSnackBar(Util().failureSnackBar('获取常见问题失败'));
          });
          return ListView();
        }
        return Padding(
          padding: EdgeInsets.all(padding16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Theme(
                data: Theme.of(context).copyWith(accentColor: colorPrimary),
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        );
      },
    );
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: TitleTopBar(title: '常见问题', canGoBack: true, actionButtons: null),
      body: Padding(
        padding: EdgeInsets.only(
          left: padding16,
          right: padding16,
          top: padding16,
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: screenHeight - kToolbarHeight - 3 * padding16 - 56,
              child: futureBuilder,
            ),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: colorPrimary,
                child: Text('联系客服'),
                borderRadius: BorderRadius.zero,
                onPressed: () {
                  launch('tel://$customerPhoneNumber');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
