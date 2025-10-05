import 'package:flutter/material.dart';
import 'package:livee/presentation/common/vm/bouncing_speech_bubble_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';

// [수정] ViewModel을 사용하도록 구조를 변경했지만, TickerProvider를 제공해야 하므로 StatefulWidget을 유지합니다.
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
  late final BouncingSpeechBubbleViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // State가 TickerProvider 역할을 하여 ViewModel을 생성하고 초기화
    _viewModel = BouncingSpeechBubbleViewModel(vsync: this);
  }

  @override
  void dispose() {
    // ViewModel의 dispose를 호출하여 컨트롤러를 안전하게 해제
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SlideTransition의 position 값으로 ViewModel의 animation을 사용
    return SlideTransition(
      position: _viewModel.animation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: CustomPaint(
          painter: _SpeechBubblePainter(
            bubbleColor: AppColors.primary,
          ),
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

class _SpeechBubblePainter extends CustomPainter {
  final Color bubbleColor;

  _SpeechBubblePainter({required this.bubbleColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = bubbleColor;
    const radius = Radius.circular(999);

    final RRect bubbleBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    final Path tail = Path()
      ..moveTo(size.width / 2 - 8, size.height)
      ..lineTo(size.width / 2, size.height + 8)
      ..lineTo(size.width / 2 + 8, size.height)
      ..close();

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
