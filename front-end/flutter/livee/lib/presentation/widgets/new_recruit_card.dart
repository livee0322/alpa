import 'package:flutter/material.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:go_router/go_router.dart'; // [추가] GoRouter 임포트

/// 모집 공고 목록에서 사용될 카드 위젯
class NewRecruitCard extends StatelessWidget {
  /// 카드에 표시할 캠페인 데이터
  final Campaign campaign;

  const NewRecruitCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    // 출연료 텍스트를 계산 (예: 300000 -> "30만원")
    String feeText = '미정';
    if (campaign.fee != null && campaign.fee! > 0) {
      feeText = '${(campaign.fee! / 10000).round()}만원';
    } else if (campaign.feeNegotiable == true) {
      feeText = '협의';
    }

    // 마감일 포맷팅 (예: "2025-09-18T15:00:00.000Z" -> "2025-09-18")
    final deadline = campaign.closeAt?.substring(0, 10) ?? '미정';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => GoRouter.of(context).push('/campaign/${campaign.id}'),
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
                    color: Colors.grey[200],
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
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
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
                  // 공고 제목
                  Text(
                    campaign.title ?? '제목 없음',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // 브랜드명과 메타 정보
                  Text(
                    '${campaign.brand ?? '브랜드 미정'} · 출연료 $feeText · 마감 $deadline',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  // 바로 지원하기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('바로 지원하기'),
                      onPressed: () {
                        // TODO: 지원하기 기능 연결
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF007AFF), // 이미지와 유사한 파란색
                        foregroundColor: Colors.white,
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
      ),
    );
  }
}
