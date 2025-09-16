// [파일경로/파일명] lib/presentation/screens/showhost/sections/recent_live_section.dart의 RecentLiveSection이 수정되었습니다.

import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/recent_live_controller.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';

class RecentLiveSection extends StatelessWidget {
  final List<RecentLiveControllers> controllers;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  const RecentLiveSection({
    super.key,
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...controllers.asMap().entries.map((entry) {
          int index = entry.key;
          RecentLiveControllers controller = entry.value;
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            // [수정] Row/Column 구조를 변경하여 레이아웃을 조정합니다.
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                          controller: controller.titleController,
                          label: '제목',
                          hintText: '예: OO몰 뷰티 라이브'),
                    ),
                    if (controllers.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0), // 버튼 위치 미세 조정
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => onRemove(index),
                          padding: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextFormField(
                    controller: controller.urlController,
                    label: '링크',
                    hintText: 'https://...'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.dateController,
                  readOnly: true, // 직접 입력을 막습니다.
                  decoration: InputDecoration(
                    labelText: '날짜',
                    hintText: '연도-월-일',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
                  ),
                  onTap: () async {
                    // 텍스트 필드를 탭하면 Date Picker를 엽니다.
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000), // 선택 가능한 가장 이른 날짜
                      lastDate: DateTime.now(), // 선택 가능한 가장 늦은 날짜 (오늘)
                    );
                    if (pickedDate != null) {
                      // 날짜를 선택하면 'YYYY-MM-DD' 형식으로 컨트롤러에 저장합니다.
                      controller.dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    }
                  },
                ),
              ],
            ),
          );
        }).toList(),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('추가'),
            onPressed: onAdd,
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: const Color(0xFF374151),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }
}