import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:livee/domain/models/news.dart';

class NewsListItem extends StatelessWidget {
  final News news;
  const NewsListItem({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy.MM.dd').format(news.createdAt);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => GoRouter.of(context).go('/news/${news.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(news.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(formattedDate, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              if (news.imageUrl != null) ...[
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    news.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
