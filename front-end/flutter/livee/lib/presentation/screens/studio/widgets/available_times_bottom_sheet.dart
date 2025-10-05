import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/common/buttons/primary_action_button.dart';

/// 특정 날짜의 예약 가능한 시간 목록을 보여주는 바텀 시트
class AvailableTimesBottomSheet extends StatelessWidget {
  final DateTime selectedDate;
  final List<String> availableTimes;

  const AvailableTimesBottomSheet({
    super.key,
    required this.selectedDate,
    required this.availableTimes,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 20,
          children: [
            // 헤더
            Text(
              '예약 가능한 시간',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // 시간 블록 목록
            if (availableTimes.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text('예약 가능한 시간이 없습니다.'),
              ))
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: availableTimes.map((time) {
                  return SizedBox(
                    width: 70,
                    // onPressed를 null로 설정하여 버튼을 비활성화
                    child: ElevatedButton(
                      onPressed: null, // 클릭 비활성화
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.disabled,
                        disabledBackgroundColor: AppColors.disabled, // 비활성화 시 배경색
                        disabledForegroundColor: Colors.black54, // 비활성화 시 글자색
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(time),
                    ),
                  );
                }).toList(),
              ),
            // 확인 버튼
            PrimaryActionButton(
              text: '확인',
              onPressed: () => context.pop(), // 시트 닫기
            ),
          ],
        ),
      );
}
