import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';

// 할인 정보 및 라이브 일정 입력 필드를 포함하는 위젯
class SaleAndLiveSection extends StatelessWidget {
  final CampaignFormProvider provider;

  const SaleAndLiveSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 할인 정보
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: provider.salePriceController,
                label: '공통 할인가(선택)',
                hint: '예) 19900',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSaleDurationDropdown(),
            ),
          ],
        ),

        // 라이브 일정
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: provider.liveDateController,
                label: '라이브 날짜',
                hint: 'YYYY-MM-DD',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: provider.liveTimeController,
                label: '라이브 시간',
                hint: 'HH:MM',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 할인 유지시간 선택 드롭다운
  Widget _buildSaleDurationDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: provider.saleDuration,
        decoration: const InputDecoration(
          labelText: '할인 유지시간',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        items: const [
          DropdownMenuItem(value: null, child: Text('설정 안 함')),
          DropdownMenuItem(value: '3600', child: Text('1시간')),
          DropdownMenuItem(value: '7200', child: Text('2시간')),
          DropdownMenuItem(value: '10800', child: Text('3시간 (최대)')),
        ],
        onChanged: (value) {
          provider.setSaleDuration(value);
        },
      ),
    );
  }

  // 공통 텍스트 필드
  Widget _buildTextField(
      {required TextEditingController controller,
      String? label,
      String? hint,
      TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
