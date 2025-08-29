// 쇼호스트 포트폴리오 정보를 담는 데이터 모델
class Portfolio {
  final String id;
  final String name;
  final String? profileImage;
  final String? jobTag;
  final int? experienceYears;
  final String? region;
  final String? category; // 필터링을 위해 추가

  Portfolio({
    required this.id,
    required this.name,
    this.profileImage,
    this.jobTag,
    this.experienceYears,
    this.region,
    this.category,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '이름 없음',
      profileImage: json['profileImage'] as String?,
      jobTag: json['jobTag'] as String?,
      experienceYears: json['experienceYears'] as int?,
      region: json['region'] as String?,
      category: json['category'] as String?, // API 응답에 category가 있다고 가정
    );
  }
}
