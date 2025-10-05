import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livee/domain/models/model.dart';
import 'package:livee/presentation/screens/model/vm/model_detail_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/common/loading_overlay.dart';
import 'package:livee/presentation/common/standard_content_card.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class ModelDetailScreen extends StatelessWidget {
  final String modelId;

  const ModelDetailScreen({
    super.key,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModelDetailViewModel(modelId: modelId),
      child: Consumer<ModelDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: _buildBody(context, viewModel),
            ),
          );
        },
      ),
    );
  }

  /// 화면 본문을 구성하는 위젯
  Widget _buildBody(BuildContext context, ModelDetailViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }
    if (viewModel.model == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final model = viewModel.model!;
    // CustomScrollView를 사용하여 스크롤 가능한 복잡한 레이아웃을 구성합니다.
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, model),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLinkButtons(model),
                const SizedBox(height: 16),
                _buildIntroductionCard(model),
                const SizedBox(height: 16),
                _buildGalleryCard(model),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 화면 상단의 AppBar와 프로필 헤더를 구성하는 SliverAppBar
  SliverAppBar _buildSliverAppBar(BuildContext context, Model model) {
    return SliverAppBar(
      expandedHeight: 250.0, // 헤더의 최대 높이
      pinned: true, // 스크롤 시 AppBar가 상단에 고정됨
      elevation: 1,
      surfaceTintColor: AppColors.white,
      shadowColor: Colors.black12,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back),
        onPressed: () => html.window.history.go(-1),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.bookmark_border_outlined), onPressed: () {}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 배경 이미지
            Image.network(
              model.backgroundImageUrl ?? 'https://picsum.photos/seed/${model.id}/800/600',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3), // 이미지 어둡게 처리
              colorBlendMode: BlendMode.darken,
            ),
            // 프로필 정보
            Positioned(
              left: 16,
              bottom: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 34,
                      backgroundImage: model.mainThumbnailUrl != null ? NetworkImage(model.mainThumbnailUrl!) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.nickname ?? '이름 없음',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(model.oneLineIntro ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      if (model.age != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('만 ${model.age}세', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 소셜 링크 버튼들을 구성하는 위젯
  Widget _buildLinkButtons(Model model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('카드를 누르면 상세 프로필을 볼 수 있어요.'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            if (model.instagramUrl != null && model.instagramUrl!.isNotEmpty)
              _buildChipButton(icon: Icons.camera_alt_outlined, label: 'Instagram', onPressed: () {}),
            if (model.youtubeUrl != null && model.youtubeUrl!.isNotEmpty)
              _buildChipButton(icon: Icons.video_collection_outlined, label: 'YouTube', onPressed: () {}),
            if (model.websiteUrl != null && model.websiteUrl!.isNotEmpty)
              _buildChipButton(icon: Icons.link, label: 'Website', onPressed: () {}),
          ],
        )
      ],
    );
  }

  /// '소개' 섹션 카드
  Widget _buildIntroductionCard(Model model) {
    return StandardContentCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('소개', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(model.detailedIntro ?? '자유로운 소개 형식입니다.'),
        ],
      ),
    );
  }

  /// '갤러리' 섹션 카드
  Widget _buildGalleryCard(Model model) {
    final images = model.subThumbnailUrls ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    return StandardContentCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('갤러리', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(images[index], fit: BoxFit.cover),
              );
            },
          )
        ],
      ),
    );
  }

  /// 소셜 링크에 사용되는 칩(Chip) 형태의 버튼
  Widget _buildChipButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
