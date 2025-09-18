import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/auth/sections/additional_info_section.dart';
import 'package:livee/presentation/screens/auth/sections/common_fields_section.dart';
import 'package:livee/presentation/screens/auth/sections/role_selector_section.dart';
import 'package:livee/presentation/screens/auth/sections/terms_section.dart';
import 'package:livee/presentation/screens/auth/vm/signup_view_model.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

// 회원가입 화면 UI를 구성
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => SignupViewModel(context),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Consumer<SignupViewModel>(
                  builder: (context, viewModel, child) => Form(
                    key: viewModel.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 페이지 제목
                        Container(
                          padding: EdgeInsets.only(bottom: 30),
                          child: Text(
                            '회원가입',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                          ),
                        ),

                        // 역할 선택 섹션
                        RoleSelectorSection(viewModel: viewModel),

                        // 공통 입력 섹션
                        CommonFieldsSection(viewModel: viewModel),

                        // 추가 입력 섹션
                        AdditionalInfoSection(viewModel: viewModel),

                        // 약관 동의 섹션
                        TermsSection(viewModel: viewModel),

                        // 버튼 입력 섹션
                        PrimaryActionButton(
                          text: '가입하기',
                          onPressed: viewModel.signup,
                          isLoading: viewModel.isLoading,
                        ),
                        const SizedBox(height: 24),
                        _buildLoginPrompt(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  // 이미 계정이 있을 경우 로그인 화면으로 이동시키는 UI를 생성
  Widget _buildLoginPrompt(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '이미 계정이 있나요? ',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          InkWell(
            onTap: () => GoRouter.of(context).go('/login'),
            child: const Text(
              '로그인',
              style: TextStyle(
                color: Color(0xFF374151),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );
}
