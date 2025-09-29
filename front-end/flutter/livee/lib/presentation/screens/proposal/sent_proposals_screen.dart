import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/proposal/vm/sent_proposals_view_model.dart';
import 'package:livee/presentation/screens/proposal/widgets/proposal_card.dart';
import 'package:livee/presentation/widgets/buttons/secondary_chip_button.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class SentProposalsScreen extends StatelessWidget {
  const SentProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SentProposalsViewModel(),
      child: Consumer<SentProposalsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('보낸 제안')),
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: Column(
                children: [
                  _buildFilterChips(context, viewModel),
                  Expanded(child: _buildProposalList(context, viewModel)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(
      BuildContext context, SentProposalsViewModel viewModel) {
    final filters = {
      'all': '전체',
      'pending': '대기',
      'accepted': '수락',
      'rejected': '거절',
      'withdrawn': '철회'
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: filters.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SecondaryChipButton(
                text: entry.value,
                isSelected: viewModel.currentFilter == entry.key,
                onPressed: () => viewModel.setFilter(entry.key),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProposalList(
      BuildContext context, SentProposalsViewModel viewModel) {
    if (viewModel.proposals.isEmpty && !viewModel.isLoading) {
      return const Center(child: Text('보낸 제안이 없습니다.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.proposals.length + (viewModel.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.proposals.length) {
          viewModel.fetchNextPage();
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final proposal = viewModel.proposals[index];
        return ProposalCard(proposal: proposal);
      },
    );
  }
}
