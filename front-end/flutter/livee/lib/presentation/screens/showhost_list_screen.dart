import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';

// 브랜드가 쇼호스트 목록을 보고 필터링할 수 있는 화면
class ShowhostListScreen extends StatelessWidget {
  const ShowhostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쇼호스트 리스트'),
      ),
      body: Column(
        children: [
          // 필터 UI
          _buildFilterSection(),
          // 쇼호스트 목록
          Expanded(
            child: Center(
              // TODO: API 연동 후 쇼호스트 목록 구현
              // 임시로 Tappable 리스트 아이템을 만듭니다.
              child: ListView(
                children: [
                  ListTile(
                    leading: const CircleAvatar(child: Text('A')),
                    title: const Text('쇼호스트 A'),
                    subtitle: const Text('경력 5년'),
                    onTap: () {
                      // --- [추가] 상세 페이지로 이동 ---
                      GoRouter.of(context).go('/showhosts/temp_id_1');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  /// 필터링 UI를 구성하는 위젯
  Widget _buildFilterSection() {
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
              onChanged: (value) {
                // TODO: 필터 로직 구현
              },
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
}
