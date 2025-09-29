import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livee/domain/models/proposal.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/buttons/secondary_action_button.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';

class ProposalCard extends StatelessWidget {
  final Proposal proposal;
  const ProposalCard({super.key, required this.proposal});

  @override
  Widget build(BuildContext context) {
    return StandardContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildInfoRow('보낸 시각',
              DateFormat('yyyy. MM. dd. HH:mm').format(proposal.sentAt)),
          _buildInfoRow(
              '출연료', proposal.isFeeNegotiable ? '협의' : '${proposal.fee}원'),
          _buildInfoRow('일정/장소', proposal.schedule ?? '미정'),
          _buildInfoRow(
              '답장 기한',
              proposal.replyDeadline != null
                  ? DateFormat('yyyy. MM. dd').format(proposal.replyDeadline!)
                  : '미정'),
          const SizedBox(height: 16),
          _buildActionButtons(),
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
            Text(proposal.recipient.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(proposal.content ?? '내용 없음',
                style: const TextStyle(color: Colors.grey)),
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
      label: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
              width: 70,
              child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (proposal.status == 'accepted') ...[
          Expanded(child: SecondaryActionButton(text: '상세', onPressed: () {})),
          const SizedBox(width: 8),
          Expanded(child: PrimaryActionButton(text: '계약 확정', onPressed: () {})),
        ] else if (proposal.status == 'rejected') ...[
          Expanded(child: SecondaryActionButton(text: '상세', onPressed: () {})),
          const SizedBox(width: 8),
          Expanded(
              child: SecondaryActionButton(text: '다시 제안하기', onPressed: () {})),
        ] else ...[
          // pending, withdrawn
          Expanded(child: SecondaryActionButton(text: '상세', onPressed: () {})),
        ]
      ],
    );
  }
}
