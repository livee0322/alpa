import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/vm/profile_edit_view_model_base.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';

// 포트폴리오의 '선택 정보' UI
class SelectionInfoSection extends StatelessWidget {
  final ProfileEditViewModelBase viewModel;

  const SelectionInfoSection({super.key, required this.viewModel});
  // [추가] 반복되는 UI 구조를 만드는 헬퍼 메소드
  /// 입력 위젯과 '공개' 체크박스를 한 줄에 배치하는 공통 위젯을 생성합니다.
  Widget _buildPublicSettingRow({
    required Widget inputField, // TextFormField, Dropdown 등 입력 위젯
    required bool isPublic, // 체크박스의 현재 값
    required ValueChanged<bool?> onPublicChanged, // 체크박스 값 변경 콜백
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 5,
          child: inputField,
        ),
        Spacer(),
        Expanded(
          flex: 3,
          child: InkWell(
            // 전체 영역을 탭 가능하게 만듦
            onTap: () => onPublicChanged(!isPublic),
            child: Row(
              children: [
                Checkbox(
                  value: isPublic,
                  onChanged: onPublicChanged,
                ),
                const Text('공개'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // [수정] build 메소드를 헬퍼 메소드를 사용하도록 리팩토링
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 경력
        _buildPublicSettingRow(
          inputField: CustomTextFormField(
            controller: viewModel.experienceYearsController,
            label: '경력(년)',
            keyboardType: TextInputType.number,
          ),
          isPublic: viewModel.isExperiencePublic,
          onPublicChanged: viewModel.setIsExperiencePublic,
        ),
        const SizedBox(height: 16),

        // 나이
        _buildPublicSettingRow(
          inputField: CustomTextFormField(
            controller: viewModel.ageController,
            label: '나이',
            keyboardType: TextInputType.number,
          ),
          isPublic: viewModel.isAgePublic,
          onPublicChanged: viewModel.setIsAgePublic,
        ),
        const SizedBox(height: 16),

        // 지역
        _buildPublicSettingRow(
          inputField: CustomTextFormField(
            controller: viewModel.regionController,
            label: '지역',
            hintText: '시/도 (예: 서울)',
          ),
          isPublic: viewModel.isRegionPublic,
          onPublicChanged: viewModel.setIsRegionPublic,
        ),
        const SizedBox(height: 16),

        // 성별
        _buildPublicSettingRow(
          inputField: CustomDropdown(
            menuOffset: Offset(0, 54),
            label: '성별',
            value: viewModel.gender ?? '선택 안함',
            items: const ['선택 안함', '남성', '여성'],
            onChanged: viewModel.setGender,
          ),
          isPublic: viewModel.isGenderPublic,
          onPublicChanged: viewModel.setIsGenderPublic,
        ),
        const SizedBox(height: 16),

        // 키
        _buildPublicSettingRow(
          inputField: CustomTextFormField(
            controller: viewModel.heightController,
            label: '키(cm)',
            keyboardType: TextInputType.number,
          ),
          isPublic: viewModel.isHeightPublic,
          onPublicChanged: viewModel.setIsHeightPublic,
        ),
        const SizedBox(height: 16),

        // 치수
        const Text('치수',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 8),
        CustomTextFormField(
          controller: viewModel.topSizeController,
          hintText: '상의 S/M/L',
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.bottomSizeController,
          hintText: '하의 26/28...',
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.shoeSizeController,
          hintText: '신발 240',
          keyboardType: TextInputType.number,
        ),
        CheckboxListTile(
          title: const Text('치수 정보 공개'),
          value: viewModel.isSizingPublic,
          onChanged: viewModel.setIsSizingPublic,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
