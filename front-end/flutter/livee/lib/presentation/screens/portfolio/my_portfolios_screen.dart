import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/presentation/screens/portfolio/vm/my_portfolios_view_model.dart';
import 'package:livee/presentation/common/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

/// 자신의 포트폴리오 목록을 보여주는 화면
class MyPortfoliosScreen extends StatelessWidget {
  const MyPortfoliosScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => MyPortfoliosViewModel(),
        child: Consumer<MyPortfoliosViewModel>(
          builder: (context, viewModel, child) => LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F8FA),
              appBar: _buildAppBar(context),
              body: Column(
                children: [
                  _buildSectionHeader(),
                  Expanded(
                    child: _buildBody(context, viewModel),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  AppBar _buildAppBar(BuildContext context) => AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => html.window.history.go(-1),
        ),
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
      );

  Widget _buildSectionHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('내 포트폴리오', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ActionChip(
              avatar: const Icon(Icons.people_alt_outlined, size: 16),
              label: const Text('전체 보기'),
              onPressed: () {
                // TODO: 전체 공개 포트폴리오 목록 보기
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: Colors.grey.shade300),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            )
          ],
        ),
      );

  Widget _buildBody(BuildContext context, MyPortfoliosViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(child: Text('오류: ${viewModel.errorMessage}'));
    }
    if (viewModel.portfolios.isEmpty) {
      return const Center(child: Text('등록된 포트폴리오가 없습니다.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: viewModel.portfolios.length,
      itemBuilder: (context, index) {
        final portfolio = viewModel.portfolios[index];
        return _buildPortfolioCard(context, portfolio);
      },
    );
  }

  Widget _buildPortfolioCard(BuildContext context, Portfolio portfolio) {
    final viewModel = Provider.of<MyPortfoliosViewModel>(context, listen: false);

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
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[200],
                child: portfolio.backgroundImageUrl != null
                    ? Image.network(portfolio.backgroundImageUrl!, fit: BoxFit.cover)
                    : null,
              ),
              Positioned(
                left: 10,
                top: 90,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage:
                        portfolio.mainThumbnailUrl != null ? NetworkImage(portfolio.mainThumbnailUrl!) : null,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portfolio.nickname ?? '무명',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Text(
                  portfolio.oneLineIntro ?? '소개글이 없습니다.',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      icon: Icons.open_in_new,
                      label: '보기',
                      onPressed: () => GoRouter.of(context).go('/portfolios/${portfolio.id}'),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                        icon: Icons.edit,
                        label: '수정',
                        onPressed: () {
                          GoRouter.of(context).go('/portfolio-edit', extra: portfolio.id);
                        }),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: '삭제',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('삭제 확인'),
                            content: const Text('정말로 이 포트폴리오를 삭제하시겠습니까?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
                              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('삭제')),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final success = await viewModel.deletePortfolio(portfolio.id);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제에 실패했습니다.')));
                          }
                        }
                      },
                      color: Colors.red.shade400,
                    ),
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
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? const Color(0xFF4B5563),
        side: BorderSide(color: color ?? Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
