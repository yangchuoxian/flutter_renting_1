import 'package:flutter/material.dart';
import 'package:flutter_renting/models/category.model.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/widgets/tabTopBar.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/widgets/bottomTabBar.dart';
import 'package:flutter_renting/widgets/sidebar.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:provider/provider.dart';
import 'package:flutter_renting/stores/navigation.store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_renting/widgets/productsList.dart';

class RentShop extends StatefulWidget {
  RentShop();
  @override
  State<StatefulWidget> createState() => _RentShopState();
}

class _RentShopState extends State<RentShop> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ProductCategory> _categories = <ProductCategory>[];

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> _getProductCategories() {
    return HTTP.get('$baseURL$apiListCategories');
  }

  @override
  Widget build(BuildContext context) {
    var navigationStore = Provider.of<NavigationStore>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TabTopBar(
              entries: <String>['租赁', '服务'],
              routes: <String>[
                RouteRentShop,
                RouteServiceShop,
              ],
              selectedIndex: 0,
            ),
            Expanded(
              child: FutureBuilder<dynamic>(
                future: _getProductCategories(),
                builder: (context, snapshot) {
                  var categoryNames = <String>[];
                  _categories.clear();
                  if (snapshot.hasData) {
                    for (var c in snapshot.data) {
                      var category = ProductCategory.fromJson(c);
                      categoryNames.add(category.name);
                      _categories.add(category);
                    }
                    return Row(
                      children: <Widget>[
                        CustomSidebar(
                          entries: categoryNames,
                          selectedIndex: navigationStore.selectedSidebarIndex,
                        ),
                        Observer(
                          builder: (_) => Flexible(
                            child: ProductsList(
                              categoryID: _categories[
                                      navigationStore.selectedSidebarIndex]
                                  .categoryID,
                              scaffoldKey: _scaffoldKey,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  if (snapshot.hasError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scaffoldKey.currentState
                        ..hideCurrentSnackBar()
                        ..showSnackBar(Util().failureSnackBar('获取商品类别失败'));
                    });
                    return Container();
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomTabBar(),
    );
  }
}
