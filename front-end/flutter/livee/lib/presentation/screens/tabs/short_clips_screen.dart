import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';

/// '숏클립' 목록을 보여주는 화면
class ShortClipsScreen extends StatelessWidget {
  const ShortClipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // API 연동 전 사용할 임시 데이터
    final List<Map<String, String>> shortClips = [
      {
        'thumbnailUrl': 'https://picsum.photos/seed/clip1/300/400',
        'title': '(제목 없음)',
        'source': 'youtube',
      },
      {
        'thumbnailUrl': 'https://picsum.photos/seed/clip2/300/400',
        'title': '(제목 없음)',
        'source': 'youtube',
      },
      {
        'thumbnailUrl': 'https://picsum.photos/seed/clip3/300/400',
        'title': '(제목 없음)',
        'source': '라스',
      },
      {
        'thumbnailUrl': 'https://picsum.photos/seed/clip4/300/400',
        'title': '(제목 없음)',
        'source': 'youtube',
      },
    ];

    return Scaffold(
      // 1. 화면의 전체적인 레이아웃 구성
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (숏클립 제목 + 총 개수)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '숏클립',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '총 ${shortClips.length}개',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            // 2열 그리드 뷰
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: shortClips.length,
                itemBuilder: (context, index) {
                  return _buildClipCard(shortClips[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 숏클립 추가 기능 구현
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 개별 클립 카드를 구성하는 위젯
  Widget _buildClipCard(Map<String, String> clip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 썸네일 부분
        Expanded(
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  clip['thumbnailUrl']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
                ),
                // 상단 소스 표시 (예: youtube)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          clip['source']!,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 썸네일 하단 제목
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
          child: Text(
            clip['title']!,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
