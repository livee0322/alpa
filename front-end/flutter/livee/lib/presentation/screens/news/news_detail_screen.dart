import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livee/presentation/screens/news/vm/news_detail_view_model.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class NewsDetailScreen extends StatelessWidget {
  final String newsId;
  const NewsDetailScreen({super.key, required this.newsId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsDetailViewModel(newsId: newsId),
      child: Consumer<NewsDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: _buildBody(viewModel),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(NewsDetailViewModel viewModel) {
    if (viewModel.news == null) {
      return viewModel.errorMessage != null ? Center(child: Text(viewModel.errorMessage!)) : const SizedBox.shrink();
    }

    final news = viewModel.news!;
    final formattedDate = DateFormat('yyyy.MM.dd').format(news.createdAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(news.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('등록일: $formattedDate', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          if (news.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(news.imageUrl!, width: double.infinity, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),
          Text(news.content, style: const TextStyle(fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }
}
