import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';

// 쇼호스트가 찜한 공고 목록을 보여주는 화면
class BookmarkedRecruitsScreen extends StatelessWidget {
  const BookmarkedRecruitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 찜한 공고'),
      ),
      body: Center(
        // TODO: API 연동 후 찜한 공고 목록을 ListView로 구현
        child: Text(
          '아직 찜한 공고가 없습니다.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }
}
