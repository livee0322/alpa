import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final int maxLines;
  final bool isRequired;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Function(String)? onSubmitted;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.maxLines = 1,
    this.isRequired = false,
    this.keyboardType,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text.rich(
              TextSpan(
                text: label,
                children: isRequired
                    ? [
                        const TextSpan(
                            text: ' *', style: TextStyle(color: Colors.red))
                      ]
                    : [],
              ),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            alignLabelWithHint: maxLines > 1,
            suffixIcon: suffixIcon,
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          onFieldSubmitted: onSubmitted,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return '필수 항목입니다.';
            }
            return null;
          },
        ),
      ],
    );
  }
}
