import 'package:flutter/material.dart';
import 'package:flutter_renting/constants.dart';
import 'package:flutter_renting/services/http.dart';
import 'package:flutter_renting/services/util.dart';
import 'package:flutter_renting/stores/auth.store.dart';
import 'package:flutter_renting/stores/product.store.dart';
import 'package:flutter_renting/models/product.model.dart';
import 'package:flutter_renting/widgets/imageView.dart';
import 'package:provider/provider.dart';

class ProductsList extends StatefulWidget {
  final String categoryID;
  final GlobalKey<ScaffoldState> scaffoldKey;
  ProductsList({this.categoryID, this.scaffoldKey}) : super();

  @override
  State<StatefulWidget> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  String categoryID;
  GlobalKey<ScaffoldState> scaffoldKey;
  List<Product> _products = <Product>[];

  Future<dynamic> _getProductsForCategory() {
    return HTTP
        .get('$baseURL$apiListProductsInCategory?categoryID=$categoryID');
  }

  @override
  Widget build(BuildContext context) {
    final productStore = Provider.of<ProductStore>(context, listen: false);
    final authStore = Provider.of<AuthStore>(context, listen: false);
    categoryID = widget.categoryID;
    scaffoldKey = widget.scaffoldKey;
    var screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<dynamic>(
      future: _getProductsForCategory(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _products.clear();
          var wrappedWidgets = <Widget>[];
          for (var p in snapshot.data) {
            var product = Product.fromJson(p);
            _products.add(product);
            var productWidget = GestureDetector(
              child: Container(
                width: (screenWidth - sidebarWidth) / 2,
                height: (screenWidth - sidebarWidth) / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ImageView(
                      width: largeAvatar,
                      height: largeAvatar,
                      uri: product.coverImageURL,
                      imageType: ImageType.network,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: padding16),
                      child: Text(product.title),
                    ),
                  ],
                ),
              ),
              onTap: () {
                // 如果用户没有登录，返回至用户登录界面
                if (authStore.loggedInUser == null) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RouteEnterPhone, (route) => false);
                } else {
                  productStore.selectProduct(product);
                  Navigator.pushNamed(context, RouteProductDetails);
                }
              },
            );
            wrappedWidgets.add(productWidget);
          }
          return Column(
            children: <Widget>[
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                direction: Axis.horizontal,
                children: wrappedWidgets,
              ),
            ],
          );
        }
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scaffoldKey.currentState
              ..hideCurrentSnackBar()
              ..showSnackBar(Util().failureSnackBar('获取商品失败'));
          });
          return Container();
        }
        return Container();
      },
    );
  }
}
