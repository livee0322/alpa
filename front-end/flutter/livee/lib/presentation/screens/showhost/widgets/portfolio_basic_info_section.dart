import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';

class PortfolioBasicInfoSection extends StatelessWidget {
  final TextEditingController nicknameController;
  final TextEditingController oneLineIntroController;
  final TextEditingController detailedIntroController;

  const PortfolioBasicInfoSection({
    super.key,
    required this.nicknameController,
    required this.oneLineIntroController,
    required this.detailedIntroController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
            controller: nicknameController,
            label: '닉네임 *',
            hintText: '예: 라이브크리에이터',
            isRequired: true),
        const SizedBox(height: 16),
        CustomTextFormField(
            controller: oneLineIntroController,
            label: '한 줄 소개 *',
            hintText: '예: 뷰티/일상 라이브 진행자',
            isRequired: true),
        const SizedBox(height: 16),
        CustomTextFormField(
            controller: detailedIntroController,
            label: '상세 소개 (자유)',
            hintText: '자유롭게 소개를 작성하세요.',
            maxLines: 5),
      ],
    );
  }
}
