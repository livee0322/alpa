// lib/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  // 선택된 역할을 저장할 상태 변수
  String _selectedRole = 'brand'; // 기본값 'brand'

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await Provider.of<AuthProvider>(context, listen: false).login(
          _emailController.text,
          _passwordController.text,
        );
        // 로그인 성공 시 메인 화면으로 이동
        if (context.mounted) GoRouter.of(context).go('/');
      } catch (e) {
        setState(() {
          _errorMessage = e
              .toString()
              .replaceFirst('Exception: ', ''); // "Exception: " 접두어 제거
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 역할 선택 버튼 UI를 생성하는 위젯 메소드
  Widget _buildRoleSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Row(
        children: [
          _buildRoleButton('brand', '브랜드'),
          _buildRoleButton('showhost', '쇼호스트'),
        ],
      ),
    );
  }

  // 개별 역할 버튼 위젯
  Widget _buildRoleButton(String role, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
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
              color: isSelected
                  ? const Color(0xFF111827)
                  : const Color(0xFF374151),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/liveelogo.png',
                    height: 42,
                  ),
                  const SizedBox(height: 28),

                  // 생성한 역할 선택 위젯을 UI에 추가
                  _buildRoleSelector(),

                  TextFormField(
                    controller: _emailController,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Color(0xFFE11D48),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFFD8DBE2),
                    ),
                    child: Text(
                      _isLoading ? '로그인 중...' : '로그인',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '아직 계정이 없으신가요? ',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
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
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }
}
