import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/service_locator.dart';
import 'widgets/detail_meta_card.dart';
import 'widgets/detail_product_card.dart';
import 'widgets/detail_sticky_bottom_bar.dart';
import 'package:universal_html/html.dart' as html;

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
  // 로딩 상태와 데이터를 직접 관리
  bool _isLoading = true;
  Campaign? _campaign;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCampaign();
  }

  // 데이터를 불러오고 상태를 관리하는 메소드
  Future<void> _loadCampaign() async {
    setState(() => _isLoading = true);
    try {
      final campaign = await locator<CampaignUseCase>().getCampaignById(widget.campaignId);
      setState(() => _campaign = campaign);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => html.window.history.go(-1),
          ),
          backgroundColor: Color(0xFFF6F7F9),
          title: const Text('공고 상세'),
        ),
        body: _buildBody(),
      ),
    );
  }

  // 화면 본문을 빌드하는 헬퍼 메소드
  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(child: Text('에러: $_errorMessage'));
    }
    if (_campaign == null) {
      return const Center(child: Text('공고 정보를 찾을 수 없습니다.'));
    }

    final campaign = _campaign!;
    return Scaffold(
      backgroundColor: Color(0xFFF6F7F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(campaign),
            const SizedBox(height: 16),
            _buildTitleSection(campaign),
            const SizedBox(height: 16),
            if (campaign.type == 'recruit')
              _buildRecruitMetaGrid(campaign)
            else if (campaign.type == 'product')
              _buildProductMetaGrid(campaign),
            const SizedBox(height: 24),
            if (campaign.type == 'product') _buildProductList(campaign),
            _buildDescription(campaign),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(campaign),
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
    // recruit 객체에서 location 정보만 가져옴
    final recruit = campaign.recruit;

    // fee를 "30만원" 형태의 문자열로 변환
    String feeText = '협의';
    if (campaign.fee != null && campaign.fee! > 0) {
      feeText = '${(campaign.fee! / 10000).round()}만원';
    } else if (campaign.feeNegotiable == true) {
      feeText = '협의';
    }

    final metaItems = [
      // liveTime을 촬영일로 사용
      {'icon': Icons.calendar_today, 'label': '촬영일', 'value': campaign.liveTime?.substring(0, 10) ?? '미정'},
      // liveTime을 시간으로 사용 (종료 시간이 없으므로 시작 시간만 표시)
      {'icon': Icons.schedule, 'label': '시간', 'value': campaign.liveTime ?? '미정'},
      {'icon': Icons.location_on_outlined, 'label': '장소', 'value': recruit?.location ?? '미정'},
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

  // '상품 캠페인' 메타 정보를 GridView로 표시
  Widget _buildProductMetaGrid(Campaign campaign) {
    final price = campaign.products?.firstOrNull?.salePrice?.toString() ??
        campaign.products?.firstOrNull?.price?.toString() ??
        '미정';
    // [수정] campaign.live 객체 대신 campaign.liveTime 필드를 직접 사용
    final metaItems = [
      {'icon': Icons.calendar_today, 'label': '라이브 날짜', 'value': campaign.liveTime?.substring(0, 10) ?? '미정'},
      {'icon': Icons.schedule, 'label': '라이브 시간', 'value': campaign.liveTime ?? '미정'},
      {'icon': Icons.sell_outlined, 'label': '판매가', 'value': '$price원'},
      {'icon': Icons.category_outlined, 'label': '카테고리', 'value': campaign.category ?? '미정'},
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
          itemBuilder: (context, index) => DetailProductCard(product: products[index]),
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
      // fee를 "30만원" 형태의 문자열로 변환
      if (campaign.fee != null && campaign.fee! > 0) {
        priceLabel = '출연료 ${(campaign.fee! / 10000).round()}만원';
      } else {
        priceLabel = '출연료 협의';
      }
    } else if (campaign.type == 'product') {
      final price =
          campaign.products?.firstOrNull?.salePrice?.toString() ?? campaign.products?.firstOrNull?.price?.toString();
      if (price != null) {
        priceLabel = '판매가 ${price}원';
      }
    }

    return DetailStickyBottomBar(
      priceLabel: priceLabel,
      buttonLabel: '지원자 현황',
      onButtonPressed: () => GoRouter.of(context).go('/campaign/${campaign.id}/applicants'),
    );
  }
}

// Dart 2.19 이상에서 List.firstOrNull 사용 가능, 하위 버전이면 확장(extension) 추가 필요
extension FirstOrNullExtension<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
