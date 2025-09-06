import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/service_locator.dart';

class PortfolioDetailScreen extends StatefulWidget {
  final String portfolioId;

  const PortfolioDetailScreen({
    super.key,
    required this.portfolioId,
  });

  @override
  State<PortfolioDetailScreen> createState() => _PortfolioDetailScreenState();
}

class _PortfolioDetailScreenState extends State<PortfolioDetailScreen> {
  // 로딩 상태와 데이터를 직접 관리
  bool _isLoading = true;
  Portfolio? _portfolio;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  // 데이터를 불러오고 상태를 관리하는 메소드
  Future<void> _loadPortfolio() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final portfolio = await locator<PortfolioRepository>()
          .getPortfolioById(widget.portfolioId);
      setState(() {
        _portfolio = portfolio;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        // [수정] FutureBuilder를 제거하고 바로 UI를 렌더링
        body: _buildBody(),
      ),
    );
  }

  // 화면의 본문을 빌드하는 헬퍼 메소드
  Widget _buildBody() {
    // 로딩이 끝난 후 에러나 데이터 상태에 따라 다른 UI를 보여줌
    if (_errorMessage != null) {
      return Center(child: Text('오류: $_errorMessage'));
    }
    if (_portfolio == null) {
      // 로딩 중이 아닐 때 데이터가 없으면 빈 화면을 보여줌 (에러 케이스)
      return const Center(child: Text('포트폴리오 정보를 불러올 수 없습니다.'));
    }

    final portfolio = _portfolio!;
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, portfolio),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(portfolio),
                const SizedBox(height: 24),
                _buildInfoSection(portfolio),
                const SizedBox(height: 24),
                _buildSection(
                  title: '스킬',
                  child: _buildTags(portfolio.tags),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: '경력',
                  total: '${portfolio.experienceYears ?? '0'}년',
                  child: _buildRecentLives(portfolio.recentLives),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Portfolio portfolio) {
    return SliverAppBar(
      pinned: true,
      elevation: 1,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black12,
      actions: [
        TextButton(
          onPressed: () =>
              GoRouter.of(context).go('/portfolio-edit', extra: portfolio.id),
          child: const Text('수정'),
        ),
      ],
    );
  }

  Widget _buildHeader(Portfolio portfolio) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            image: portfolio.backgroundImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(portfolio.backgroundImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: portfolio.mainThumbnailUrl != null
                      ? NetworkImage(portfolio.mainThumbnailUrl!)
                      : null,
                  child: portfolio.mainThumbnailUrl == null
                      ? const Icon(Icons.person, size: 30, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(portfolio.nickname ?? '닉네임 없음',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(portfolio.oneLineIntro ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Portfolio portfolio) {
    return _buildSection(
      title: '인적사항',
      child: Column(
        children: [
          if (portfolio.age != null)
            ListTile(
                leading: const Icon(Icons.cake_outlined),
                title: Text('${portfolio.age}세')),
          if (portfolio.mainLink != null && portfolio.mainLink!.isNotEmpty)
            ListTile(
                leading: const Icon(Icons.link_outlined),
                title: Text(portfolio.mainLink!)),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, String? total, required Widget child}) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                if (total != null)
                  Text(total,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTags(List<String>? tags) {
    if (tags == null || tags.isEmpty) return const Text('등록된 스킬이 없습니다.');
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: tags.map((tag) => Chip(label: Text(tag))).toList(),
    );
  }

  Widget _buildRecentLives(List<RecentLive>? lives) {
    if (lives == null || lives.isEmpty) return const Text('등록된 경력이 없습니다.');
    return Column(
      children: lives
          .map((live) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(live.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${live.date}\n${live.url}'),
                  isThreeLine: true,
                ),
              ))
          .toList(),
    );
  }
}
