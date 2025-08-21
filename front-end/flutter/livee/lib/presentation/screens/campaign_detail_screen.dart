import 'package:flutter/material.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:provider/provider.dart';

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
    _campaignFuture = Provider.of<CampaignUseCase>(context, listen: false).getCampaignById(widget.campaignId);
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
          } else if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('캠페인 정보를 찾을 수 없습니다.'));
          } else {
            final campaign = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 썸네일
                  if (campaign.coverImageUrl != null)
                    Image.network(
                      campaign.coverImageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 16),
                  // 브랜드 / 제목
                  Text(
                    campaign.brand ?? '브랜드 미정',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 16),
                  // 메타 정보
                  if (campaign.type == 'recruit')
                    _buildRecruitMeta(campaign)
                  else if (campaign.type == 'product')
                    _buildProductMeta(campaign),
                  const SizedBox(height: 16),
                  // 상세 설명
                  const Text(
                    '상세 설명',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(campaign.descriptionHTML ?? '상세 설명이 없습니다.'),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildRecruitMeta(Campaign campaign) {
    final recruit = campaign.recruit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetaItem('촬영일', recruit?.date ?? '미정'),
        _buildMetaItem('촬영시간', '${recruit?.timeStart ?? ''} ~ ${recruit?.timeEnd ?? ''}'),
        _buildMetaItem('장소', recruit?.location ?? '미정'),
        _buildMetaItem('출연료', recruit?.pay ?? '미정'),
        _buildMetaItem('카테고리', recruit?.category ?? '미정'),
      ],
    );
  }

  Widget _buildProductMeta(Campaign campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetaItem('라이브 날짜', campaign.live?.date ?? '미정'),
        _buildMetaItem('라이브 시간', campaign.live?.time ?? '미정'),
        _buildMetaItem('판매가', campaign.products?.first.salePrice?.toString() ?? '미정'),
        const Text('상품 목록'),
        if (campaign.products != null) ...campaign.products!.map((p) => Text('- ${p.title ?? '제목 없음'}')).toList(),
      ],
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
