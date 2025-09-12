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
            child: Column(
              children: [
                CustomTextFormField(
                    controller: controller.titleController,
                    label: '제목',
                    hintText: '예: OO몰 뷰티 라이브'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 2,
                        child: CustomTextFormField(
                            controller: controller.urlController,
                            label: '링크',
                            hintText: 'https://...')),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 1,
                        child: CustomTextFormField(
                            controller: controller.dateController,
                            label: '날짜',
                            hintText: '연도-월-일')),
                    if (controllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => onRemove(index),
                        padding: const EdgeInsets.only(top: 8),
                        constraints: const BoxConstraints(),
                      )
                  ],
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
