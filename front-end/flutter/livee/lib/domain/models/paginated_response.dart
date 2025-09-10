/// 서버로부터 받는 페이지네이션 응답을 위한 제네릭 모델 클래스
class PaginatedResponse<T> {
  /// 현재 페이지의 아이템 리스트
  final List<T> items;

  /// 현재 페이지 번호
  final int currentPage;

  /// 전체 페이지 수
  final int totalPages;

  /// 전체 아이템 개수
  final int totalItems;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  /// JSON으로부터 객체를 생성하는 팩토리 생성자
  /// fromJsonModel: JSON 객체를 T 타입의 모델 객체로 변환하는 함수
  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonModel) {
    final itemsList = json['items'] as List<dynamic>;
    final items = itemsList.map((itemJson) => fromJsonModel(itemJson as Map<String, dynamic>)).toList();

    return PaginatedResponse(
      items: items,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalItems: json['totalItems'] as int,
    );
  }
}
