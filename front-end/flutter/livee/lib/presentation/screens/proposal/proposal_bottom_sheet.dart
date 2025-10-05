import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/presentation/screens/proposal/vm/proposal_view_model.dart';
import 'package:livee/presentation/common/buttons/primary_action_button.dart';
import 'package:livee/presentation/common/buttons/secondary_action_button.dart';
import 'package:livee/presentation/common/custom_text_form_field.dart';
import 'package:provider/provider.dart';

/// '제안 보내기' 전체 UI를 표시하는 함수
/// ViewModel을 생성하고 바텀시트를 호출하는 로직을 통합
void showProposalBottomSheet(BuildContext context, {required Portfolio portfolio}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 키보드가 올라와도 UI가 가려지지 않도록 설정
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => ProposalViewModel(portfolio: portfolio, context: context),
      child: const ProposalBottomSheet(), // portfolio를 직접 전달하지 않음
    ),
  );
}

/// '제안 보내기' UI를 담당하는 바텀시트 위젯
class ProposalBottomSheet extends StatelessWidget {
  const ProposalBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer를 사용하여 ViewModel에 접근
    return Consumer<ProposalViewModel>(
      builder: (context, viewModel, child) {
        // 키보드 영역을 제외한 나머지 부분에 패딩을 적용
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: FractionallySizedBox(
            heightFactor: 0.85, // 화면 높이의 85%를 차지하도록 수정
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: viewModel.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, viewModel),
                          const SizedBox(height: 24),
                          _buildFormFields(context, viewModel),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: _buildActionButtons(context, viewModel),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 헤더 UI (쇼호스트 정보, 닫기 버튼)
  Widget _buildHeader(BuildContext context, ProposalViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '제안 보내기',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: viewModel.portfolio.mainThumbnailUrl != null
                  ? NetworkImage(viewModel.portfolio.mainThumbnailUrl!)
                  : null,
              child: viewModel.portfolio.mainThumbnailUrl == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.portfolio.nickname ?? '쇼호스트',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '포트폴리오 ID: ${viewModel.portfolio.id}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  /// 폼 입력 필드 전체 UI
  Widget _buildFormFields(BuildContext context, ProposalViewModel viewModel) {
    return Column(
      children: [
        CustomTextFormField(
          controller: viewModel.brandNameController,
          label: '브랜드명',
          hintText: '예) 라이비',
          isRequired: true,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: viewModel.feeController,
                label: '출연료',
                hintText: '예) 300000',
                keyboardType: TextInputType.number,
                // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                // // '협의' 체크 시 비활성화
                // enabled: !viewModel.isFeeNegotiable,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0, left: 8.0),
              child: Row(
                children: [
                  Checkbox(
                    value: viewModel.isFeeNegotiable,
                    onChanged: viewModel.toggleFeeNegotiable,
                  ),
                  const Text('협의'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 촬영일
        _buildDateField(
          context: context,
          label: '촬영일',
          value: viewModel.formatDate(viewModel.shootingDate),
          onTap: () => viewModel.selectDate(context, isShootingDate: true),
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.shootingTimeController,
          label: '촬영 시간',
          hintText: '예) 14:00~16:00',
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.locationController,
          label: '장소',
          hintText: '예) 서울 강남구 ...',
        ),
        const SizedBox(height: 16),
        // 답장 기한
        _buildDateField(
          context: context,
          label: '답장 기한',
          value: viewModel.formatDate(viewModel.replyDeadline),
          onTap: () => viewModel.selectDate(context, isShootingDate: false),
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.contentController,
          label: '내용 (선택)',
          hintText: '간단한 제안 내용을 작성하세요 (최대 800자)',
          maxLines: 5,
        ),
      ],
    );
  }

  /// 날짜 선택 필드 UI
  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value.isEmpty ? '연도-월-일' : value,
                  style: TextStyle(
                    color: value.isEmpty ? Colors.grey[500] : Colors.black,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 하단 액션 버튼 UI
  Widget _buildActionButtons(BuildContext context, ProposalViewModel viewModel) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: SecondaryActionButton(
                text: '취소',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PrimaryActionButton(
                text: '보내기',
                onPressed: viewModel.submitProposal,
                isLoading: viewModel.isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
