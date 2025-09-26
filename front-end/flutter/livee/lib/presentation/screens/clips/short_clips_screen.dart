import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/clip.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/clips/vm/short_clips_view_model.dart';
import 'package:livee/presentation/screens/clips/widgets/add_clip_bottom_sheet.dart';
import 'package:livee/presentation/widgets/buttons/common_floating_action_button.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';

// '숏클립' 목록
class ShortClipsScreen extends StatelessWidget {
  const ShortClipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShortClipsViewModel(),
      child: Consumer<ShortClipsViewModel>(
        builder: (context, viewModel, child) {
          final authProvider = context.watch<AuthProvider>();
          return Scaffold(
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(viewModel.clips.length),
                    Expanded(
                      child: viewModel.clips.isEmpty && !viewModel.isLoading
                          ? const Center(child: Text('등록된 숏클립이 없습니다.'))
                          : _buildClipGrid(context, viewModel),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(context, authProvider, viewModel),
          );
        },
      ),
    );
  }

  // 화면 헤더
  Widget _buildHeader(int totalClips) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '숏클립',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '총 $totalClips개',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // [메소드] 숏클립 그리드 UI를 생성합니다.
  Widget _buildClipGrid(BuildContext context, ShortClipsViewModel viewModel) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: viewModel.clips.length,
      itemBuilder: (context, index) {
        final clip = viewModel.clips[index];
        return _buildClipCard(context, clip, viewModel);
      },
    );
  }

  // [메소드] 개별 숏클립 카드 UI를 생성합니다.
  Widget _buildClipCard(BuildContext context, Clip clip, ShortClipsViewModel viewModel) {
    // [리팩토링] Card 위젯을 StandardContentCard 공통 컴포넌트로 교체합니다.
    return StandardContentCard(
      padding: EdgeInsets.zero, // 이미지가 카드에 꽉 차도록 패딩을 제거합니다.
      margin: EdgeInsets.zero, // GridView가 간격을 관리하므로 마진을 제거합니다.
      onTap: () {
        // TODO: 숏클립 상세 보기 또는 재생 기능 구현
      },
      child: ClipRRect(
        // StandardContentCard의 둥근 모서리(14)에 맞춰 이미지를 잘라줍니다.
        borderRadius: BorderRadius.circular(14.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              clip.thumbnailUrl ?? 'https://picsum.photos/seed/${clip.id}/300/400',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
            ),
            // isMine이 true일 경우에만 삭제 아이콘을 표시합니다.
            if (clip.isMine == true)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.delete_forever,
                      color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                  onPressed: () async {
                    final confirm = await showCommonPromptDialog(
                        context: context, title: '삭제 확인', content: '정말로 이 숏클립을 삭제하시겠습니까?', confirmText: '삭제');
                    if (confirm == true) {
                      await viewModel.deleteClip(clip.id);
                    }
                  },
                ),
              ),
            // 카드 상단 소스 표시
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
                      clip.provider ?? 'video',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // 카드 하단 제목
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                clip.title ?? '(제목 없음)',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black87)]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 플로팅 액션 버튼 UI를 생성
  Widget _buildFloatingActionButton(BuildContext context, AuthProvider authProvider, ShortClipsViewModel viewModel) {
    return CommonFloatingActionButton(
      onPressed: () async {
        if (!authProvider.isLoggedIn) {
          final result = await showCommonPromptDialog(
              context: context,
              title: '로그인이 필요합니다',
              content: '숏클립을 등록하려면 로그인이 필요합니다.\n로그인 페이지로 이동하시겠습니까?',
              confirmText: '로그인');
          if (result == true) GoRouter.of(context).go('/login');
          return;
        }

        final result = await showAddClipBottomSheet(context);
        if (result == true) {
          viewModel.fetchClips();
        }
      },
    );
  }
}
