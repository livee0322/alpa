class Product {
  final String? url;
  final String? title;
  final num? price;
  final num? salePrice;
  final String? thumbnail;

  Product({
    this.url,
    this.title,
    this.price,
    this.salePrice,
    this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      url: json['url'] as String?,
      title: json['title'] as String?,
      price: json['price'] as num?,
      salePrice: json['salePrice'] as num?,
      thumbnail: json['thumbnail'] as String?,
    );
  }
}
