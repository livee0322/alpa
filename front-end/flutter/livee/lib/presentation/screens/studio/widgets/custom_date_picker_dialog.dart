import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

/// 디자인 시안에 맞게 커스텀된 날짜 선택 다이얼로그
class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const CustomDatePickerDialog({super.key, required this.initialDate});

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            const Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 20),
                SizedBox(width: 8),
                Text('날짜와 시간을 선택해 주세요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            // 캘린더
            TableCalendar(
              locale: 'ko_KR',
              focusedDay: _focusedDay,
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              // 달력의 행(week) 개수를 항상 6개로 고정하여 높이 변화를 방지
              sixWeekMonthsEnforced: true,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                Navigator.of(context).pop(_selectedDay);
              },
              // 캘린더 UI 커스텀
              calendarStyle: CalendarStyle(
                // 오늘 날짜 스타일
                todayDecoration: BoxDecoration(
                  color: AppColors.disabled.withOpacity(0.5),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                // 선택된 날짜 스타일
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary, // [수정] '퍼스트 컬러'로 변경
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // 특정 날짜 빌더 (예: '오늘', '개천절' 등 표시)
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  // 예시: 10월 3일 '개천절' 표시
                  if (day.month == 10 && day.day == 3) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${day.day}', style: const TextStyle(color: Colors.red)),
                          const Text('개천절', style: TextStyle(color: Colors.red, fontSize: 8)),
                        ],
                      ),
                    );
                  }
                  return null;
                },
                todayBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text('오늘', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
