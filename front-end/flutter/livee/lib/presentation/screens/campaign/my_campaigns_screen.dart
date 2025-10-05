import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/screens/campaign/vm/my_campaigns_view_model.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';

/// 내 공고 목록' 화면
class MyCampaignsScreen extends StatelessWidget {
  const MyCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyCampaignsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: Column(
              children: [
                // 헤더 UI
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '내 공고 목록',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => GoRouter.of(context).go('/campaign-form'),
                        icon: const Icon(Icons.add_circle_outline, size: 28),
                      ),
                    ],
                  ),
                ),
                // 본문 (공고 목록)
                Expanded(
                  child: _buildBody(context, viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 화면의 본문을 구성
  Widget _buildBody(BuildContext context, MyCampaignsViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(viewModel.errorMessage!),
      );
    }
    if (viewModel.campaigns.isEmpty) {
      return const Center(
        child: Text('등록된 공고가 없습니다.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: viewModel.campaigns.length,
      itemBuilder: (context, index) {
        final campaign = viewModel.campaigns[index];
        return _buildCampaignCard(context, campaign, viewModel);
      },
    );
  }

  // 개별 공고 카드를 구성
  Widget _buildCampaignCard(BuildContext context, Campaign campaign, MyCampaignsViewModel viewModel) {
    return StandardContentCard(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: EdgeInsets.zero,
      onTap: () => context.push('/campaign/${campaign.id}'),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // 썸네일 이미지
                campaign.coverImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          campaign.coverImageUrl!,
                          width: 120,
                          height: 68,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 120,
                        height: 68,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                const SizedBox(width: 12),
                // 캠페인 제목
                Expanded(
                  child: Text(
                    campaign.title ?? '제목 없음',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 수정 및 삭제 아이콘 버튼
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => GoRouter.of(context).go('/campaign-form', extra: campaign.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('삭제 확인'),
                            content: const Text('이 공고를 삭제하시겠어요?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // [수정] ViewModel의 deleteCampaign 메소드를 호출합니다.
                          final success = await viewModel.deleteCampaign(campaign.id!);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제에 실패했습니다.')));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // '지원자 현황 보기' 버튼
          const Divider(height: 1),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => GoRouter.of(context).go('/campaign/${campaign.id}/applicants'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
              ),
              child: const Text('지원자 현황 보기'),
            ),
          ),
        ],
      ),
    );
  }
}
