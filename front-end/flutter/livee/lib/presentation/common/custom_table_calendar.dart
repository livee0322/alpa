import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livee/presentation/screens/studio/models/day_schedule.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

/// 앱 전역에서 사용될 공통 달력 위젯
class CustomTableCalendar extends StatelessWidget {
  /// 달력이 초기에 보여줄 월
  final DateTime focusedDay;

  /// 현재 선택된 날짜
  final DateTime? selectedDay;

  /// 사용자가 날짜를 선택했을 때 호출될 콜백 함수
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  /// '예약 마감' 상태로 표시할 날짜 목록
  final Set<DateTime> bookedDates;

  /// 휴무일 등 주간 스케줄 정보
  final Map<String, DaySchedule> weeklySchedule;

  const CustomTableCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    this.bookedDates = const {}, // 기본값은 빈 Set
    required this.weeklySchedule,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      // [수정] selectedDayPredicate와 onDaySelected를 외부에서 받은 props로 교체
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,

      // 오늘 이전 날짜를 선택할 수 없도록 설정
      enabledDayPredicate: (day) {
        return !day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
      },

      // 캘린더의 각 날짜 UI를 커스텀
      calendarBuilders: CalendarBuilders(
        // 비활성화된 날짜(과거)를 회색으로 표시
        disabledBuilder: (context, day, focusedDay) {
          return Center(
            child: Text(
              '${day.day}',
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        },

        // 기본 날짜를 렌더링할 때 예약 가능 여부를 확인
        defaultBuilder: (context, day, focusedDay) {
          final dayOfWeek = DateFormat('E', 'ko_KR').format(day);
          // [수정] viewModel.studio.weeklySchedule -> widget.weeklySchedule로 변경
          final scheduleTemplate = weeklySchedule[dayOfWeek];

          // 휴무일이거나 스케줄 정보가 없으면 회색 처리
          if (scheduleTemplate == null || !scheduleTemplate.isOpen) {
            return Center(
              child:
                  Text('${day.day}', style: TextStyle(color: Colors.grey[400])),
            );
          }

          // [수정] 하드코딩된 예약 데이터를 외부에서 전달받은 bookedDates로 교체
          // 날짜만 비교하기 위해 시간 정보는 제거
          final normalizedDay = DateTime(day.year, day.month, day.day);
          if (bookedDates.contains(normalizedDay)) {
            return Center(
              child:
                  Text('${day.day}', style: TextStyle(color: Colors.grey[400])),
            );
          }

          return null; // 위 조건에 해당하지 않으면 기본 스타일 사용
        },

        // [추가] 선택된 날짜의 UI를 커스텀합니다.
        selectedBuilder: (context, day, focusedDay) {
          return Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
