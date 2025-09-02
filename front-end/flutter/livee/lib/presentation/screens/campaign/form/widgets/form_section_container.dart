import 'package:flutter/material.dart';

// 캠페인 폼의 각 섹션을 감싸는 공통 컨테이너 위젯
class FormSectionContainer extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FormSectionContainer({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 외부 여백
      margin: const EdgeInsets.only(bottom: 18),
      // 내부 여백
      padding: const EdgeInsets.all(16),
      // 디자인 스타일 (배경색, 테두리, 그림자)
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEF0F3)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 제목
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          // 섹션 내용
          ...children,
        ],
      ),
    );
  }
}
