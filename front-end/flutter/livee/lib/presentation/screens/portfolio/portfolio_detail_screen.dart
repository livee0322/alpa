import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/presentation/screens/portfolio/vm/portfolio_detail_view_model.dart';
import 'package:livee/presentation/common/loading_overlay.dart';
import 'package:livee/presentation/common/standard_content_card.dart';
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
        builder: (context, viewModel, child) => Scaffold(
          body: LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: _buildBody(context, viewModel),
          ),
        ),
      ),
    );
  }

  /// 화면 본문을 구성하는 위젯
  Widget _buildBody(BuildContext context, PortfolioDetailViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }
    if (viewModel.item == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final portfolio = viewModel.item!;
    // CustomScrollView를 사용하여 스크롤 가능한 UI를 구성
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(context, portfolio),
        ),
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
                _buildRecentLivesCard(portfolio),
                const SizedBox(height: 16),
                _buildGalleryCard(portfolio),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// [추가] 새로운 디자인의 헤더 UI를 구성하는 위젯
  Widget _buildHeader(BuildContext context, Portfolio portfolio) {
    return Stack(
      children: [
        // --- 1. 배경 이미지 ---
        Container(
          height: 400, // 헤더의 높이를 지정
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                portfolio.backgroundImageUrl ?? 'https://picsum.photos/seed/${portfolio.id}/800/600',
              ),
              fit: BoxFit.cover,
            ),
          ),
          // 텍스트가 잘 보이도록 그라데이션 오버레이를 추가
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
        ),

        // --- 2. 상단 버튼 (뒤로가기, 공유, 북마크) ---
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            // 상태 표시줄을 침범하지 않도록 SafeArea 적용
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 뒤로가기 버튼
                  IconButton(
                    icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white, size: 28),
                    onPressed: () => html.window.history.go(-1),
                  ),
                  // 공유 & 북마크 버튼
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.share, color: Colors.white, size: 24),
                        onPressed: () {/* 기능 구현 X */},
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.bookmark, color: Colors.white, size: 24),
                        onPressed: () {/* 기능 구현 X */},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- 3. 프로필 정보 (썸네일, 이름, 소개, 나이) ---
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 메인 썸네일 (원형)
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      portfolio.mainThumbnailUrl != null ? NetworkImage(portfolio.mainThumbnailUrl!) : null,
                ),
              ),
              const SizedBox(width: 16),
              // 이름, 한 줄 소개, 나이
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      portfolio.nickname ?? '이름 없음',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      portfolio.oneLineIntro ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    if (portfolio.age != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '만 ${portfolio.age}세',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
  ///
  /// subThumbnailUrls에 있는 이미지들을 3열 그리드 형태로 표시합니다.
  Widget _buildGalleryCard(Portfolio portfolio) {
    final images = portfolio.subThumbnailUrls ?? [];
    // 이미지가 없으면 갤러리 섹션 자체를 표시하지 않습니다.
    if (images.isEmpty) return const SizedBox.shrink();

    // 공통 카드 위젯을 사용하여 일관된 디자인을 유지합니다.
    return StandardContentCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('갤러리', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // GridView.builder를 사용하여 그리드 레이아웃을 효율적으로 구성합니다.
          GridView.builder(
            shrinkWrap: true, // 스크롤뷰 내에서 사용하기 위해 설정
            physics: const NeverScrollableScrollPhysics(), // 부모 스크롤과 충돌 방지
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // [핵심] 한 줄에 3개의 이미지를 표시하여 3xN 그리드를 만듭니다.
              crossAxisSpacing: 8, // 이미지 좌우 간격
              mainAxisSpacing: 8, // 이미지 상하 간격
            ),
            itemBuilder: (context, index) {
              // 각 이미지를 둥근 모서리로 표시합니다.
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
