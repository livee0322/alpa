import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/portfolio/vm/profile_edit_view_model_base.dart';
import 'package:livee/presentation/common/custom_text_form_field.dart';

class BasicInfoSection extends StatelessWidget {
  final ProfileEditViewModelBase viewModel;

  const BasicInfoSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          controller: viewModel.nicknameController,
          label: '닉네임',
          isRequired: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.oneLineIntroController,
          label: '한 줄 소개',
          isRequired: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.detailedIntroController,
          label: '상세 소개',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
