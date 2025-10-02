class Campaign {
  final String? id; // 고유 식별자
  final String? title; // 외부에 노출되는 공고 제목
  final String? thumbnailUrl; // 목록용 썸네일 이미지 URL
  final String? coverImageUrl; // 상세 페이지용 커버 이미지 URL
  final String? brandName; // 브랜드명
  final String? category; // 카테고리
  final num? fee; // 출연료
  final bool? feeNegotiable; // 출연료 협의 가능 여부
  final DateTime? closeAt; // 모집 마감일
  final String? content; // 상세 설명 (HTML 형식)
  final bool? isAd; // 광고 여부
  final bool? isApplied; // 현재 사용자의 지원 여부
  final String? location; // 촬영 장소
  final String? internalTitle; // 내부 관리용 제목
  final String? prefix; // 제목 앞에 붙는 말머리 (예: [긴급])
  final String? liveVerticalCoverUrl; // 모바일용 세로 커버 이미지 URL
  final String? startTime; // 라이브 시작 시간
  final String? endTime; // 라이브 종료 시간
  final String? liveStreamUrl; // 라이브 스트리밍 URL
  final String? productThumbnailUrl; // 대표 상품 썸네일 URL
  final String? productName; // 대표 상품명
  final String? productUrl; // 대표 상품 판매 페이지 URL
  final DateTime? shootDate; // 촬영일
  final num? durationHours; // 총 촬영 시간

  Campaign({
    this.id,
    this.title,
    this.thumbnailUrl,
    this.coverImageUrl,
    this.brandName,
    this.category,
    this.fee,
    this.feeNegotiable,
    this.closeAt,
    this.content,
    this.isAd,
    this.isApplied,
    this.location,
    this.internalTitle,
    this.prefix,
    this.liveVerticalCoverUrl,
    this.startTime,
    this.endTime,
    this.liveStreamUrl,
    this.productThumbnailUrl,
    this.productName,
    this.productUrl,
    this.shootDate,
    this.durationHours,
  });
  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String? ?? json['_id'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      brandName: json['brandName'] as String?,
      category: json['category'] as String?,
      fee: json['fee'] as num?,
      feeNegotiable: json['feeNegotiable'] as bool?,
      closeAt:
          json['closeAt'] != null ? DateTime.tryParse(json['closeAt']) : null,
      content: json['content'] as String?,
      isApplied: json['isApplied'] as bool?,
      location: json['location'] as String?,
      internalTitle: json['internalTitle'] as String?,
      prefix: json['prefix'] as String?,
      liveVerticalCoverUrl: json['liveVerticalCoverUrl'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      liveStreamUrl: json['liveStreamUrl'] as String?,
      productThumbnailUrl: json['productThumbnailUrl'] as String?,
      productName: json['productName'] as String?,
      productUrl: json['productUrl'] as String?,
      shootDate: json['shootDate'] != null
          ? DateTime.tryParse(json['shootDate'])
          : null,
      durationHours: json['durationHours'] as num?,
    );
  }
}
