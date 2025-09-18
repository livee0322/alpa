import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';

// 위아래로 부드럽게 움직이는 애니메이션이 적용된 말풍선
class BouncingSpeechBubble extends StatefulWidget {
  final String text;

  const BouncingSpeechBubble({
    super.key,
    required this.text,
  });

  @override
  State<BouncingSpeechBubble> createState() => _BouncingSpeechBubbleState();
}

class _BouncingSpeechBubbleState extends State<BouncingSpeechBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // 애니메이션 컨트롤러를 설정 (800ms 동안 한 번 움직임)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true); // 위아래로 무한 반복하도록 설정

    // 애니메이션의 움직임 범위를 설정합니다 (Y축으로 살짝 위로 이동).
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.2), // Y축으로의 이동량
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // 부드럽게 시작하고 멈추는 효과
    ));
  }

  @override
  void dispose() {
    _controller.dispose(); // 위젯이 사라질 때 컨트롤러를 정리하여 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      // [수정] 꼬리가 그려질 추가 공간(8px)을 확보하기 위해 Padding을 추가합니다.
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: CustomPaint(
          painter: _SpeechBubblePainter(
            bubbleColor: AppColors.primary,
          ),
          // CustomPaint의 자식으로 텍스트를 배치합니다.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// [수정] 말풍선 전체를 그리는 로직으로 변경합니다.
class _SpeechBubblePainter extends CustomPainter {
  final Color bubbleColor;

  _SpeechBubblePainter({required this.bubbleColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = bubbleColor;
    const radius = Radius.circular(999); // 둥근 모서리

    // 말풍선 몸통(Rounded Rectangle) 경로
    final RRect bubbleBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    // 꼬리(Triangle) 경로
    final Path tail = Path();
    tail.moveTo(size.width / 2 - 8, size.height); // 꼬리 시작점 (왼쪽)
    tail.lineTo(size.width / 2, size.height + 8); // 꼬리 끝점 (아래)
    tail.lineTo(size.width / 2 + 8, size.height); // 꼬리 시작점 (오른쪽)
    tail.close();

    // 몸통과 꼬리를 합칩니다.
    final Path bubbleWithTail = Path.combine(
      PathOperation.union,
      Path()..addRRect(bubbleBody),
      tail,
    );

    canvas.drawPath(bubbleWithTail, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}