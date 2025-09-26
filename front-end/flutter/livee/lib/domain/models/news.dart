/// 뉴스 게시물 정보를 담는 데이터 모델
class News {
  final String id; // 게시물 고유 ID
  final String title; // 제목
  final String content; // 내용 (HTML 또는 일반 텍스트)
  final String? imageUrl; // 대표 이미지 URL (선택 사항)
  final DateTime createdAt; // 생성일
  final DateTime updatedAt; // 최종 수정일

  News({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON 데이터를 News 객체로 변환하는 팩토리 생성자
  ///
  /// 서버로부터 받은 JSON 맵(Map)을 News 객체로 변환
  /// 날짜 문자열은 DateTime 객체로 파싱하여 처리
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
