import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/vm/portfolio_edit_view_model.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';

class BasicInfoSection extends StatelessWidget {
  final PortfolioEditViewModel viewModel;

  const BasicInfoSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          controller: viewModel.nicknameController,
          label: '닉네임 *',
          isRequired: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.oneLineIntroController,
          label: '한 줄 소개 *',
          isRequired: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.detailedIntroController,
          label: '상세 소개',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: CustomTextFormField(
                    controller: viewModel.experienceYearsController,
                    label: '경력(년)')),
            const SizedBox(width: 16),
            Expanded(
                child: CustomTextFormField(
                    controller: viewModel.ageController, label: '나이')),
          ],
        ),
        CheckboxListTile(
          title: const Text('나이 공개'),
          value: viewModel.isAgePublic,
          onChanged: viewModel.setIsAgePublic,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
