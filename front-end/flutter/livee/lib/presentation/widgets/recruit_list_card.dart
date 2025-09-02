import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';

// '공고 모아보기' 화면에서 사용될 개별 공고 카드 위젯
class RecruitListCard extends StatelessWidget {
  final Campaign campaign;

  const RecruitListCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    // campaign 객체에서 직접 날짜 정보를 가져오기
    final when = campaign.liveTime != null ? DateTime.tryParse(campaign.liveTime!) : null;
    final dateString = when != null ? '${when.year}.${when.month}.${when.day}' : '';

    return InkWell(
      onTap: () => GoRouter.of(context).push('/campaign/${campaign.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        shadowColor: Colors.black12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 이미지
            _buildThumbnail(),
            // 카드 본문
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 공고 제목
                  Text(
                    campaign.title ?? '제목 없음',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // 메타 정보 (날짜, 브랜드, 출연료)
                  _buildMetaInfo(dateString),
                  const SizedBox(height: 10),
                  // 카테고리 뱃지
                  if (campaign.category != null && campaign.category!.isNotEmpty)
                    _buildCategoryBadge(campaign.category!),
                  const SizedBox(height: 8),
                  // 상세 설명
                  Text(
                    campaign.descriptionHTML?.replaceAll('\n', ' ').trim() ?? '설명 없음',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 썸네일 이미지 위젯
  Widget _buildThumbnail() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        campaign.coverImageUrl ?? 'https://picsum.photos/seed/${campaign.id}/640/360',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
      ),
    );
  }

  /// 메타 정보 (날짜, 브랜드 등) 위젯
  Widget _buildMetaInfo(String dateString) {
    // [추가] fee를 "30만원" 형태의 문자열로 변환합니다.
    String feeText = '협의';
    if (campaign.fee != null && campaign.fee! > 0) {
      feeText = '${(campaign.fee! / 10000).round()}만원';
    } else if (campaign.feeNegotiable == true) {
      feeText = '협의';
    }

    return Text(
      [
        if (dateString.isNotEmpty) '📅 $dateString',
        '🏷️ ${campaign.brand ?? '브랜드 미정'}',
        '💸 $feeText' // [수정] 변환된 feeText를 사용합니다.
      ].join('  |  '),
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[600],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 카테고리 뱃지 위젯
  Widget _buildCategoryBadge(String category) {
    return Chip(
      label: Text(category),
      labelStyle: const TextStyle(
        color: Color(0xFF6C63FF),
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
      backgroundColor: const Color(0xFFF6F7FF),
      side: const BorderSide(
        color: Color(0xFFE6EBFF),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
