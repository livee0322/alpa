import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/vm/portfolio_edit_view_model.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';

/// 포트폴리오의 '선택 정보' UI를 구성하는 위젯
class SelectionInfoSection extends StatelessWidget {
  final PortfolioEditViewModel viewModel;

  const SelectionInfoSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: viewModel.regionController,
                label: '지역',
                hintText: '시/도 (예: 서울)',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextFormField(
                controller: viewModel.detailedRegionController,
                label: '상세 지역',
                hintText: '구/군 (예: 강남구)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          label: '성별',
          value: viewModel.gender ?? '선택 안함',
          items: const ['선택 안함', '남성', '여성'],
          onChanged: viewModel.setGender,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: viewModel.heightController,
                label: '키(cm)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextFormField(
                controller: viewModel.weightController,
                label: '몸무게(kg)',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.topSizeController,
          label: '상의',
          hintText: '예: 55, 95, M',
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.bottomSizeController,
          label: '하의',
          hintText: '예: 26, 30',
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.shoeSizeController,
          label: '신발',
          hintText: '예: 240',
          keyboardType: TextInputType.number,
        ),
        CheckboxListTile(
          title: const Text('치수 공개'),
          value: viewModel.isSizingPublic,
          onChanged: viewModel.setIsSizingPublic,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF6C63FF),
        ),
      ],
    );
  }
}
