// lib/presentation/screens/campaign_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:provider/provider.dart';
import 'campaign_detail/widgets/detail_meta_card.dart';
import 'campaign_detail/widgets/detail_product_card.dart';
import 'campaign_detail/widgets/detail_sticky_bottom_bar.dart';

class CampaignDetailScreen extends StatefulWidget {
  final String campaignId;

  const CampaignDetailScreen({
    super.key,
    required this.campaignId,
  });

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  late Future<Campaign> _campaignFuture;

  @override
  void initState() {
    super.initState();
    _campaignFuture = Provider.of<CampaignUseCase>(context, listen: false)
        .getCampaignById(widget.campaignId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캠페인 상세'),
      ),
      body: FutureBuilder<Campaign>(
        future: _campaignFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('캠페인 정보를 찾을 수 없습니다.'));
          }

          final campaign = snapshot.data!;
          // Scaffold를 반환하여 bottomNavigationBar를 동적으로 설정
          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 썸네일
                  _buildThumbnail(campaign),
                  const SizedBox(height: 16),
                  // 브랜드 / 제목
                  _buildTitleSection(campaign),
                  const SizedBox(height: 16),
                  // 메타 정보 (타입에 따라 분기)
                  if (campaign.type == 'recruit')
                    _buildRecruitMetaGrid(campaign)
                  else if (campaign.type == 'product')
                    _buildProductMetaGrid(campaign),
                  const SizedBox(height: 24),
                  // 상품 목록 (상품 캠페인일 경우)
                  if (campaign.type == 'product') _buildProductList(campaign),
                  // 상세 설명
                  _buildDescription(campaign),
                ],
              ),
            ),
            // 하단 고정 버튼 바
            bottomNavigationBar: _buildBottomBar(campaign),
          );
        },
      ),
    );
  }

  // UI 구성 요소
  Widget _buildThumbnail(Campaign campaign) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        campaign.coverImageUrl ??
            'https://picsum.photos/seed/${campaign.id}/1280/720',
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
          campaign.brand ?? '브랜드 미정',
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
    final recruit = campaign.recruit;
    final metaItems = [
      {
        'icon': Icons.calendar_today,
        'label': '촬영일',
        'value': recruit?.date?.substring(0, 10) ?? '미정'
      },
      {
        'icon': Icons.schedule,
        'label': '시간',
        'value': '${recruit?.timeStart ?? ''} ~ ${recruit?.timeEnd ?? ''}'
      },
      {
        'icon': Icons.location_on_outlined,
        'label': '장소',
        'value': recruit?.location ?? '미정'
      },
      {'icon': Icons.payment, 'label': '출연료', 'value': recruit?.pay ?? '협의'},
      // TODO: 마감일, 카테고리 추가
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

  // '상품 캠페인' 메타 정보를 GridView로 표시
  Widget _buildProductMetaGrid(Campaign campaign) {
    final price = campaign.products?.firstOrNull?.salePrice?.toString() ??
        campaign.products?.firstOrNull?.price?.toString() ??
        '미정';
    final metaItems = [
      {
        'icon': Icons.calendar_today,
        'label': '라이브 날짜',
        'value': campaign.live?.date ?? '미정'
      },
      {
        'icon': Icons.schedule,
        'label': '라이브 시간',
        'value': campaign.live?.time ?? '미정'
      },
      {'icon': Icons.sell_outlined, 'label': '판매가', 'value': '$price원'},
      {
        'icon': Icons.category_outlined,
        'label': '카테고리',
        'value': campaign.category ?? '미정'
      },
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

  // 상품 목록을 ListView로 표시
  Widget _buildProductList(Campaign campaign) {
    final products = campaign.products;
    if (products == null || products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '구성 상품',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) =>
              DetailProductCard(product: products[index]),
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
        // TODO: HTML 렌더링 패키지(flutter_html) 적용 필요
        Text(campaign.descriptionHTML ?? '상세 설명이 없습니다.'),
      ],
    );
  }

  /// 하단 고정 바를 빌드
  Widget _buildBottomBar(Campaign campaign) {
    String priceLabel = '';
    if (campaign.type == 'recruit') {
      priceLabel = '출연료 ${campaign.recruit?.pay ?? '협의'}';
    } else if (campaign.type == 'product') {
      final price = campaign.products?.firstOrNull?.salePrice?.toString() ??
          campaign.products?.firstOrNull?.price?.toString();
      if (price != null) {
        priceLabel = '판매가 ${price}원';
      }
    }

    return DetailStickyBottomBar(
      priceLabel: priceLabel,
      buttonLabel: '지원자 현황',
      onButtonPressed: () {
        // TODO: 지원자 현황 페이지로 이동
      },
    );
  }
}

// Dart 2.19 이상에서 List.firstOrNull 사용 가능, 하위 버전이면 확장(extension) 추가 필요
extension FirstOrNullExtension<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
