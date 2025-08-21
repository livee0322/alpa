import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';
import 'product_list_section.dart';
import 'product_url_input_section.dart';
import 'sale_and_live_section.dart';

// '상품 캠페인'에 해당하는 모든 입력 필드를 포함하는 위젯
class ProductFormSection extends StatelessWidget {
  final CampaignFormProvider provider;

  const ProductFormSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 공개 정보 (제목, 브랜드명)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: provider.titleController,
                label: '공개 제목',
                hint: '상품 캠페인 제목',
                isRequired: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: provider.brandController,
                label: '브랜드명',
                hint: '예) MAC',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProductUrlInputSection(provider: provider),
        ProductListSection(provider: provider),
        const SizedBox(height: 16),
        SaleAndLiveSection(provider: provider),

        // 기타 정보
        _buildTextField(
            controller: provider.categoryController,
            label: '상품군',
            hint: '예) 뷰티/패션/가전'),
        _buildTextField(
          controller: provider.descController,
          label: '상세 설명 (HTML 가능)',
          hint: '상세페이지 소개/가이드/주의사항 등을 작성하세요.',
          maxLines: 7,
        ),
      ],
    );
  }

  // 공통 텍스트 필드 위젯
  Widget _buildTextField(
      {required TextEditingController controller,
      String? label,
      String? hint,
      bool isRequired = false,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label != null ? (isRequired ? '$label *' : label) : null,
          hintText: hint,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label을(를) 입력해주세요.';
          }
          return null;
        },
      ),
    );
  }
}
