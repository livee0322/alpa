import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/presentation/screens/portfolio/vm/portfolio_detail_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class PortfolioDetailScreen extends StatelessWidget {
  final String portfolioId;

  const PortfolioDetailScreen({
    super.key,
    required this.portfolioId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortfolioDetailViewModel(portfolioId: portfolioId),
      child: Consumer<PortfolioDetailViewModel>(
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
  Widget _buildBody(BuildContext context, PortfolioDetailViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }
    if (viewModel.portfolio == null) {
      return const Center(child: Text('포트폴리오 정보를 찾을 수 없습니다.'));
    }

    final portfolio = viewModel.portfolio!;
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, portfolio),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLinkButtons(portfolio),
                const SizedBox(height: 16),
                _buildIntroductionCard(portfolio),
                const SizedBox(height: 16),
                _buildRecentLivesCard(portfolio), // 포트폴리오 고유 섹션
                const SizedBox(height: 16),
                _buildGalleryCard(portfolio),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 화면 상단의 AppBar와 프로필 헤더를 구성하는 SliverAppBar
  SliverAppBar _buildSliverAppBar(BuildContext context, Portfolio portfolio) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
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
            Image.network(
              portfolio.backgroundImageUrl ?? 'https://picsum.photos/seed/${portfolio.id}/800/600',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
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
                      backgroundImage:
                          portfolio.mainThumbnailUrl != null ? NetworkImage(portfolio.mainThumbnailUrl!) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(portfolio.nickname ?? '이름 없음',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(portfolio.oneLineIntro ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      if (portfolio.age != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('만 ${portfolio.age}세', style: const TextStyle(color: Colors.white, fontSize: 12)),
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
  Widget _buildLinkButtons(Portfolio portfolio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('카드를 누르면 상세 프로필을 볼 수 있어요.'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            if (portfolio.instagramUrl != null && portfolio.instagramUrl!.isNotEmpty)
              _buildChipButton(icon: Icons.camera_alt_outlined, label: 'Instagram', onPressed: () {}),
            if (portfolio.youtubeUrl != null && portfolio.youtubeUrl!.isNotEmpty)
              _buildChipButton(icon: Icons.video_collection_outlined, label: 'YouTube', onPressed: () {}),
            if (portfolio.websiteUrl != null && portfolio.websiteUrl!.isNotEmpty)
              _buildChipButton(icon: Icons.link, label: 'Website', onPressed: () {}),
          ],
        )
      ],
    );
  }

  /// '소개' 섹션 카드
  Widget _buildIntroductionCard(Portfolio portfolio) {
    return StandardContentCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('소개', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(portfolio.detailedIntro ?? '자유로운 소개 형식입니다.'),
        ],
      ),
    );
  }

  /// '최근 라이브 이력' 섹션 카드
  Widget _buildRecentLivesCard(Portfolio portfolio) {
    final lives = portfolio.recentLives ?? [];
    if (lives.isEmpty) return const SizedBox.shrink();

    return StandardContentCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('최근 라이브 이력', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...lives
              .map((live) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(live.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${live.date} / ${live.url}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  /// '갤러리' 섹션 카드
  Widget _buildGalleryCard(Portfolio portfolio) {
    final images = portfolio.subThumbnailUrls ?? [];
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
