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
  final bool? isPublic; // 공개 여부

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
    this.isPublic,
  });
  factory Campaign.fromJson(Map<String, dynamic> json) {
    // [추가] json의 value를 안전하게 특정 타입으로 변환하는 헬퍼 함수
    T? safeCast<T>(dynamic value) {
      if (value is T) {
        return value;
      }
      if (T == double && value is int) {
        return value.toDouble() as T?;
      }
      if (T == int && value is double) {
        return value.toInt() as T?;
      }
      if (T == String) {
        return value?.toString() as T?;
      }
      return null;
    }

    // 숫자 타입 필드를 안전하게 파싱하는 함수 (문자열 "50000" 등도 처리)
    num? parseNum(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      return num.tryParse(value.toString());
    }

    return Campaign(
      id: safeCast<String>(json['id']) ?? safeCast<String>(json['_id']),
      title: safeCast<String>(json['title']),
      thumbnailUrl: safeCast<String>(json['thumbnailUrl']),
      coverImageUrl: safeCast<String>(json['coverImageUrl']),
      brandName: safeCast<String>(json['brandName']),
      category: safeCast<String>(json['category']),
      fee: parseNum(json['fee']),
      feeNegotiable: safeCast<bool>(json['feeNegotiable']),
      closeAt: json['closeAt'] != null
          ? DateTime.tryParse(json['closeAt'].toString())
          : null,
      content: safeCast<String>(json['content']),
      isAd: safeCast<bool>(json['isAd']),
      isApplied: safeCast<bool>(json['isApplied']),
      location: safeCast<String>(json['location']),
      internalTitle: safeCast<String>(json['internalTitle']),
      prefix: safeCast<String>(json['prefix']),
      liveVerticalCoverUrl: safeCast<String>(json['liveVerticalCoverUrl']),
      startTime: safeCast<String>(json['startTime']),
      endTime: safeCast<String>(json['endTime']),
      liveStreamUrl: safeCast<String>(json['liveStreamUrl']),
      productThumbnailUrl: safeCast<String>(json['productThumbnailUrl']),
      productName: safeCast<String>(json['productName']),
      productUrl: safeCast<String>(json['productUrl']),
      shootDate: json['shootDate'] != null
          ? DateTime.tryParse(json['shootDate'].toString())
          : null,
      durationHours: parseNum(json['durationHours']),
      isPublic: safeCast<bool>(json['isPublic']),
    );
  }
}
