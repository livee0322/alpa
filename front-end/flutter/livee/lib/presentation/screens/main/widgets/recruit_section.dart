import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';

class RecruitSection extends StatelessWidget {
  // 부모 위젯(MainScreen)으로부터 Future 데이터를 전달받음
  final Future<List<Campaign>> recruitsFuture;

  const RecruitSection({
    super.key,
    required this.recruitsFuture,
  });

  @override
  Widget build(BuildContext context) {
    // FutureBuilder를 사용하여 비동기 데이터를 UI로 변환
    return FutureBuilder<List<Campaign>>(
      future: recruitsFuture,
      builder: (context, snapshot) {
        // 로딩, 에러, 데이터 없음 처리
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('모집 공고 로딩 실패'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('등록된 공고가 없습니다'));
        }

        // 데이터가 있을 때 리스트 뷰로 표시
        final items = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12), // 아이템 간 간격
          itemBuilder: (context, index) {
            final campaign = items[index];
            final recruit = campaign.recruit;
            final dDay = _calculateDday(recruit?.date);

            // 웹 버전의 .lv-job 스타일을 참고한 카드 위젯
            return InkWell(
              onTap: () => GoRouter.of(context).push('/campaign/${campaign.id}'),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign.brand ?? '브랜드 미정',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              campaign.title ?? '제목 없음',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (dDay.isNotEmpty) ...[
                                  // D-day 뱃지
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      dDay,
                                      style: const TextStyle(
                                          fontSize: 12, color: Color(0xFF4338CA), fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  _buildMetaSeparator(),
                                ],
                                // 출연료
                                Text(
                                  '출연료 ${recruit?.pay ?? '협의'}',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                                ),
                                // TODO: 지원자 수는 API 응답에 추가 필요
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 썸네일 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          campaign.coverImageUrl ?? 'https://picsum.photos/seed/recruit${campaign.id}/112/112',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(width: 56, height: 56, child: Icon(Icons.error)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 메타 정보 구분자 위젯
  Widget _buildMetaSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text('|', style: TextStyle(color: Color(0xFFD1D5DB))),
    );
  }

  /// D-day 계산 로직 (기존 main.js 참고)
  String _calculateDday(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final today = DateTime.now();
      final difference = date.difference(DateTime(today.year, today.month, today.day)).inDays;

      if (difference < 0) return '마감';
      if (difference == 0) return 'D-DAY';
      return 'D-$difference';
    } catch (e) {
      return '';
    }
  }
}
