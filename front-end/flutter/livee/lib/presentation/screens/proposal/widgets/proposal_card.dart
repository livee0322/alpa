import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livee/domain/models/proposal.dart';
import 'package:livee/domain/usecases/proposal_use_case.dart';
import 'package:livee/presentation/screens/proposal/vm/sent_proposals_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/buttons/secondary_action_button.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:livee/service_locator.dart';
import 'package:provider/provider.dart';

// 뷰 타입을 구분하기 위한 enum
enum ProposalViewType { sent, received }

class ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final ProposalViewType viewType;
  const ProposalCard({
    super.key,
    required this.proposal,
    required this.viewType,
  });

  @override
  Widget build(BuildContext context) {
    return StandardContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildInfoRow('보낸 시각', DateFormat('yyyy. MM. dd. HH:mm').format(proposal.sentAt)),
          _buildInfoRow('출연료', proposal.isFeeNegotiable ? '협의' : '${proposal.fee}원'),
          _buildInfoRow('일정/장소', proposal.schedule ?? '미정'),
          _buildInfoRow('답장 기한',
              proposal.replyDeadline != null ? DateFormat('yyyy. MM. dd').format(proposal.replyDeadline!) : '미정'),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // ?. 와 ?? 연산자를 사용하여 null 안전하게 이름을 표시
              viewType == ProposalViewType.sent
                  ? (proposal.recipient?.name ?? '받는 사람 없음')
                  : (proposal.sender?.brandName ?? '브랜드 없음'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(proposal.content ?? '내용 없음', style: const TextStyle(color: Colors.grey)),
          ],
        ),
        _buildStatusChip(proposal.status),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    String label;
    switch (status) {
      case 'accepted':
        backgroundColor = AppColors.primary;
        label = '수락';
        break;
      case 'rejected':
        backgroundColor = AppColors.error;
        label = '거절';
        break;
      case 'withdrawn':
        backgroundColor = Colors.grey;
        label = '철회';
        break;
      default: // pending
        backgroundColor = Colors.orange;
        label = '대기';
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // viewType에 따라 다른 버튼 그룹을 렌더링
    if (viewType == ProposalViewType.sent) {
      // --- 브랜드 (보낸 사람)가 보는 버튼 ---
      switch (proposal.status) {
        case 'pending': // 대기
        case 'hold': // 보류
          return Row(children: [
            Expanded(child: SecondaryActionButton(text: '상세 보기', onPressed: () {})),
            const SizedBox(width: 8),
            Expanded(
              child: SecondaryActionButton(
                text: '제안 철회',
                onPressed: () async {
                  final confirm = await showCommonPromptDialog(
                    context: context,
                    title: '제안을 철회하시겠습니까?',
                    content: '철회한 제안은 되돌릴 수 없습니다.',
                    confirmText: '철회',
                  );
                  if (confirm == true) {
                    try {
                      // UseCase를 통해 제안 철회 API 호출
                      await locator<ProposalUseCase>().withdrawProposal(proposal.id);
                      // 성공 시 목록 새로고침
                      context.read<SentProposalsViewModel>().setFilter('all');
                      showCustomToast(context, '제안을 철회했습니다.', type: ToastType.info);
                    } catch (e) {
                      showCustomToast(context, '철회에 실패했습니다.', type: ToastType.error);
                    }
                  }
                },
              ),
            ),
          ]);
        case 'accepted': // 수락
          return Row(children: [
            Expanded(child: SecondaryActionButton(text: '상세 보기', onPressed: () {})),
            const SizedBox(width: 8),
            Expanded(child: PrimaryActionButton(text: '계약 확정', onPressed: () {})),
          ]);
        case 'rejected': // 거절
        case 'withdrawn': // 철회
          return Row(children: [
            Expanded(child: SecondaryActionButton(text: '상세 보기', onPressed: () {})),
            const SizedBox(width: 8),
            Expanded(child: PrimaryActionButton(text: '다시 제안하기', onPressed: () {})),
          ]);
        default:
          return SecondaryActionButton(text: '상세 보기', onPressed: () {});
      }
    } else {
      // --- 쇼호스트 (받는 사람)가 보는 버튼 ---
      switch (proposal.status) {
        case 'pending': // 대기
          return Row(children: [
            Expanded(child: SecondaryActionButton(text: '거절', onPressed: () {})),
            const SizedBox(width: 8),
            Expanded(child: PrimaryActionButton(text: '수락', onPressed: () {})),
          ]);
        case 'hold': // 보류
          return Row(children: [
            Expanded(child: SecondaryActionButton(text: '거절', onPressed: () {})),
            const SizedBox(width: 8),
            Expanded(child: PrimaryActionButton(text: '수락', onPressed: () {})),
          ]);
        case 'accepted': // 수락
          return SecondaryActionButton(text: '브랜드의 확정을 기다리는 중', onPressed: () {});
        default: // 거절, 철회 등
          return SecondaryActionButton(text: '완료된 제안', onPressed: () {});
      }
    }
  }
}
