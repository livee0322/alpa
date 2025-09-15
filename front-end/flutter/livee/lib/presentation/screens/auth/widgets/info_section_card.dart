import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';

// 회원가입 시 추가 정보 섹션의 공통 UI 레이아웃을 담당하는 위젯
class InfoSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const InfoSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // 섹션 제목
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        // 입력 필드를 감싸는 공통 카드
        StandardContentCard(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // children으로 받은 위젯 리스트를 여기에 배치
            children: children,
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
