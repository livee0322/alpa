import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/proposal/vm/received_proposals_view_model.dart';
import 'package:livee/presentation/screens/proposal/widgets/proposal_card.dart';
import 'package:livee/presentation/common/custom_dropdown.dart';
import 'package:livee/presentation/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class ReceivedProposalsScreen extends StatelessWidget {
  const ReceivedProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReceivedProposalsViewModel(),
      child: Consumer<ReceivedProposalsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: Column(
                children: [
                  _buildHeader(context, viewModel),
                  Expanded(child: _buildProposalList(context, viewModel)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 페이지 헤더 (제목 + 필터 드롭다운) UI
  Widget _buildHeader(BuildContext context, ReceivedProposalsViewModel viewModel) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '받은 제안',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 120,
              child: CustomDropdown(
                value: viewModel.filterOptions[viewModel.currentFilter] ?? '전체',
                items: viewModel.filterOptions.values.toList(),
                menuOffset: Offset(0, 42),
                onChanged: (selectedValue) {
                  if (selectedValue != null) {
                    final selectedKey =
                        viewModel.filterOptions.entries.firstWhere((entry) => entry.value == selectedValue).key;
                    viewModel.setFilter(selectedKey);
                  }
                },
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 제안 목록 리스트 UI
  Widget _buildProposalList(BuildContext context, ReceivedProposalsViewModel viewModel) {
    if (viewModel.items.isEmpty && !viewModel.isLoading) {
      return const Center(child: Text('받은 제안이 없습니다.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.items.length + (viewModel.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.items.length) {
          viewModel.loadMore();
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final proposal = viewModel.items[index];
        return ProposalCard(proposal: proposal, viewType: ProposalViewType.received);
      },
    );
  }
}
