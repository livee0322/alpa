// [파일경로/파일명] lib/presentation/screens/campaign/campaigns_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/campaign/vm/campaigns_view_model.dart';
import 'package:livee/presentation/screens/apply/apply_bottom_sheet.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/common/buttons/common_floating_action_button.dart';
import 'package:livee/presentation/common/common_prompt_dialog.dart';
import 'package:livee/presentation/common/custom_dropdown.dart';
import 'package:livee/presentation/common/custom_toast.dart';
import 'package:livee/presentation/common/loading_overlay.dart';
import 'package:livee/presentation/common/standard_content_card.dart';
import 'package:provider/provider.dart';

/// 모든 사용자에게 공개된 '모집 공고' 목록을 보여주는 페이지
class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CampaignsViewModel>(
      builder: (context, viewModel, child) {
        final authProvider = context.watch<AuthProvider>();
        // 정렬 옵션 Map은 build 메소드 내 지역 변수로 관리
        final Map<String, String> sortOptions = {
          'latest': '최신 등록순',
          'deadline': '마감 임박순',
        };

        return Scaffold(
          body: LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: Column(
              children: [
                // 검색 및 정렬 UI
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        onSubmitted: (value) => viewModel.search(value),
                        decoration: InputDecoration(
                          hintText: '제목·내용·브랜드로 검색',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('총 ${viewModel.totalItems}건'),
                          SizedBox(
                            width: 140,
                            child: CustomDropdown(
                              menuOffset: Offset(0, 42),
                              value: sortOptions[viewModel.sortBy] ?? '정렬 기준',
                              items: sortOptions.values.toList(),
                              onChanged: (String? selectedValue) {
                                final sortKey = sortOptions.entries.firstWhere((e) => e.value == selectedValue).key;
                                viewModel.setSortBy(sortKey);
                              },
                              fontSize: 14,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 공고 목록 UI
                Expanded(
                  child: _buildCampaignList(context, viewModel),
                ),
                // 페이지네이션 UI
                if (viewModel.totalPages > 1) _buildPaginationControls(viewModel),
              ],
            ),
          ),
          // 글쓰기 버튼
          floatingActionButton: authProvider.role == 'showhost'
              ? null
              : CommonFloatingActionButton(
                  icon: Icons.add,
                  onPressed: () async {
                    if (!authProvider.isLoggedIn) {
                      final result = await showCommonPromptDialog(
                        context: context,
                        title: '로그인이 필요합니다',
                        content: '공고를 등록하려면 브랜드 회원으로 로그인해야 합니다.\n로그인 페이지로 이동하시겠습니까?',
                        confirmText: '로그인',
                      );
                      if (result == true && context.mounted) {
                        context.go('/login');
                      }
                    } else {
                      context.go('/campaign-form');
                    }
                  },
                ),
        );
      },
    );
  }

  /// 공고 목록을 빌드하는 헬퍼 메소드
  Widget _buildCampaignList(BuildContext context, CampaignsViewModel viewModel) {
    if (viewModel.items.isEmpty && !viewModel.isLoading) {
      return const Center(child: Text('표시할 공고가 없습니다.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.items.length,
      itemBuilder: (context, index) {
        final campaign = viewModel.items[index];
        return _buildCampaignCard(context, campaign, viewModel);
      },
    );
  }

  /// StandardContentCard를 사용하여 새로운 카드 UI를 구성하는 헬퍼 메소드
  Widget _buildCampaignCard(BuildContext context, Campaign campaign, CampaignsViewModel viewModel) {
    final authProvider = context.watch<AuthProvider>();
    String feeText = '미정';
    if (campaign.fee != null && campaign.fee! > 0) {
      feeText = '${(campaign.fee! / 10000).round()}만원';
    } else if (campaign.feeNegotiable == true) {
      feeText = '협의';
    }
    final deadline = campaign.closeAt != null ? DateFormat('yyyy-MM-dd').format(campaign.closeAt!) : '미정';

    return StandardContentCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      onTap: () => context.push('/campaign/${campaign.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 썸네일 이미지와 AD 뱃지
          Stack(
            children: [
              Image.network(
                campaign.coverImageUrl ?? 'https://picsum.photos/seed/${campaign.id}/400/200',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: AppColors.disabled,
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
              if (campaign.isAd == true)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.black.withAlpha(179),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          // 공고 정보 (제목, 브랜드, 메타데이터, 지원 버튼)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title ?? '제목 없음',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${campaign.brandName ?? '브랜드 미정'} · 출연료 $feeText · 마감 $deadline',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send, size: 18),
                    label: Text(authProvider.recruitButtonText),
                    onPressed: () async {
                      if (!authProvider.isLoggedIn) {
                        final confirm = await showCommonPromptDialog(
                          context: context,
                          title: '로그인이 필요합니다',
                          content: '공고에 지원하려면 로그인이 필요해요.\n로그인 페이지로 이동하시겠습니까?',
                          confirmText: '로그인',
                        );
                        if (confirm == true) context.go('/login');
                        return;
                      }

                      switch (authProvider.role) {
                        case 'showhost':
                          if (campaign.isApplied == true) {
                            showCustomToast(context, '이미 지원한 공고입니다.', type: ToastType.info);
                          } else {
                            final result = await showApplyBottomSheet(context, campaign);
                            if (result == true) {
                              viewModel.refresh();
                            }
                          }
                          break;
                        case 'brand':
                          context.go('/campaign/${campaign.id}/applicants');
                          break;
                        default:
                          showApplyBottomSheet(context, campaign);
                          break;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 페이지네이션 컨트롤을 빌드하는 헬퍼 메소드
  Widget _buildPaginationControls(CampaignsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: viewModel.currentPage > 1 ? () => viewModel.goToPage(1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: viewModel.currentPage > 1 ? () => viewModel.goToPage(viewModel.currentPage - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${viewModel.currentPage} / ${viewModel.totalPages}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: viewModel.currentPage < viewModel.totalPages
                ? () => viewModel.goToPage(viewModel.currentPage + 1)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed:
                viewModel.currentPage < viewModel.totalPages ? () => viewModel.goToPage(viewModel.totalPages) : null,
          ),
        ],
      ),
    );
  }
}
