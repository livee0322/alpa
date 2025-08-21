import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          // 다른 화면과 UI 통일성을 위해 공통 위젯 추가
          CommonTopTabBar(),
          Expanded(
            child: Center(
              child: Text(
                '서비스 화면 (구현 예정)',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavBar(),
    );
  }
}
