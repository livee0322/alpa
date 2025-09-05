// lib/presentation/screens/showhost/my_portfolio_list_screen.dart

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

  // 목록을 불러오는 함수
  void _loadPortfolios() {
    setState(() {
      _portfoliosFuture = locator<PortfolioRepository>().getMyPortfolioList();
    });
  }

  // 삭제 로직
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
        _loadPortfolios(); // 삭제 후 목록 새로고침
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
        title: const Text('내 포트폴리오'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
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
      body: FutureBuilder<List<Portfolio>>(
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
            padding: const EdgeInsets.all(16.0),
            itemCount: portfolios.length,
            itemBuilder: (context, index) {
              final portfolio = portfolios[index];
              return _buildPortfolioCard(portfolio);
            },
          );
        },
      ),
    );
  }

  Widget _buildPortfolioCard(Portfolio portfolio) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: portfolio.profileImage != null
                      ? NetworkImage(portfolio.profileImage!)
                      : null,
                  child: portfolio.profileImage == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    portfolio.name ?? '무명',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                    icon: Icons.open_in_new, label: '보기', onPressed: () {}),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.edit,
                  label: '수정',
                  onPressed: () => GoRouter.of(context)
                      .go('/portfolio-edit', extra: portfolio.id),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                    icon: Icons.delete,
                    label: '삭제',
                    onPressed: () => _deletePortfolio(portfolio.id),
                    color: Colors.red),
              ],
            )
          ],
        ),
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
        foregroundColor: color,
        side: BorderSide(color: color ?? Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
