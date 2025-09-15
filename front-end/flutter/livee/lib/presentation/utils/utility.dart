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
}
