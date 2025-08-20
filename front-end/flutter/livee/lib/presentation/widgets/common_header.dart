import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 60, // approximate height
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 로고
          GestureDetector(
            onTap: () {
              // TODO: GoRouter를 사용하여 홈 페이지로 이동하는 로직 추가
            },
            child: Image.asset(
              'assets/images/liveelogo.png',
              height: 42,
            ),
          ),
          // 로그인 버튼
          TextButton(
            onPressed: () {
              // TODO: GoRouter를 사용하여 로그인 페이지로 이동하는 로직 추가
            },
            child: const Text(
              '로그인',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
