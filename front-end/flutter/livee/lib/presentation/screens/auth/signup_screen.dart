import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/auth/vm/signup_view_model.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  /// 화면의 전체적인 UI 구조를 구성하고 ViewModel과 연결
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => SignupViewModel(context),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                // Consumer를 사용하여 ViewModel의 변경사항을 감지하고 UI를 다시 그리기
                child: Consumer<SignupViewModel>(
                  builder: (context, viewModel, child) => Form(
                    key: viewModel.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildRoleSelector(viewModel),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: viewModel.nicknameController,
                          decoration: const InputDecoration(
                            labelText: '닉네임',
                            hintText: '라이비',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? '닉네임을 입력해주세요.' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: viewModel.emailController,
                          decoration: const InputDecoration(
                            labelText: '이메일',
                            hintText: 'example@livee.co',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => (value == null || value.isEmpty) ? '이메일을 입력해주세요.' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: viewModel.passwordController,
                          decoration: const InputDecoration(
                            labelText: '비밀번호',
                            hintText: '6자 이상',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) => (value == null || value.isEmpty) ? '비밀번호를 입력해주세요.' : null,
                        ),
                        const SizedBox(height: 16),
                        PrimaryActionButton(
                          text: '가입하기',
                          onPressed: viewModel.signup,
                          isLoading: viewModel.isLoading,
                        ),
                        const SizedBox(height: 16),
                        Row(
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: const CommonBottomNavBar(),
        ),
      );

  /// 역할(brand/showhost)을 선택하는 버튼 UI를 구성
  Widget _buildRoleSelector(SignupViewModel viewModel) => Row(
        children: [
          _buildRoleButton('brand', '브랜드(업체)', viewModel),
          const SizedBox(width: 8),
          _buildRoleButton('showhost', '쇼호스트', viewModel),
        ],
      );

  /// 역할 선택 버튼의 개별 UI를 구성
  Widget _buildRoleButton(String role, String label, SignupViewModel viewModel) {
    final isSelected = viewModel.selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => viewModel.setSelectedRole(role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF374151),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
