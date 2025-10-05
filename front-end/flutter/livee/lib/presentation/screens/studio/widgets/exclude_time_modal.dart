import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/common/buttons/primary_action_button.dart';

/// 영업 시간 내에서 특정 시간 블록을 제외하기 위한 모달
class ExcludeTimeModal extends StatefulWidget {
  final String startTime;
  final String endTime;
  final List<String> alreadyExcluded;

  const ExcludeTimeModal({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.alreadyExcluded,
  });

  @override
  State<ExcludeTimeModal> createState() => _ExcludeTimeModalState();
}

class _ExcludeTimeModalState extends State<ExcludeTimeModal> {
  late Set<String> _selectedTimes;

  @override
  void initState() {
    super.initState();
    // 기존에 제외된 시간들을 Set으로 변환하여 초기 선택 상태로 설정
    _selectedTimes = Set.from(widget.alreadyExcluded);
  }

  /// 시작 시간과 종료 시간 사이의 모든 시간 블록(1시간 단위)을 생성
  List<String> _generateTimeSlots() {
    try {
      final startHour = int.parse(widget.startTime.split(':')[0]);
      final endHour = int.parse(widget.endTime.split(':')[0]);
      if (startHour >= endHour) return [];

      return List.generate(endHour - startHour, (index) {
        return '${(startHour + index).toString().padLeft(2, '0')}:00';
      });
    } catch (e) {
      return []; // 시간 파싱 실패 시 빈 리스트 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = _generateTimeSlots();

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Wrap(
        runSpacing: 20,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('영업 제외 시간 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(), // 변경사항 없이 닫기
              ),
            ],
          ),
          // 시간 블록 선택 그리드
          if (timeSlots.isEmpty)
            const Center(child: Text('설정된 영업시간이 올바르지 않습니다.'))
          else
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: timeSlots.map((time) {
                final isSelected = _selectedTimes.contains(time);
                return SizedBox(
                  width: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isSelected) {
                          _selectedTimes.remove(time);
                        } else {
                          _selectedTimes.add(time);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                      backgroundColor: isSelected ? AppColors.error : AppColors.disabled,
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
            onPressed: () => context.pop(_selectedTimes.toList()),
          ),
        ],
      ),
    );
  }
}
