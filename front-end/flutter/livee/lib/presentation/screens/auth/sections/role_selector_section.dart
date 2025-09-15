import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/auth/vm/signup_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';

// 회원가입 시 역할(쇼호스트/브랜드)을 선택하는 섹션 UI
class RoleSelectorSection extends StatelessWidget {
  final SignupViewModel viewModel;

  const RoleSelectorSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text.rich(
            TextSpan(
              text: '역할 선택',
              children: [
                const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                    ))
              ],
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                Row(
                  children: [
                    _buildRoleButton('showhost', '쇼호스트'),
                    _buildRoleButton('brand', '브랜드'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 역할 선택 버튼의 개별 UI
  Widget _buildRoleButton(String role, String label) {
    final isSelected = viewModel.selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => viewModel.setSelectedRole(role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textGrey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
