import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';

// '쇼호스트 모집'에 해당하는 모든 입력 필드를 포함하는 위젯
class RecruitFormSection extends StatelessWidget {
  final CampaignFormProvider provider;

  const RecruitFormSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: provider.titleRecruitController,
          label: '공개 제목',
          hint: '예) 잘 먹는 쇼호스트 찾습니다',
          isRequired: true,
        ),
        // 촬영일 & 모집 마감일
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: provider.dateController,
                label: '촬영일',
                hint: 'YYYY-MM-DD',
                isRequired: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: provider.deadlineController,
                label: '모집 마감일',
                hint: 'YYYY-MM-DD',
              ),
            ),
          ],
        ),
        // 촬영 시간
        const Text(
          '촬영 시간',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: provider.timeStartController,
                hint: '시작 시간',
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('~'),
            ),
            Expanded(
              child: _buildTextField(
                  controller: provider.timeEndController, hint: '종료 시간'),
            ),
          ],
        ),
        // 계산된 촬영 시간 표시
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4, bottom: 16),
          child: Text(
            provider.durationText,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // 촬영 장소
        _buildTextField(
            controller: provider.locationController,
            label: '촬영 장소',
            hint: '예) 서울 강남구 ○○스튜디오'),
        // 출연료
        _buildPayField(provider),
      ],
    );
  }

  // 공통 텍스트 필드 위젯 (Stateless 위젯 내의 헬퍼 메소드)
  Widget _buildTextField(
      {required TextEditingController controller,
      String? label,
      String? hint,
      bool isRequired = false,
      String? helperText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label != null ? (isRequired ? '$label *' : label) : null,
          hintText: hint,
          helperText: helperText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label을(를) 입력해주세요.';
          }
          return null;
        },
      ),
    );
  }

  // 출연료 입력 필드 위젯
  Widget _buildPayField(CampaignFormProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '출연료',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: provider.payWanController,
                decoration: const InputDecoration(
                  hintText: '숫자만 입력 (예: 30)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  suffixText: '만원',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  Checkbox(
                    value: provider.payNegotiable,
                    onChanged: (value) =>
                        provider.setPayNegotiable(value ?? false),
                  ),
                  const Text('협의 가능'),
                ],
              ),
            ),
          ],
        ),
        if (provider.payWanPreview.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12, bottom: 16),
            child: Text(
              provider.payWanPreview,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
