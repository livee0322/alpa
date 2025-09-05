import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';

class PortfolioExperienceSection extends StatelessWidget {
  final TextEditingController experienceYearsController;
  final TextEditingController ageController;

  const PortfolioExperienceSection({
    super.key,
    required this.experienceYearsController,
    required this.ageController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomTextFormField(
              controller: experienceYearsController,
              label: '경력(년)',
              keyboardType: TextInputType.number),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextFormField(
              controller: ageController,
              label: '나이',
              keyboardType: TextInputType.number),
        ),
      ],
    );
  }
}
