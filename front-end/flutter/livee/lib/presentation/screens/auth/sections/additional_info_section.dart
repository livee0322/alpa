import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/auth/vm/signup_view_model.dart';
import 'package:livee/presentation/screens/auth/widgets/info_section_card.dart';
import 'package:livee/presentation/common/custom_text_form_field.dart';

// [클래스] 역할별 추가 정보(쇼호스트/브랜드) 입력 섹션 UI를 담당합니다.
class AdditionalInfoSection extends StatelessWidget {
  final SignupViewModel viewModel;

  const AdditionalInfoSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (viewModel.selectedRole == 'showhost') _buildShowhostInfoSection(),
        if (viewModel.selectedRole == 'brand') _buildBrandInfoSection(),
      ],
    );
  }

  // 쇼호스트 추가 정보 입력 섹션
  Widget _buildShowhostInfoSection() {
    return InfoSectionCard(
      title: '쇼호스트 정보',
      children: [
        // 닉네임
        CustomTextFormField(
          controller: viewModel.nicknameController,
          label: '닉네임',
          hintText: '닉네임을 입력해주세요.',
        ),
        const SizedBox(height: 16),

        // 대표 SNS 링크
        CustomTextFormField(
          controller: viewModel.snsLinkController,
          label: '대표 SNS 링크',
          hintText: '링크를 입력해주세요.(https://livee.com...)',
        ),
        const SizedBox(height: 16),

        // 소개
        CustomTextFormField(
          controller: viewModel.introController,
          label: '소개',
          hintText: '한 줄 소개 또는 경력을 입력해주세요.',
        ),
      ],
    );
  }

  // 브랜드 추가 정보 입력 섹션
  Widget _buildBrandInfoSection() {
    return InfoSectionCard(
      title: '브랜드 정보',
      children: [
        // 브랜드
        CustomTextFormField(
          controller: viewModel.brandNameController,
          label: '브랜드명',
          hintText: '브랜드명 입력해주세요.',
          isRequired: true,
        ),
        const SizedBox(height: 16),

        // 회사
        CustomTextFormField(
          controller: viewModel.companyNameController,
          label: '회사명',
          hintText: '회사명 입력해주세요.',
        ),
        const SizedBox(height: 16),

        // 사업자번호
        CustomTextFormField(
          controller: viewModel.businessNumberController,
          label: '사업자번호',
          hintText: '사업자번호 입력해주세요.',
        ),
      ],
    );
  }
}
