class ProductCategory {
  String categoryID;
  String parentCategoryID;
  String name;
  String description;

  ProductCategory({
    this.categoryID,
    this.parentCategoryID,
    this.name,
    this.description,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      categoryID: json['id'],
      parentCategoryID: json['parentCategoryID'],
      name: json['name'],
      description: json['description'],
    );
  }
}
