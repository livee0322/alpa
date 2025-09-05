// lib/domain/models/portfolio.dart

// 쇼호스트 포트폴리오 정보를 담는 데이터 모델
class Portfolio {
  final String id;
  final String? name;
  final String? profileImage;
  final String? jobTag;
  final int? experienceYears;
  final String? region;
  final String? category;

  // 신규 기획안 필드
  final String? nickname;
  final String? oneLineIntro;
  final String? detailedIntro;
  final int? age;
  final String? mainLink;
  final String? mainThumbnailUrl;
  final String? backgroundImageUrl;
  final List<String>? subThumbnailUrls;
  final String? publicScope;
  final bool? isReceivingOffers;
  final List<RecentLive>? recentLives;
  final List<String>? tags;
  final String? status;

  Portfolio({
    required this.id,
    this.name,
    this.profileImage,
    this.jobTag,
    this.experienceYears,
    this.region,
    this.category,
    this.nickname,
    this.oneLineIntro,
    this.detailedIntro,
    this.age,
    this.mainLink,
    this.mainThumbnailUrl,
    this.backgroundImageUrl,
    this.subThumbnailUrls,
    this.publicScope,
    this.isReceivingOffers,
    this.recentLives,
    this.tags,
    this.status,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '이름 없음',
      profileImage: json['profileImage'] as String?,
      jobTag: json['jobTag'] as String?,
      experienceYears: json['experienceYears'] as int?,
      region: json['region'] as String?,
      category: json['category'] as String?,
      // --- [추가] fromJson 로직 ---
      nickname: json['nickname'] as String?,
      oneLineIntro: json['oneLineIntro'] as String?,
      detailedIntro: json['detailedIntro'] as String?,
      age: json['age'] as int?,
      mainLink: json['mainLink'] as String?,
      mainThumbnailUrl: json['mainThumbnailUrl'] as String?,
      backgroundImageUrl: json['backgroundImageUrl'] as String?,
      subThumbnailUrls: (json['subThumbnailUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      publicScope: json['publicScope'] as String?,
      isReceivingOffers: json['isReceivingOffers'] as bool?,
      recentLives: (json['recentLives'] as List<dynamic>?)
          ?.map((e) => RecentLive.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      status: json['status'] as String?,
    );
  }
}

// '최근 라이브 링크' 항목을 위한 보조 모델
class RecentLive {
  final String title;
  final String url;
  final String date;

  RecentLive({
    required this.title,
    required this.url,
    required this.date,
  });

  factory RecentLive.fromJson(Map<String, dynamic> json) {
    return RecentLive(
      title: json['title'] as String,
      url: json['url'] as String,
      date: json['date'] as String,
    );
  }
}
