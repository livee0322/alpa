import 'package:livee/domain/models/product.dart';
import 'package:livee/domain/models/recruit.dart';

class Campaign {
  final String? id;
  final String? title;
  final String? thumbnailUrl;
  final String? coverImageUrl;
  final String? type;
  final List<Product>? products;
  final Recruit? recruit;
  final String? brand;
  final String? category;
  final num? fee;
  final bool? feeNegotiable;
  final String? liveTime;
  final String? closeAt;
  final String? descriptionHTML;
  final bool? isAd;
  final bool? isApplied;

  Campaign({
    this.id,
    this.title,
    this.thumbnailUrl,
    this.coverImageUrl,
    this.type,
    this.products,
    this.recruit,
    this.brand,
    this.category,
    this.fee,
    this.feeNegotiable,
    this.liveTime,
    this.closeAt,
    this.descriptionHTML,
    this.isAd,
    this.isApplied,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String?,
      title: json['title'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      type: json['type'] as String?,
      products: (json['products'] as List<dynamic>?)?.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
      recruit: json['recruit'] != null ? Recruit.fromJson(json['recruit'] as Map<String, dynamic>) : null,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      fee: json['fee'] as num?,
      feeNegotiable: json['feeNegotiable'] as bool?,
      liveTime: json['liveTime'] as String?,
      closeAt: json['closeAt'] as String?,
      descriptionHTML: json['descriptionHTML'] as String?,
      isAd: json['isAd'] as bool?,
      isApplied: json['isApplied'] as bool?,
    );
  }
}
