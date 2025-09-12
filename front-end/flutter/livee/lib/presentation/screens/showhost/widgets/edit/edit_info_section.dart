import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/vm/portfolio_edit_view_model.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';

class EditInfoSection extends StatelessWidget {
  final PortfolioEditViewModel viewModel;

  const EditInfoSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 기본 정보 ---
        _buildSectionTitle('기본 정보'),
        CustomTextFormField(
          controller: viewModel.nicknameController,
          label: '닉네임 *',
          hintText: '예: 라이브 크리에이터',
          isRequired: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.oneLineIntroController,
          label: '한 줄 소개 *',
          hintText: '예: 뷰티/일상 라이브 진행자',
          isRequired: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.detailedIntroController,
          label: '상세 소개',
          hintText: '자유롭게 소개를 작성하세요.',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: viewModel.experienceYearsController,
                label: '경력(년)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextFormField(
                controller: viewModel.ageController,
                label: '나이',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        CheckboxListTile(
          title: const Text('나이 공개'),
          value: viewModel.isAgePublic,
          onChanged: viewModel.setIsAgePublic, // ViewModel에 추가 필요
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 32),

        // --- 선택 정보 ---
        _buildSectionTitle('선택 정보'),
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
          onChanged: viewModel.setGender, // ViewModel에 추가 필요
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
            hintText: '예: 55, 95, M'),
        const SizedBox(height: 16),
        CustomTextFormField(
            controller: viewModel.bottomSizeController,
            label: '하의',
            hintText: '예: 26, 30'),
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
          onChanged: viewModel.setIsSizingPublic, // ViewModel에 추가 필요
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
