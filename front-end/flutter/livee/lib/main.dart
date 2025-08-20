import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_banner.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            CommonHeader(),
            CommonBanner(),
            CommonTopTabBar(),
            Expanded(
              child: Center(
                child: Text('여기에 메인 콘텐츠가 표시됩니다.'),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CommonBottomNavBar(),
      ),
    );
  }
}
