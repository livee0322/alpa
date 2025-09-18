import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/auth/vm/login_view_model.dart';
import 'package:livee/presentation/widgets/bouncing_speech_bubble.dart';
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
                          height: 128,
                        ),
                        const SizedBox(height: 72),
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
        ),
      );

  /// 역할(brand/showhost)을 선택하는 버튼 UI를 구성
  Widget _buildRoleSelector(LoginViewModel viewModel) => Container(
        margin: const EdgeInsets.only(bottom: 22),
        // [추가] LayoutBuilder로 Stack을 감싸서 부모의 너비(constraints.maxWidth)를 얻어옵니다.
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 기존 역할 선택 버튼 UI
                Container(
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
                ),
                // [수정] Positioned 위젯의 위치를 LayoutBuilder가 제공하는 너비에 따라 동적으로 계산합니다.
                Positioned(
                  top: -52,
                  // left를 부모 너비의 절반으로 설정하여 '쇼호스트' 버튼 영역의 시작점에 맞춥니다.
                  left: constraints.maxWidth / 2,
                  right: 0, // right를 0으로 설정하여 '쇼호스트' 버튼 영역의 끝점에 맞춥니다.
                  child: Align(
                    // Align 위젯을 사용해 '쇼호스트' 버튼 영역 내에서 말풍선을 정확히 가운데 정렬합니다.
                    alignment: Alignment.center,
                    child: const BouncingSpeechBubble(text: '모델도 여기!'),
                  ),
                ),
              ],
            );
          },
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
