// lib/domain/models/recruit.dart

class Recruit {
  // 필드
  final String? title; // 모집 공고의 제목
  final String? date; // 라이브 커머스 촬영 날짜 (YYYY-MM-DD)
  final String? timeStart; // 촬영 시작 시간 (HH:MM)
  final String? timeEnd; // 촬영 종료 시간 (HH:MM)
  final String? location; // 촬영 장소 (예: 서울 강남구 OO 스튜디오)
  final String? pay; // 출연료 정보 (문자열, 예: "30만원", "협의")
  final bool? payNegotiable; // 출연료 협의 가능 여부
  final String? category; // 모집 분야 카테고리 (예: "뷰티", "패션")
  final String? description; // 공고 상세 설명 (HTML 형식 포함 가능)
  final String? applyDeadline; // 모집 마감일 (YYYY-MM-DD)
  final int? fee; // 출연료 (숫자 값, 원 단위, 정렬/필터용)
  final List<String>? tags; // 공고 관련 태그 리스트 (최대 5개)

  // 생성자
  Recruit({
    this.title,
    this.date,
    this.timeStart,
    this.timeEnd,
    this.location,
    this.pay,
    this.payNegotiable,
    this.category,
    this.description,
    this.applyDeadline,
    this.fee,
    this.tags,
  });

  // 메소드
  factory Recruit.fromJson(Map<String, dynamic> json) {
    return Recruit(
      title: json['title'] as String?,
      date: json['date'] as String?,
      timeStart: json['timeStart'] as String?,
      timeEnd: json['timeEnd'] as String?,
      location: json['location'] as String?,
      pay: json['pay'] as String?,
      payNegotiable: json['payNegotiable'] as bool?,
      category: json['category'] as String?,
      description: json['description'] as String?,
      applyDeadline: json['applyDeadline'] as String?,
      fee: json['fee'] as int?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}
