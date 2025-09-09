import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/auth/vm/login_view_model.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  /// 화면의 전체적인 UI 구조를 구성하고 ViewModel과 연결
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => LoginViewModel(context),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Consumer<LoginViewModel>(
                  builder: (context, viewModel, child) => Form(
                    key: viewModel.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/liveelogo.png',
                        ),
                        _buildRoleSelector(viewModel),
                        TextFormField(
                          controller: viewModel.emailController,
                          decoration: const InputDecoration(
                            hintText: 'you@example.com',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6C63FF)),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => (value == null || value.isEmpty) ? '이메일을 입력해주세요.' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: viewModel.passwordController,
                          decoration: const InputDecoration(
                            hintText: '••••••••',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6C63FF)),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) => (value == null || value.isEmpty) ? '비밀번호를 입력해주세요.' : null,
                        ),
                        const SizedBox(height: 24),
                        PrimaryActionButton(
                          text: viewModel.isLoading ? '로그인 중...' : '로그인',
                          onPressed: viewModel.login,
                          isLoading: viewModel.isLoading,
                        ),
                        const SizedBox(height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '아직 계정이 없으신가요? ',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                            ),
                            InkWell(
                              onTap: () => GoRouter.of(context).go('/signup'),
                              child: const Text(
                                '회원가입',
                                style: TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
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
  Widget _buildRoleSelector(LoginViewModel viewModel) => Container(
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E8EC)),
        ),
        child: Row(
          children: [
            _buildRoleButton('brand', '브랜드', viewModel),
            _buildRoleButton('showhost', '쇼호스트', viewModel),
          ],
        ),
      );

  /// 역할 선택 버튼의 개별 UI를 구성
  Widget _buildRoleButton(String role, String label, LoginViewModel viewModel) {
    final isSelected = viewModel.selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => viewModel.setSelectedRole(role),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF111827) : const Color(0xFF374151),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
