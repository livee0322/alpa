// 임시 모델 (추후 상세 구현 예정)
import 'package:livee/domain/models/product.dart';

class Recruit {
  Recruit.fromJson(Map<String, dynamic> json);
}

class Campaign {
  final String? id;
  final String? title;
  final String? coverImageUrl;
  final String? type;
  final List<Product>? products;
  final Recruit? recruit;
  final String? brand;
  final String? category;
  final String? date;

  Campaign({
    this.id,
    this.title,
    this.coverImageUrl,
    this.type,
    this.products,
    this.recruit,
    this.brand,
    this.category,
    this.date,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['_id'] as String? ?? json['id'] as String?,
      title: json['title'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      type: json['type'] as String?,
      products: (json['products'] as List<dynamic>?)?.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
      recruit: json['recruit'] != null ? Recruit.fromJson(json['recruit'] as Map<String, dynamic>) : null,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      date: json['date'] as String?,
    );
  }
}
