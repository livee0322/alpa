
import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';

/// 디자인 시안에 맞는 커스텀 시간 선택 위젯
class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;

  const CustomTimePicker({super.key, this.initialTime = const TimeOfDay(hour: 12, minute: 0)});

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late FixedExtentScrollController _periodController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _periodController = FixedExtentScrollController(initialItem: widget.initialTime.period == DayPeriod.am ? 0 : 1);
    _hourController = FixedExtentScrollController(initialItem: widget.initialTime.hourOfPeriod -1);
    _minuteController = FixedExtentScrollController(initialItem: widget.initialTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // 오전/오후 선택
                _buildPickerColumn(_periodController, ['오전', '오후']),
                // 시 선택
                _buildPickerColumn(_hourController, List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'))),
                // 분 선택
                _buildPickerColumn(_minuteController, List.generate(60, (index) => index.toString().padLeft(2, '0'))),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// [위젯] 시간/분 등을 선택하는 스크롤 피커 UI
  Widget _buildPickerColumn(FixedExtentScrollController controller, List<String> items) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, index) {
            return Center(
              child: Text(items[index], style: const TextStyle(fontSize: 18)),
            );
          },
        ),
      ),
    );
  }

  /// [위젯] 타임 피커의 하단 액션 버튼
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('취소'))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(onPressed: () {
            // TODO: 선택된 시간 값 반환 로직
            Navigator.pop(context);
          }, child: const Text('저장'))),
        ],
      ),
    );
  }
}