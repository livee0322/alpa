import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/studio/vm/studio_edit_view_model.dart';
import 'package:livee/presentation/screens/studio/widgets/exclude_time_modal.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';

/// 요일별로 시간 단위를 직접 선택하여 예약 스케줄을 관리하는 위젯
class WeeklyScheduleSection extends StatelessWidget {
  final StudioEditViewModel viewModel;

  const WeeklyScheduleSection({super.key, required this.viewModel});

  // 00:00 부터 23:00 까지 1시간 단위의 시간 목록을 생성하는 헬퍼 함수
  List<String> get _timeOptions => List.generate(24, (i) => '${i.toString().padLeft(2, '0')}:00');

  @override
  Widget build(BuildContext context) {
    return Column(
      // ViewModel의 weeklySchedule 맵 데이터를 기반으로 각 요일의 UI를 동적으로 생성
      children: viewModel.weeklySchedule.entries.map((entry) {
        final day = entry.key;
        final schedule = entry.value;
        return _buildDayScheduleRow(context, day, schedule);
      }).toList(),
    );
  }

  /// 각 요일별 UI를 구성하는 위젯
  Widget _buildDayScheduleRow(BuildContext context, String day, dynamic schedule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 요일 이름과 영업 토글 스위치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Text('영업', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Switch(
                    value: schedule.isOpen,
                    onChanged: (value) => viewModel.setDayOpen(day, value),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. 시작시간 / 마감시간 드롭다운 (영업 토글이 꺼지면 비활성화)
          Opacity(
            opacity: schedule.isOpen ? 1.0 : 0.5,
            child: AbsorbPointer(
              absorbing: !schedule.isOpen,
              child: Row(
                children: [
                  Expanded(
                    child: CustomDropdown(
                      value: schedule.startTime,
                      items: _timeOptions,
                      onChanged: (value) {
                        if (value != null) viewModel.setStartTime(day, value);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('~'),
                  ),
                  Expanded(
                    child: CustomDropdown(
                      value: schedule.endTime,
                      items: _timeOptions,
                      onChanged: (value) {
                        if (value != null) viewModel.setEndTime(day, value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. '영업시간 제외' 버튼
          Opacity(
            opacity: schedule.isOpen ? 1.0 : 0.5,
            child: AbsorbPointer(
              absorbing: !schedule.isOpen,
              child: TextButton.icon(
                icon: const Icon(Icons.remove_circle_outline, size: 16),
                label: const Text('영업시간 제외'),
                onPressed: () async {
                  final List<String>? result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ExcludeTimeModal(
                      startTime: schedule.startTime,
                      endTime: schedule.endTime,
                      alreadyExcluded: schedule.excludedTimes,
                    ),
                  );
                  if (result != null) {
                    viewModel.setExcludedTimes(day, result);
                  }
                },
              ),
            ),
          ),

          // 4. 제외된 시간들을 표시하는 칩(Chip) 목록
          if (schedule.excludedTimes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: schedule.excludedTimes.map<Widget>((time) {
                  return Chip(
                    label: Text(time),
                    backgroundColor: Colors.grey[200],
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      // 기존 목록을 복사한 후 해당 시간만 제거하여 ViewModel에 업데이트
                      final updatedList = List<String>.from(schedule.excludedTimes)..remove(time);
                      viewModel.setExcludedTimes(day, updatedList);
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
