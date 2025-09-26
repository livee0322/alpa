/// 공통 유틸리티 함수들을 관리하는 클래스
class Utility {
  // D-day를 계산하여 문자열로 반환 함수
  static String calculateDday(String? dateStr) {
    if (dateStr == null) return '미정';
    try {
      final date = DateTime.parse(dateStr);
      final today = DateTime.now();
      // 날짜 차이만 계산하기 위해 시간 정보는 제거
      final difference = date.difference(DateTime(today.year, today.month, today.day)).inDays;

      if (difference < 0) return '마감';
      if (difference == 0) return 'D-DAY';
      return 'D-$difference';
    } catch (e) {
      return '미정'; // 날짜 파싱 실패 시
    }
  }

  // 상대 시간을 계산하여 문자열로 반환하는 함수
  /// (예: "방금 전", "5분 전", "3일 전", "2주 전", "3개월 전", "1년 전")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}년 전';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
