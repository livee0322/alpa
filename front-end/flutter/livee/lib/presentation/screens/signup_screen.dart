import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  String _selectedRole = 'brand';

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await Provider.of<AuthProvider>(context, listen: false).signup(
          _nicknameController.text,
          _emailController.text,
          _passwordController.text,
          _selectedRole,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인 해주세요.')),
        );
        GoRouter.of(context).go('/login');
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 역할 선택 버튼 위젯
  Widget _buildRoleSelector() {
    return Row(
      children: [
        _buildRoleButton('brand', '브랜드(업체)'),
        const SizedBox(width: 8),
        _buildRoleButton('showhost', '쇼호스트'),
      ],
    );
  }

  // 역할 버튼 개별 위젯
  Widget _buildRoleButton(String role, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = role; //
          });
        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
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
                  _buildRoleSelector(),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: '닉네임',
                      hintText: '라이비',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '닉네임을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      hintText: 'example@livee.co',
                      border: OutlineInputBorder(
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
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      hintText: '6자 이상',
                      border: OutlineInputBorder(
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
                  const SizedBox(height: 16),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  SizedBox(height: _errorMessage.isNotEmpty ? 16 : 0),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: const Color(0xFF5B5EE6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                    ),
                    child: Text(
                      _isLoading ? '가입 중...' : '가입하기',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '이미 계정이 있나요? ',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
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
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }
}
