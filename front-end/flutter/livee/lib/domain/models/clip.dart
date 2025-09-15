// 숏클립 데이터의 구조를 정의하는 모델 클래스
class Clip {
  final String id;
  final String url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? provider; // youtube, instagram 등
  final bool? isMine;

  Clip({
    required this.id,
    required this.url,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.provider,
    this.isMine,
  });

  factory Clip.fromJson(Map<String, dynamic> json) {
    return Clip(
      id: json['_id'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      provider: json['provider'] as String?,
      isMine: json['isMine'] as bool?,
    );
  }
}
