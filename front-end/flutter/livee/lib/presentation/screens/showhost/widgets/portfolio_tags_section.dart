import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';

class PortfolioTagsSection extends StatelessWidget {
  final TextEditingController tagController;
  final List<String> tags;
  final VoidCallback onAddTag;
  final Function(String) onRemoveTag;

  const PortfolioTagsSection({
    super.key,
    required this.tagController,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          controller: tagController,
          hintText: '엔터로 추가',
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAddTag,
          ),
          onSubmitted: (_) => onAddTag,
        ),
        if (tags.isNotEmpty) const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: tags
              .map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => onRemoveTag(tag),
                    deleteIconColor: Colors.grey[600],
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
