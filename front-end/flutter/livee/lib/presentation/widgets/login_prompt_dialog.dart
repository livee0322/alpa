import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 로그인이 필요할 때 표시하는 공통 모달(다이얼로그) 함수
Future<void> showLoginPromptDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          // 모달의 모서리를 더 둥글게 처리
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Container(
          
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 콘텐츠 크기에 맞게 높이 조절
            children: [
              const SizedBox(height: 16),
              // 제목
              const Text(
                '로그인이 필요합니다',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // 부가 설명
              const Text(
                '회원 전용 서비스입니다.\n로그인 하시겠습니까?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              // 버튼 영역
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        // 알약 모양 버튼
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('취소', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 로그인 버튼
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('로그인', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        GoRouter.of(context).go('/login');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
