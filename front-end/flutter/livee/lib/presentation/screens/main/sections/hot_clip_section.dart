import 'package:flutter/material.dart';

/// 메인 화면의 'HOT clip' 섹션을 표시하는 위젯
class HotClipSection extends StatelessWidget {
  const HotClipSection({super.key});

  @override
  Widget build(BuildContext context) {
    // API 연동 전 사용할 임시 데이터
    final List<Map<String, String>> hotClips = [
      {
        'thumbnailUrl': 'https://picsum.photos/seed/clip1/300/400',
        'title': '절대 쏟아지지 않는 그릇이라길래 샀는데...',
      },
      {
        'thumbnailUrl': 'https://picsum.photos/seed/clip2/300/400',
        'title': '라면 논쟁 일으키는 배수민',
      },
      {
        'thumbnailUrl': 'https://picsum.photos/seed/clip3/300/400',
        'title': '이걸 참아? 상상초월 먹방 ASMR',
      },
    ];

    return Column(
      children: [
        // 1. 섹션 헤더 (제목 + 더보기 버튼)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text.rich(
              TextSpan(
                text: 'HOT ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.red,
                ),
                children: [
                  TextSpan(
                    text: 'clip',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                // TODO: 숏클립 전체 페이지로 이동
              },
              child: const Text(
                '더보기',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 2. 가로 스크롤 클립 목록
        SizedBox(
          height: 200, // 목록의 높이를 지정
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hotClips.length,
            padding: EdgeInsets.zero, // ListView 자체의 좌우 여백 제거
            itemBuilder: (context, index) {
              final clip = hotClips[index];
              return _buildClipCard(clip);
            },
            // 아이템 사이의 간격
            separatorBuilder: (context, index) => const SizedBox(width: 12),
          ),
        ),
      ],
    );
  }

  /// 개별 클립 카드를 구성하는 위젯
  Widget _buildClipCard(Map<String, String> clip) {
    return SizedBox(
      width: 150, // 각 카드의 너비를 지정
      child: Card(
        clipBehavior: Clip.antiAlias, // Card의 경계를 넘어가는 자식 위젯을 잘라냄
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          fit: StackFit.expand, // 자식 위젯이 Stack의 크기에 맞게 확장되도록 함
          children: [
            // 썸네일 이미지
            Image.network(
              clip['thumbnailUrl']!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
            ),

            // 어두운 Gradient 오버레이 (텍스트 가독성을 위해)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),

            // 재생 버튼 아이콘
            const Center(
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                radius: 24,
                child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
              ),
            ),

            // 클립 제목
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                clip['title']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
