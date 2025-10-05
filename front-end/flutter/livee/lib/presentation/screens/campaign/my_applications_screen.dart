import 'package:flutter/material.dart';

/// 쇼호스트가 지원한 공고 목록을 보여주는 화면
class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 지원한 공고'),
      ),
      body: Center(
        // TODO: API 연동 후 지원한 공고 목록 구현
        child: Text(
          '아직 지원한 공고가 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
