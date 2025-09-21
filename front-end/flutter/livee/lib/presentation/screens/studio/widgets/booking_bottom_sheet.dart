import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';

/// '스튜디오 예약/결제' 정보를 입력받는 바텀시트 위젯
class BookingBottomSheet extends StatefulWidget {
  const BookingBottomSheet({super.key});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  // --- 상태 변수 ---
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '10:00';
  String _selectedPaymentMethod = '신용/체크카드';

  @override
  Widget build(BuildContext context) {
    // 키보드가 올라올 때 UI가 가려지지 않도록 처리합니다.
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          runSpacing: 20,
          children: [
            _buildHeader(),
            _buildDatePicker(),
            _buildTimePicker(),
            _buildPaymentPicker(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// [위젯] 헤더 (제목, 닫기 버튼)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('예약/결제',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// [위젯] 날짜 선택 필드
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('날짜 선택', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(
              text: "${_selectedDate.toLocal()}".split(' ')[0]),
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate != null && pickedDate != _selectedDate) {
              setState(() => _selectedDate = pickedDate);
            }
          },
        ),
      ],
    );
  }

  /// [위젯] 시간 선택 드롭다운 (공통 위젯 사용)
  Widget _buildTimePicker() {
    return CustomDropdown(
      label: '시간 선택',
      value: _selectedTime,
      items: const [
        '10:00',
        '11:00',
        '12:00',
        '13:00',
        '14:00',
        '15:00',
        '16:00',
        '17:00'
      ],
      onChanged: (value) {
        if (value != null) setState(() => _selectedTime = value);
      },
    );
  }

  /// [위젯] 결제 수단 선택 드롭다운 (공통 위젯 사용)
  Widget _buildPaymentPicker() {
    return CustomDropdown(
      label: '결제 수단',
      value: _selectedPaymentMethod,
      items: const ['신용/체크카드', '무통장입금', '카카오페이'],
      onChanged: (value) {
        if (value != null) setState(() => _selectedPaymentMethod = value);
      },
    );
  }

  /// [위젯] 하단 액션 버튼 (취소, 결제하기)
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: AppColors.textBlack,
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Text('취소'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PrimaryActionButton(
            text: '결제하기',
            onPressed: () {
              // TODO: 결제 로직 연동
            },
          ),
        ),
      ],
    );
  }
}
