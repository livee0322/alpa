import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/auth/vm/signup_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Consumer<SignupViewModel>(
                  builder: (context, viewModel, child) => Form(
                    key: viewModel.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('회원가입', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 24),
                        _buildRoleSelector(viewModel),
                        const SizedBox(height: 16),
                        _buildTextField(controller: viewModel.emailController, label: '이메일 *', hint: 'you@example.com'),
                        _buildTextField(
                            controller: viewModel.passwordController,
                            label: '비밀번호 *',
                            hint: '8자 이상',
                            isPassword: true,
                            validator: (val) => (val == null || val.length < 8) ? '8자 이상 입력해주세요.' : null),
                        _buildTextField(
                            controller: viewModel.passwordConfirmController,
                            label: '비밀번호 확인 *',
                            hint: '비밀번호를 다시 입력해주세요.',
                            isPassword: true,
                            validator: (val) => (val != viewModel.passwordController.text) ? '비밀번호가 일치하지 않습니다.' : null),
                        _buildTextField(controller: viewModel.nameController, label: '이름 *', hint: '홍길동'),
                        _buildTextField(
                            controller: viewModel.phoneController,
                            label: '휴대폰',
                            hint: '010-0000-0000',
                            isRequired: false),

                        // 역할에 따라 다른 정보 섹션 보여주기
                        if (viewModel.selectedRole == 'showhost') _buildShowhostInfoSection(viewModel),
                        if (viewModel.selectedRole == 'brand') _buildBrandInfoSection(viewModel),

                        const SizedBox(height: 24),
                        _buildTermsSection(viewModel),
                        const SizedBox(height: 24),

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
          bottomNavigationBar: const CommonBottomNavBar(),
        ),
      );

  // 공통 텍스트 필드를 생성
  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      String? hint,
      bool isPassword = false,
      bool isRequired = true,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        validator:
            validator ?? (value) => (isRequired && (value == null || value.isEmpty)) ? '$label 항목은 필수입니다.' : null,
      ),
    );
  }

  // 역할(brand/showhost) 선택 UI를 구성
  Widget _buildRoleSelector(SignupViewModel viewModel) => Row(
        children: [
          _buildRoleButton('showhost', '쇼호스트', viewModel),
          const SizedBox(width: 8),
          _buildRoleButton('brand', '브랜드', viewModel),
        ],
      );

  // 역할 선택 버튼의 개별 UI를 구성
  Widget _buildRoleButton(String role, String label, SignupViewModel viewModel) {
    final isSelected = viewModel.selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => viewModel.setSelectedRole(role),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
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

  // 쇼호스트 추가 정보 입력 섹션을 생성
  Widget _buildShowhostInfoSection(SignupViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('쇼호스트 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(controller: viewModel.nicknameController, label: '닉네임', isRequired: false),
          _buildTextField(
              controller: viewModel.snsLinkController,
              label: '대표 SNS 링크',
              hint: 'https://instagram.com/...',
              isRequired: false),
          _buildTextField(controller: viewModel.introController, label: '소개', hint: '한 줄 소개 또는 경력', isRequired: false),
        ],
      ),
    );
  }

  //  브랜드 추가 정보 입력 섹션을 생성
  Widget _buildBrandInfoSection(SignupViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('브랜드 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(controller: viewModel.brandNameController, label: '브랜드명 *', hint: '예) ACME'),
          _buildTextField(controller: viewModel.companyNameController, label: '회사명', isRequired: false),
          _buildTextField(controller: viewModel.businessNumberController, label: '사업자번호', isRequired: false),
        ],
      ),
    );
  }

  // 약관 동의 섹션을 생성
  Widget _buildTermsSection(SignupViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('약관 동의', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (viewModel.selectedRole == 'brand') ...[
            CheckboxListTile(
                value: viewModel.serviceTermsConsent,
                onChanged: viewModel.setServiceTermsConsent,
                title: const Text('[필수] 서비스 이용약관 동의'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary),
            CheckboxListTile(
                value: viewModel.privacyPolicyConsent,
                onChanged: viewModel.setPrivacyPolicyConsent,
                title: const Text('[필수] 개인정보처리방침 동의'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary),
          ],
          CheckboxListTile(
              value: viewModel.ageConsent,
              onChanged: viewModel.setAgeConsent,
              title: const Text('[필수] 만 14세 이상입니다.'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary),
          CheckboxListTile(
              value: viewModel.marketingConsent,
              onChanged: viewModel.setMarketingConsent,
              title: const Text('[선택] 마케팅 정보 수신 동의'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary),
        ],
      ),
    );
  }

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
