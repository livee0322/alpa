import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';

// 캠페인 유형('상품 캠페인', '쇼호스트 모집')을 선택하는 위젯
class CampaignTypeSelector extends StatelessWidget {
  final CampaignFormProvider provider;

  const CampaignTypeSelector({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTypeButton('product', '상품 캠페인', provider),
        const SizedBox(width: 8),
        _buildTypeButton('recruit', '쇼호스트 모집', provider),
      ],
    );
  }

  // 각 버튼을 만드는 헬퍼 위젯
  Widget _buildTypeButton(
      String type, String label, CampaignFormProvider provider) {
    final isSelected = provider.campaignType == type;
    return Expanded(
      child: InkWell(
        onTap: () => provider.setCampaignType(type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF6C63FF) : const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6C63FF)
                  : const Color(0xFFE6E8EC),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4B4F68),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
