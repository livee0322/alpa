import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/auth/vm/signup_view_model.dart';

import 'package:livee/presentation/screens/auth/widgets/info_section_card.dart';
import 'package:livee/presentation/styles/app_colors.dart';

// 약관 동의 섹션 UI
class TermsSection extends StatelessWidget {
  final SignupViewModel viewModel;

  const TermsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return InfoSectionCard(
      title: '약관 동의',
      children: [
        Column(
          children: [
            // 서비스 이용약관
            CheckboxListTile(
              value: viewModel.serviceTermsConsent,
              onChanged: viewModel.setServiceTermsConsent,
              title: const Text('[필수] 서비스 이용약관 동의'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),

            // 개인정보처리 방침
            CheckboxListTile(
              value: viewModel.privacyPolicyConsent,
              onChanged: viewModel.setPrivacyPolicyConsent,
              title: const Text('[필수] 개인정보처리방침 동의'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),

            // 만 14세
            CheckboxListTile(
              value: viewModel.ageConsent,
              onChanged: viewModel.setAgeConsent,
              title: const Text('[필수] 만 14세 이상입니다.'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),

            // 마케팅 동의
            CheckboxListTile(
              value: viewModel.marketingConsent,
              onChanged: viewModel.setMarketingConsent,
              title: const Text('[선택] 마케팅 정보 수신 동의(이메일/문자)'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),

            // 제 3자 제공 동의
            CheckboxListTile(
              value: viewModel.thirdPartyConsent,
              onChanged: viewModel.setThirdPartyConsent,
              title: const Text('[선택] 제3자 제공/국외 이전 동의(서비스 인프라 제공자)'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}
