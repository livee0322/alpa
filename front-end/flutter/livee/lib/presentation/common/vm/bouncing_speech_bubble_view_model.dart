import 'package:flutter/material.dart';

/// BouncingSpeechBubble 위젯의 애니메이션 로직
class BouncingSpeechBubbleViewModel with ChangeNotifier {
  late final AnimationController controller;
  late final Animation<Offset> animation;

  /// 생성자: 애니메이션 컨트롤러를 초기화하기 위해 TickerProvider를 필수로 받기
  BouncingSpeechBubbleViewModel({required TickerProvider vsync}) {
    // 애니메이션 컨트롤러를 설정 (800ms 동안 한 번 움직임)
    controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    )..repeat(reverse: true); // 위아래로 무한 반복하도록 설정

    // 애니메이션의 움직임 범위를 설정 (Y축으로 살짝 위로 이동).
    animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.2), // Y축으로의 이동량
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut, // 부드럽게 시작하고 멈추는 효과
    ));
  }

  @override
  void dispose() {
    controller.dispose(); // 컨트롤러를 정리하여 메모리 누수를 방지
    super.dispose();
  }
}
