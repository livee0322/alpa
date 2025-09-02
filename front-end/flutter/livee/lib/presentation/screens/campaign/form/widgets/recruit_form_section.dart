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
        // 브랜드명, 제목 필드
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: provider.brandController,
                label: '브랜드명',
                hint: '예) ACME',
                isRequired: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: provider.titleRecruitController,
                label: '제목',
                hint: '예) 9월 신제품 쇼핑라이브',
                isRequired: true,
              ),
            ),
          ],
        ),
        // [추가] 내용(브리프) 필드
        _buildTextField(
          controller: provider.descRecruitController, // provider에 이미 존재
          label: '내용(브리프)',
          hint: '요구역량/참고링크 등을 자유롭게 입력',
          maxLines: 5,
        ),
        // [추가] 카테고리 필드 (Dropdown으로 변경)
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: '카테고리 *',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            items: const [
              DropdownMenuItem(value: '뷰티', child: Text('뷰티')),
              DropdownMenuItem(value: '패션', child: Text('패션')),
              DropdownMenuItem(value: '식품', child: Text('식품')),
              DropdownMenuItem(value: '가전', child: Text('가전')),
              DropdownMenuItem(value: '생활/리빙', child: Text('생활/리빙')),
            ],
            onChanged: (value) {
              provider.categoryRecruitController.text = value ?? '';
            },
            validator: (value) => (value == null || value.isEmpty) ? '카테고리를 선택해주세요.' : null,
          ),
        ),
        _buildTextField(controller: provider.locationController, label: '장소(선택)', hint: '예) 서울 성수동 스튜디오'),
        // 촬영일 & 모집 마감일
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDateField(context, controller: provider.dateController, label: '촬영일 *'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(context, controller: provider.deadlineController, label: '마감일 *'),
            ),
          ],
        ),
        // 촬영 시간
        Row(
          children: [
            Expanded(
              child: _buildTimeField(context, controller: provider.timeStartController, label: '시작 *'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeField(context, controller: provider.timeEndController, label: '종료 *'),
            ),
          ],
        ),
        _buildPayField(provider),
      ],
    );
  }

  // 날짜 선택 기능이 포함된 텍스트 필드 위젯
  Widget _buildDateField(BuildContext context, {required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true, // 직접 수정을 막음
        decoration: InputDecoration(
          labelText: label,
          hintText: '연도-월-일',
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                controller.text = "${pickedDate.toLocal()}".split(' ')[0];
              }
            },
          ),
        ),
        validator: (value) => (value == null || value.isEmpty) ? '날짜를 선택해주세요.' : null,
      ),
    );
  }

  // 시간 선택 기능이 포함된 텍스트 필드 위젯
  Widget _buildTimeField(BuildContext context, {required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: '-- : --',
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          suffixIcon: IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                controller.text = pickedTime.format(context);
              }
            },
          ),
        ),
        validator: (value) => (value == null || value.isEmpty) ? '시간을 선택해주세요.' : null,
      ),
    );
  }

  // 출연료 입력 필드에 비활성화 로직 추가
  Widget _buildPayField(CampaignFormProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                // payNegotiable 값에 따라 활성화/비활성화 상태 변경
                enabled: !provider.payNegotiable,
                controller: provider.payWanController,
                decoration: const InputDecoration(
                  labelText: '출연료(원)',
                  hintText: '예) 300000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        // 협의 가능 체크박스
        Row(
          children: [
            Checkbox(
              value: provider.payNegotiable,
              onChanged: (value) => provider.setPayNegotiable(value ?? false),
            ),
            const Text('협의 가능 (체크 시 출연료 입력 비활성화)'),
          ],
        ),
      ],
    );
  }

  // 공통 텍스트 필드 위젯 (Stateless 위젯 내의 헬퍼 메소드)
  Widget _buildTextField({
    required TextEditingController controller,
    String? label,
    String? hint,
    bool isRequired = false,
    String? helperText,
    int maxLines = 1,
  }) {
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
}
