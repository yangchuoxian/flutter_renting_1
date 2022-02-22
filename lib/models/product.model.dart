class Product {
  String productID;
  String title;
  String coverImageURL;
  String description;
  String detailsURL;
  int pricePerYear;
  int pricePerMonth;
  int generalPrice; // 用作押金
  List<String> categoryIDs;
  List<String> carouselImageURLs; // 轮播图片的链接

  Product({
    this.productID,
    this.title,
    this.coverImageURL,
    this.description,
    this.detailsURL,
    this.pricePerYear,
    this.pricePerMonth,
    this.generalPrice,
    this.categoryIDs,
    this.carouselImageURLs,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var cIDs = <String>[];
    for (var i in json['categories']) {
      cIDs.add(i);
    }
    var cURLs = <String>[];
    if (json['carouselImageURLs'] != null) {
      for (var cURL in json['carouselImageURLs']) {
        if (cURL != '') {
          cURLs.add(cURL);
        }
      }
    }
    return Product(
      productID: json['id'],
      title: json['title'],
      coverImageURL: json['coverImageURL'],
      description: json['description'],
      detailsURL: json['detailsURL'],
      pricePerYear: json['pricePerYear'],
      pricePerMonth: json['pricePerMonth'],
      generalPrice: json['generalPrice'],
      categoryIDs: cIDs,
      carouselImageURLs: cURLs,
    );
  }
}
