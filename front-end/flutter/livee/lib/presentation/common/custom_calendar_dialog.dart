import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/common/custom_table_calendar.dart';

/// CustomTableCalendar를 사용하여 날짜를 선택하는 공통 다이얼로그
class CustomCalendarDialog extends StatefulWidget {
  final DateTime initialDate;

  const CustomCalendarDialog({super.key, required this.initialDate});

  @override
  State<CustomCalendarDialog> createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<CustomCalendarDialog> {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTableCalendar(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              // weeklySchedule은 이 다이얼로그에서는 필요 없으므로 빈 Map을 전달합니다.
              weeklySchedule: const {},
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
            const SizedBox(height: 16),
            // 하단 액션 버튼 (취소, 확인)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // null을 반환하며 닫기
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_selectedDay), // 선택된 날짜를 반환하며 닫기
                  child: const Text(
                    '확인',
                    style: TextStyle(color: AppColors.primary), // 퍼스트 컬러 적용
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
