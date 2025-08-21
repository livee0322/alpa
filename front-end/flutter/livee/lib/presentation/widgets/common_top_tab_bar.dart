import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonTopTabBar extends StatelessWidget {
  const CommonTopTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 탭 데이터를 리스트로 관리
    final List<Map<String, String>> tabs = [
      {'label': '숏클립', 'path': '/clips'},
      {'label': '쇼핑라이브', 'path': '/live'},
      {'label': '뉴스', 'path': '/news'},
      {'label': '이벤트', 'path': '/event'},
      {'label': '서비스', 'path': '/service'},
    ];

    // 현재 경로 확인
    final String currentPath =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F3F5),
            width: 1.0,
          ),
        ),
      ),
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          // 리스트 데이터를 기반으로 탭 버튼 동적 생성
          children: tabs.map((tab) {
            final bool isActive = currentPath == tab['path'];
            return _buildTab(
              context: context,
              label: tab['label']!,
              path: tab['path']!,
              isActive: isActive,
            );
          }).toList(),
        ),
      ),
    );
  }

  // 개별 탭 버튼을 생성하는 위젯
  Widget _buildTab({
    required BuildContext context,
    required String label,
    required String path,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: () => GoRouter.of(context).go(path),
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Colors.transparent : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFF374151),
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            // 활성화된 탭 하단에 밑줄 표시
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 3,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(3),
                ),
              )
          ],
        ),
      ),
    );
  }
}
