import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';

// 특정 캠페인의 지원자 목록을 보여주는 화면
class ApplicantListScreen extends StatelessWidget {
  final String campaignId;

  const ApplicantListScreen({
    super.key,
    required this.campaignId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지원자 현황'),
      ),
      body: Center(
        // TODO: API 연동 후 지원자 목록을 ListView로 구현
        child: Text(
          '아직 지원자가 없습니다.',
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
