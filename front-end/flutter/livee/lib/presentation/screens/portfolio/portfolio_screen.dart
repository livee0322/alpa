import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/portfolio/vm/portfolio_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/buttons/common_floating_action_button.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortfolioViewModel(),
      child: Consumer<PortfolioViewModel>(
        builder: (context, viewModel, child) {
          final authProvider = context.watch<AuthProvider>();
          return Scaffold(
            // LoadingOverlay를 사용하여 전체 로딩 상태를 관리
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: Column(
                children: [
                  _buildSearchBar(context, viewModel),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '카드를 누르면 상세 프로필을 보실 수 있어요.',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildPortfolioList(context, viewModel),
                  ),
                ],
              ),
            ),
            // 버튼 노출 조건을 '브랜드 회원이 아닐 때'로 변경 (쇼호스트 or 비회원)
            floatingActionButton: authProvider.role != 'brand'
                ? CommonFloatingActionButton(
                    onPressed: () async {
                      // 버튼 클릭 시 로그인 상태를 먼저 확인
                      if (!authProvider.isLoggedIn) {
                        // 비회원이면 로그인 유도 팝업을
                        final result = await showCommonPromptDialog(
                          context: context,
                          title: '로그인이 필요합니다',
                          content: '포트폴리오를 등록하려면 로그인이 필요합니다.\n로그인 페이지로 이동하시겠습니까?',
                          confirmText: '로그인',
                        );
                        if (result == true && context.mounted) {
                          GoRouter.of(context).replace('/login');
                        }
                      } else {
                        // 로그인 상태(쇼호스트)이면 등록 페이지로 이동
                        GoRouter.of(context).go('/portfolio-edit');
                      }
                    },
                  )
                : null, // 브랜드 회원이면 버튼을 표시 X
          );
        },
      ),
    );
  }

  // 검색 바와 정렬 드롭다운을 포함한 상단 UI
  Widget _buildSearchBar(BuildContext context, PortfolioViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 검색창
          Expanded(
            child: TextField(
              onSubmitted: (value) => viewModel.search(value),
              decoration: InputDecoration(
                hintText: '검색',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 정렬 드롭다운
          CustomDropdown(
            menuOffset: Offset(0, 50),
            value: '최신순', // TODO: ViewModel의 sortBy와 연동
            items: const ['최신순', '인기순'],
            onChanged: (value) => viewModel.setSortBy(value),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          )
        ],
      ),
    );
  }

  // 포트폴리오 목록을 표시하는 UI
  Widget _buildPortfolioList(BuildContext context, PortfolioViewModel viewModel) {
    if (viewModel.portfolios.isEmpty && !viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('아직 등록된 포트폴리오가 없어요.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: viewModel.portfolios.length,
      itemBuilder: (context, index) {
        final portfolio = viewModel.portfolios[index];
        return _buildPortfolioCard(context, portfolio);
      },
    );
  }

  // 개별 포트폴리오 정보를 표시하는 카드
  Widget _buildPortfolioCard(BuildContext context, Portfolio portfolio) {
    return StandardContentCard(
      onTap: () => GoRouter.of(context).go('/portfolios/${portfolio.id}'),
      child: Row(
        children: [
          // 프로필 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              portfolio.mainThumbnailUrl ?? 'https://picsum.photos/seed/${portfolio.id}/100/100',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: AppColors.disabled),
            ),
          ),
          const SizedBox(width: 16),
          // 정보 (이름, 소개, 나이)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portfolio.nickname ?? '이름 없음',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  portfolio.oneLineIntro ?? '소개 준비 중',
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (portfolio.age != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.disabled,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('만 ${portfolio.age}세', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  ),
              ],
            ),
          ),
          // 찜하기 버튼
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.grey),
            onPressed: () {
              // TODO: 찜하기 기능 구현
            },
          ),
        ],
      ),
    );
  }
}
