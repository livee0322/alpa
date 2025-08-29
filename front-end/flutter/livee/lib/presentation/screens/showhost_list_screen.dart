import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/showhost_list_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

// 브랜드가 쇼호스트 목록을 보고 필터링할 수 있는 화면
class ShowhostListScreen extends StatefulWidget {
  const ShowhostListScreen({super.key});

  @override
  State<ShowhostListScreen> createState() => _ShowhostListScreenState();
}

class _ShowhostListScreenState extends State<ShowhostListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드될 때 데이터를 불러옵니다.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => Provider.of<ShowhostListProvider>(context, listen: false).fetchShowhosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쇼호스트 리스트'),
      ),
      body: Consumer<ShowhostListProvider>(
        builder: (context, provider, child) => Column(
          children: [
            // 필터 UI
            _buildFilterSection(provider),
            // 쇼호스트 목록
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.filteredShowhosts.isEmpty
                      ? const Center(child: Text('등록된 쇼호스트가 없습니다.'))
                      : _buildShowhostList(provider),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  // 필터링 UI를 구성하는 위젯
  Widget _buildFilterSection(ShowhostListProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('전체')),
                DropdownMenuItem(value: '뷰티', child: Text('뷰티')),
                DropdownMenuItem(value: '음식', child: Text('음식')),
              ],
              onChanged: (value) => provider.applyFilter(category: value),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '출연료',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('전체')),
                DropdownMenuItem(value: '10', child: Text('~10만원')),
                DropdownMenuItem(value: '30', child: Text('10~30만원')),
              ],
              onChanged: (value) {
                // TODO: 필터 로직 구현
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 쇼호스트 목록 UI
  Widget _buildShowhostList(ShowhostListProvider provider) {
    return ListView.builder(
      itemCount: provider.filteredShowhosts.length,
      itemBuilder: (context, index) {
        final host = provider.filteredShowhosts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: host.profileImage != null ? NetworkImage(host.profileImage!) : null,
              child: host.profileImage == null ? const Icon(Icons.person) : null,
            ),
            title: Text(host.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('경력: ${host.experienceYears ?? '-'}년 | 지역: ${host.region ?? '-'}'),
            onTap: () => GoRouter.of(context).go('/showhosts/${host.id}'),
          ),
        );
      },
    );
  }
}
