import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';

// 쇼호스트가 브랜드로부터 받은 제안 목록을 보여주는 화면
class ReceivedOffersScreen extends StatelessWidget {
  const ReceivedOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('받은 제안'),
      ),
      body: Center(
        // TODO: API 연동 후 받은 제안 목록을 ListView로 구현
        child: Text(
          '아직 받은 제안이 없습니다.',
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
