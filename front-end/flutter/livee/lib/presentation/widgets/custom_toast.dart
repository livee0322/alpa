import 'dart:async';
import 'package:flutter/material.dart';

// 토스트 메시지의 유형 (성공, 실패/에러)
enum ToastType { success, error }

// 커스텀 토스트 메시지를 화면에 표시하는 함수
void showCustomToast(BuildContext context, String message, {ToastType type = ToastType.error}) {
  // OverlayState를 찾음
  final overlay = Overlay.of(context);
  // Overlay에 삽입될 OverlayEntry 생성
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      // 화면 하단 중앙에 위치
      bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      left: 24,
      right: 24,
      child: CustomToastWidget(
        message: message,
        type: type,
        // 위젯이 사라질 때 OverlayEntry를 제거
        onDismissed: () {
          overlayEntry.remove();
        },
      ),
    ),
  );

  // Overlay에 위젯을 삽입
  overlay.insert(overlayEntry);
}

// 토스트 UI 위젯
class CustomToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismissed;

  const CustomToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<CustomToastWidget> createState() => _CustomToastWidgetState();
}

class _CustomToastWidgetState extends State<CustomToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // 위에서 아래로 내려오는 효과를 위한 애니메이션
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    // 위젯이 빌드된 후 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      // 2.5초 후 사라지는 애니메이션 시작
      Timer(const Duration(milliseconds: 2500), () {
        _controller.reverse().then((_) => widget.onDismissed());
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData iconData;

    switch (widget.type) {
      case ToastType.success:
        backgroundColor = const Color(0xFF2E7D32); // 진한 초록색
        iconData = Icons.check_circle_outline;
        break;
      case ToastType.error:
        backgroundColor = const Color(0xFFC62828); // 진한 붉은색
        iconData = Icons.error_outline;
        break;
    }

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5), // 아래에서 시작
          end: Offset.zero, // 제자리로
        ).animate(_animation),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}