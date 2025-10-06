import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/campaign/vm/campaign_detail_view_model.dart';
import 'package:livee/presentation/common/loading_overlay.dart';
import 'package:livee/presentation/common/standard_content_card.dart';
import 'package:provider/provider.dart';
import 'widgets/detail_meta_card.dart';
import 'widgets/detail_sticky_bottom_bar.dart';

class CampaignDetailScreen extends StatelessWidget {
  final String campaignId;

  const CampaignDetailScreen({
    super.key,
    required this.campaignId,
  });

  /// 화면의 전체적인 UI 구조를 구성하고 ViewModel과 연결
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => CampaignDetailViewModel(context, campaignId: campaignId),
        child: Consumer<CampaignDetailViewModel>(
          builder: (context, viewModel, child) => LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: Scaffold(
              body: _buildBody(context, viewModel),
            ),
          ),
        ),
      );

  /// ViewModel의 상태에 따라 화면의 본문을 구성
  Widget _buildBody(BuildContext context, CampaignDetailViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(child: Text('에러: ${viewModel.errorMessage}'));
    }
    if (viewModel.item == null) {
      return const Center(child: Text('공고 정보를 찾을 수 없습니다.'));
    }

    final campaign = viewModel.item!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildThumbnail(campaign),
            const SizedBox(height: 16),
            _buildTitleSection(campaign),
            const SizedBox(height: 16),
            _buildRecruitMetaGrid(campaign),
            const SizedBox(height: 24),
            if (campaign.productName != null && campaign.productName!.isNotEmpty) _buildProductSection(campaign),
            _buildDescription(campaign),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, campaign, authProvider, viewModel),
    );
  }

  // [추가] Column 방식에 맞는 새로운 헤더 위젯입니다.
  Widget _buildHeader() {
    return SafeArea(
      bottom: false, // SafeArea의 아래쪽 패딩은 필요 없으므로 제거
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 8.0),
        child: Text(
          '공고 상세',
          style: TextStyle(
            color: Colors.black, // [수정] 텍스트 색상을 검은색으로 변경
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // UI 구성 요소
  Widget _buildThumbnail(Campaign campaign) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        campaign.coverImageUrl ?? 'https://picsum.photos/seed/${campaign.id}/1280/720',
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildTitleSection(Campaign campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          campaign.brandName ?? '브랜드 미정',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          campaign.title ?? '제목 없음',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // '쇼호스트 모집' 메타 정보를 GridView로 표시
  Widget _buildRecruitMetaGrid(Campaign campaign) {
    String feeText = '협의';
    if (campaign.fee != null && campaign.fee! > 0) {
      feeText = '${(campaign.fee! / 10000).round()}만원';
    } else if (campaign.feeNegotiable == true) {
      feeText = '협의';
    }

    final metaItems = [
      {
        'icon': Icons.calendar_today,
        'label': '촬영일',
        'value': campaign.shootDate != null ? DateFormat('yyyy.MM.dd').format(campaign.shootDate!) : '미정'
      },
      {
        'icon': Icons.schedule,
        'label': '시간',
        'value': campaign.startTime != null ? '${campaign.startTime} ~ ${campaign.endTime}' : '미정'
      },
      {'icon': Icons.location_on_outlined, 'label': '장소', 'value': campaign.location ?? '미정'},
      {'icon': Icons.payment, 'label': '출연료', 'value': feeText},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metaItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3.0,
      ),
      itemBuilder: (context, index) {
        final item = metaItems[index];
        return DetailMetaCard(
          icon: item['icon'] as IconData,
          label: item['label'] as String,
          value: item['value'] as String,
        );
      },
    );
  }

  // 단일 상품 정보를 표시하는 새로운 섹션 위젯
  Widget _buildProductSection(Campaign campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '대표 상품',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        StandardContentCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            // [수정] crossAxisAlignment를 CrossAxisAlignment.start로 설정하여 위쪽으로 정렬합니다.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  campaign.productThumbnailUrl ?? 'https://picsum.photos/seed/${campaign.productName}/128/128',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  campaign.productName ?? '상품명 미정',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  // [수정] maxLines와 overflow 속성을 추가합니다.
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 상세 설명을 표시
  Widget _buildDescription(Campaign campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '상세 설명',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // [수정] descriptionHTML -> content로 필드명을 변경합니다.
        Text(campaign.content ?? '상세 설명이 없습니다.'),
      ],
    );
  }

  // 하단 고정 바를 빌드
  Widget _buildBottomBar(
      BuildContext context, Campaign campaign, AuthProvider authProvider, CampaignDetailViewModel viewModel) {
    // [수정] type과 products 필드 분기 로직을 제거하고, 출연료 정보만 표시하도록 단일화합니다.
    String priceLabel = '출연료 협의'; // 기본값
    if (campaign.fee != null && campaign.fee! > 0) {
      priceLabel = '출연료 ${(campaign.fee! / 10000).round()}만원';
    }

    bool isBrand = authProvider.role == 'brand';

    return DetailStickyBottomBar(
      priceLabel: priceLabel,
      buttonLabel: isBrand ? '지원자 현황' : '지원하기',
      onButtonPressed: () => isBrand ? context.go('/campaign/${campaign.id}/applicants') : viewModel.handleApply(),
    );
  }
}

// Dart 2.19 이상에서 List.firstOrNull 사용 가능, 하위 버전이면 확장(extension) 추가 필요
extension FirstOrNullExtension<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
