import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_banner.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          CommonHeader(),
          CommonBanner(),
          CommonTopTabBar(),
          Expanded(
            child: Center(
              child: Text('메인 페이지'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavBar(),
    );
  }
}
