/// 각 요일의 영업 시간 및 예외 시간을 관리
class DaySchedule {
  bool isOpen; // '영업' 토글 상태
  String startTime; // 시작 시간 (예: "09:00")
  String endTime; // 마감 시간 (예: "18:00")
  List<String> excludedTimes; // 영업 제외 시간 목록

  DaySchedule({
    this.isOpen = true,
    this.startTime = '09:00',
    this.endTime = '18:00',
    List<String>? excludedTimes,
  }) : excludedTimes = excludedTimes ?? []; // null일 경우 빈 리스트로 초기화
}
