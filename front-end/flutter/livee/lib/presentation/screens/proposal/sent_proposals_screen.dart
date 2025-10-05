import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/proposal/vm/sent_proposals_view_model.dart';
import 'package:livee/presentation/screens/proposal/widgets/proposal_card.dart';
import 'package:livee/presentation/common/custom_dropdown.dart';
import 'package:livee/presentation/common/loading_overlay.dart';
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

  // 제목과 드롭다운을 함께 배치
  Widget _buildHeader(BuildContext context, SentProposalsViewModel viewModel) {
    return SafeArea(
      bottom: false, // SafeArea의 아래쪽 패딩은 필요 없으므로 제거
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '보낸 제안',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 120, // 드롭다운의 너비를 지정
              child: CustomDropdown(
                // ViewModel의 Map을 사용하여 현재 필터 key에 해당하는 표시 이름을 찾기
                value: viewModel.filterOptions[viewModel.currentFilter] ?? '전체',
                // ViewModel의 Map에서 표시 이름 목록을 가져오기
                items: viewModel.filterOptions.values.toList(),
                menuOffset: Offset(0, 42),
                onChanged: (selectedValue) {
                  if (selectedValue != null) {
                    // 선택된 표시 이름(selectedValue)을 통해 key를 찾아서 API를 호출
                    final selectedKey =
                        viewModel.filterOptions.entries.firstWhere((entry) => entry.value == selectedValue).key;
                    viewModel.setFilter(selectedKey);
                  }
                },
                // 작은 드롭다운 스타일에 맞게 패딩과 폰트 크기를 조정
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalList(BuildContext context, SentProposalsViewModel viewModel) {
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
        return ProposalCard(proposal: proposal, viewType: ProposalViewType.sent);
      },
    );
  }
}
