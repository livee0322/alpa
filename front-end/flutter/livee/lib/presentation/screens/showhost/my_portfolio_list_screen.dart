import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/service_locator.dart';

class MyPortfolioListScreen extends StatefulWidget {
  const MyPortfolioListScreen({super.key});

  @override
  State<MyPortfolioListScreen> createState() => _MyPortfolioListScreenState();
}

class _MyPortfolioListScreenState extends State<MyPortfolioListScreen> {
  late Future<List<Portfolio>> _portfoliosFuture;

  @override
  void initState() {
    super.initState();
    _loadPortfolios();
  }

  void _loadPortfolios() {
    setState(() {
      _portfoliosFuture = locator<PortfolioRepository>().getMyPortfolioList();
    });
  }

  Future<void> _deletePortfolio(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말로 이 포트폴리오를 삭제하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await locator<PortfolioRepository>().deletePortfolio(id);
        _loadPortfolios();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: const Text('내 포트폴리오'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('등록'),
              onPressed: () => GoRouter.of(context).go('/portfolio-edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // [추가] 섹션 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('내 포트폴리오',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ActionChip(
                  avatar: const Icon(Icons.people_alt_outlined, size: 16),
                  label: const Text('전체 보기'),
                  onPressed: () {
                    // TODO: 전체 공개 포트폴리오 목록 보기
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(color: Colors.grey.shade300),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Portfolio>>(
              future: _portfoliosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('오류: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('등록된 포트폴리오가 없습니다.'));
                }

                final portfolios = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: portfolios.length,
                  itemBuilder: (context, index) {
                    final portfolio = portfolios[index];
                    return _buildPortfolioCard(portfolio);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // [수정] 카드 UI를 디자인 시안에 맞춰 전면 개편
  Widget _buildPortfolioCard(Portfolio portfolio) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 배경 이미지
              Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey[200],
                child: portfolio.backgroundImageUrl != null
                    ? Image.network(portfolio.backgroundImageUrl!,
                        fit: BoxFit.cover)
                    : null,
              ),
              // 프로필 이미지 (배경 위에 걸쳐짐)
              Positioned(
                top: 80,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 37,
                    backgroundImage: portfolio.mainThumbnailUrl != null
                        ? NetworkImage(portfolio.mainThumbnailUrl!)
                        : null,
                    child: portfolio.mainThumbnailUrl == null
                        ? const Icon(Icons.person, size: 30, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Column(
              children: [
                Text(
                  portfolio.nickname ?? '무명',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                        icon: Icons.open_in_new, label: '보기', onPressed: () {}),
                    const SizedBox(width: 8),
                    _buildActionButton(
                        icon: Icons.edit,
                        label: '수정',
                        onPressed: () {
                          GoRouter.of(context)
                              .go('/portfolio-edit', extra: portfolio.id);
                        }),
                    const SizedBox(width: 8),
                    _buildActionButton(
                        icon: Icons.delete,
                        label: '삭제',
                        onPressed: () => _deletePortfolio(portfolio.id),
                        color: Colors.red.shade400),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? const Color(0xFF4B5563),
        side: BorderSide(color: color ?? Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
