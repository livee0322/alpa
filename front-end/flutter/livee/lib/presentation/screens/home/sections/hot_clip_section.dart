import 'package:flutter/material.dart';
import 'package:livee/domain/models/clip.dart' as model;
import 'package:livee/presentation/screens/clips/widgets/clip_player_modal.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';

/// 메인 화면의 'HOT clip' 섹션을 표시하는 위젯
class HotClipSection extends StatelessWidget {
  final List<model.Clip> clips;
  const HotClipSection({
    super.key,
    required this.clips,
  });

  @override
  Widget build(BuildContext context) {
    // 전달받은 클립 데이터가 비어있을 경우 안내 문구를 표시
    if (clips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: Text('등록된 숏클립이 없습니다.'),
        ),
      );
    }
    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // itemCount를 전달받은 clips 리스트의 길이로 설정
        itemCount: clips.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final clip = clips[index];
          // _buildClipCard에 실제 Clip 객체를 전달
          return _buildClipCard(context, clip);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }

  /// 개별 클립 카드를 구성하는 위젯
  Widget _buildClipCard(BuildContext context, model.Clip clip) {
    return StandardContentCard(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      // [수정] 카드를 탭하면 ClipPlayerModal을 띄우도록 수정합니다.
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ClipPlayerModal(clip: clip),
        );
      },
      child: SizedBox(
        width: 180,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 썸네일 이미지
              Image.network(
                // [수정] 실제 데이터의 thumbnailUrl을 사용하고, 없을 경우 picsum 포토를 사용합니다.
                clip.thumbnailUrl ??
                    'https://picsum.photos/seed/${clip.id}/300/400',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.error),
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
                  // [수정] 실제 데이터의 title을 사용합니다.
                  clip.title ?? '(제목 없음)',
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
