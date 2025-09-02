import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 쇼호스트의 상세 프로필 정보를 보여주는 화면
class ShowhostDetailScreen extends StatelessWidget {
  final String showhostId;

  const ShowhostDetailScreen({
    super.key,
    required this.showhostId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쇼호스트 상세 정보'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // TODO: API 연동 후 실제 데이터로 UI 구성
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 20),
            _buildInfoSection(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/casting-request', extra: showhostId),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('섭외 요청하기'),
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 섹션 UI (사진, 이름 등)
  Widget _buildProfileSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://picsum.photos/seed/123/96/96', // 임시 이미지
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('쇼호스트 이름', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('카테고리: 뷰티', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상세 정보 섹션 UI (소개, 경력 등)
  Widget _buildInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('희망 출연료', '30만원'),
            _buildInfoRow('경력', '5년'),
            _buildInfoRow('자기소개', '시청자의 마음을 사로잡는 쇼호스트입니다. 뷰티, 패션 전문입니다.'),
          ],
        ),
      ),
    );
  }

  /// 정보 항목을 만드는 헬퍼 위젯
  Widget _buildInfoRow(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }
}
