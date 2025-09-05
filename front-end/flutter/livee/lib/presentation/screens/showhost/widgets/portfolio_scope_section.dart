import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';

class PortfolioScopeSection extends StatelessWidget {
  final String publicScope;
  final bool isReceivingOffers;
  final ValueChanged<String?> onScopeChanged;
  final ValueChanged<bool?> onOfferChanged;

  const PortfolioScopeSection({
    super.key,
    required this.publicScope,
    required this.isReceivingOffers,
    required this.onScopeChanged,
    required this.onOfferChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdown(
          label: '공개 범위',
          value: publicScope,
          items: const ['전체공개', '링크 공개', '비공개'],
          onChanged: onScopeChanged,
        ),
        CheckboxListTile(
          title: const Text('제안 받기'),
          value: isReceivingOffers,
          onChanged: onOfferChanged,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF6C63FF),
        ),
      ],
    );
  }
}
