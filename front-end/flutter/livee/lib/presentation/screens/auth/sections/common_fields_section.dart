import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/auth/vm/signup_view_model.dart';
import 'package:livee/presentation/common/custom_text_form_field.dart';

// 회원가입 공통 입력 필드 섹션 UI
class CommonFieldsSection extends StatelessWidget {
  final SignupViewModel viewModel;

  const CommonFieldsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 이메일
        CustomTextFormField(
          controller: viewModel.emailController,
          label: '이메일',
          hintText: '이메일을 입력해주세요.',
          isRequired: true,
        ),
        const SizedBox(height: 16),

        // 비밀번호
        CustomTextFormField(
          controller: viewModel.passwordController,
          label: '비밀번호',
          hintText: '비밀번호를 입력해주세요.',
          isRequired: true,
          obscureText: true,
          validator: (val) => (val == null || val.length < 8) ? '8자 이상 입력해주세요.' : null,
        ),
        const SizedBox(height: 16),

        // 비밀번호 확인
        CustomTextFormField(
          controller: viewModel.passwordConfirmController,
          label: '비밀번호 확인',
          hintText: '비밀번호를 다시 입력해주세요.',
          isRequired: true,
          obscureText: true,
          validator: (val) => (val != viewModel.passwordController.text) ? '비밀번호가 일치하지 않습니다.' : null,
        ),
        const SizedBox(height: 16),

        // 이름
        CustomTextFormField(
          controller: viewModel.nameController,
          label: '이름',
          hintText: '이름을 입력해주세요.',
          isRequired: true,
        ),
        const SizedBox(height: 16),

        // 전화번호
        CustomTextFormField(
          controller: viewModel.phoneController,
          label: '휴대폰',
          hintText: '전화번호를 입력해주세요.',
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
