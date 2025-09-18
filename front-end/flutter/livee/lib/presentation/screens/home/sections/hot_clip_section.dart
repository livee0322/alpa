import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';

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

    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hotClips.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final clip = hotClips[index];
          return _buildClipCard(clip);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }

  /// 개별 클립 카드를 구성하는 위젯
  Widget _buildClipCard(Map<String, String> clip) {
    return StandardContentCard(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      onTap: () {/* TODO: 클립 재생 페이지로 이동 */},
      child: SizedBox(
        width: 180,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 썸네일 이미지
              Image.network(
                clip['thumbnailUrl']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.error,
                  ),
                ),
              ),

              // 어두운 Gradient 오버레이
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
      ),
    );
  }
}
