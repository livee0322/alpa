import 'package:flutter/material.dart';

/// 크롭 영역의 UI를 그리는 CustomPainter
class CropperOverlayPainter extends CustomPainter {
  final Size cropSize;
  final bool isCircle;

  CropperOverlayPainter({required this.cropSize, this.isCircle = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.5);

    // 크롭 영역의 Rect(사각형) 정의
    final cropRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cropSize.width,
      height: cropSize.height,
    );

    // 전체 화면에서 크롭 영역을 뺀 나머지 부분을 어둡게 칠함
    if (isCircle) {
      final path = Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addOval(cropRect),
      );
      canvas.drawPath(path, paint);
    } else {
      final path = Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(cropRect),
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
