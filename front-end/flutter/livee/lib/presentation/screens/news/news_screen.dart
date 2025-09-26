import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/news/vm/news_list_view_model.dart';
import 'package:livee/presentation/screens/news/widgets/news_list_item.dart';
import 'package:livee/presentation/widgets/buttons/common_floating_action_button.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsListViewModel(),
      child: Consumer<NewsListViewModel>(
        builder: (context, viewModel, child) {
          final authProvider = context.watch<AuthProvider>();
          return Scaffold(
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: _buildNewsList(viewModel),
            ),
            // '쇼호스트' 역할일 때만 글쓰기 버튼 표시
            floatingActionButton: authProvider.role == 'showhost'
                ? CommonFloatingActionButton(
                    onPressed: () => GoRouter.of(context).go('/news/form'),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildNewsList(NewsListViewModel viewModel) {
    if (viewModel.newsList.isEmpty && !viewModel.isLoading) {
      return const Center(child: Text('등록된 뉴스가 없습니다.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.newsList.length + (viewModel.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.newsList.length) {
          // 마지막 아이템이면 '더 보기' 버튼 표시
          viewModel.fetchNextPage();
          return const Center(child: CircularProgressIndicator());
        }
        final news = viewModel.newsList[index];
        return NewsListItem(news: news);
      },
    );
  }
}
