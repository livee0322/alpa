/// 쇼호스트 포트폴리오 정보를 담는 데이터 모델
class Portfolio {
  final String id;
  final String? name; // 이름 필드
  final String? profileImage; // 프로필 이미지
  final String? jobTag; // 직업 태그
  final int? experienceYears; // 경력(년차)
  final String? region; // 지역 필드 (시/도)
  final String? category; // 카테고리 필드
  final String? nickname; // 닉네임
  final String? oneLineIntro; // 한 줄 소개
  final String? detailedIntro; // 상세 소개
  final int? age; // 나이
  final String? mainLink; // 대표 링크
  final String? mainThumbnailUrl; // 메인 썸네일 URL (프로필 사진)
  final String? backgroundImageUrl; // 배경 이미지 URL
  final List<String>? subThumbnailUrls; // 서브 썸네일 URL 목록
  final String? publicScope; // 포트폴리오 공개 범위 (전체공개, 링크공개, 비공개)
  final bool? isReceivingOffers; // 제안 받기 여부
  final List<RecentLive>? recentLives; // 최근 라이브 이력 목록
  final String? status; // 포트폴리오 상태 (published: 발행, draft: 임시저장)
  final bool? isAgePublic; // 나이 공개 여부
  final String? detailedRegion; // 상세 지역 (구/군)
  final String? gender; // 성별
  final int? height; // 키 (cm)
  final int? weight; // 몸무게 (kg)
  final String? topSize; // 상의 사이즈
  final String? bottomSize; // 하의 사이즈
  final int? shoeSize; // 신발 사이즈
  final bool? isSizingPublic; // 신체 치수 공개 여부
  final String? websiteUrl; // 개인 웹사이트 링크
  final String? instagramUrl; // 인스타그램 링크
  final String? youtubeUrl; // 유튜브 링크
  final String? tiktokUrl; // 틱톡 링크
  final bool? isExperiencePublic;
  final bool? isRegionPublic;
  final bool? isGenderPublic;
  final bool? isHeightPublic;
  final String? attachedFileUrl; // 첨부 파일 URL

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
    this.status,
    this.isAgePublic,
    this.detailedRegion,
    this.gender,
    this.height,
    this.weight,
    this.topSize,
    this.bottomSize,
    this.shoeSize,
    this.isSizingPublic,
    this.websiteUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.tiktokUrl,
    this.isExperiencePublic,
    this.isRegionPublic,
    this.isGenderPublic,
    this.isHeightPublic,
    this.attachedFileUrl,
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
      status: json['status'] as String?,
      isAgePublic: json['isAgePublic'] as bool?,
      detailedRegion: json['detailedRegion'] as String?,
      gender: json['gender'] as String?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      topSize: json['topSize'] as String?,
      bottomSize: json['bottomSize'] as String?,
      shoeSize: json['shoeSize'] as int?,
      isSizingPublic: json['isSizingPublic'] as bool?,
      websiteUrl: json['websiteUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      isExperiencePublic: json['isExperiencePublic'] as bool?,
      isRegionPublic: json['isRegionPublic'] as bool?,
      isGenderPublic: json['isGenderPublic'] as bool?,
      isHeightPublic: json['isHeightPublic'] as bool?,
      attachedFileUrl: json['attachedFileUrl'] as String?,
    );
  }
}

/// '최근 라이브 링크' 항목을 위한 보조 모델
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
