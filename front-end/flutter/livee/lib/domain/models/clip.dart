// 숏클립 데이터의 구조를 정의하는 모델
class Clip {
  final String id; // 고유 식별자 (삭제, 수정 시 사용)
  final String url; // 동영상 원본 링크 (유튜브, 인스타 등)
  final String? title; // 숏클립 제목
  final String? description; // 숏클립 상세 설명 (상세 페이지용)
  final String? thumbnailUrl; // 서버에서 생성된 썸네일 이미지 주소
  final String? provider; // 동영상 플랫폼 (예: youtube, instagram)
  final bool? isMine; // 내가 등록한 클립인지 여부 (삭제 버튼 표시용)

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
      url: json['sourceUrl'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      provider: json['provider'] as String?,
      isMine: json['isMine'] as bool?,
    );
  }
}
