import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:livee/presentation/styles/app_colors.dart'; // image 패키지를 img라는 별칭으로 사용

/// 이미지를 자를 수 있는 커스텀 다이얼로그 위젯
class CustomCropperDialog extends StatefulWidget {
  final XFile imageFile; // 편집할 원본 이미지 파일
  final double aspectRatio; // 자를 비율 (1.0 = 1:1, 16/9 = 16:9)

  const CustomCropperDialog({
    super.key,
    required this.imageFile,
    this.aspectRatio = 1.0, // 기본값은 1:1 (정사각형)
  });

  @override
  State<CustomCropperDialog> createState() => _CustomCropperDialogState();
}

class _CustomCropperDialogState extends State<CustomCropperDialog> {
  final TransformationController _transformationController =
      TransformationController();
  late Future<Uint8List> _imageBytes;

  // _CustomCropperDialogState 클래스에 _isCropping 변수 추가
  final ValueNotifier<bool> _isCropping = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때 이미지 파일을 바이트 데이터로 변환
    _imageBytes = widget.imageFile.readAsBytes();
  }

  /// '자르기' 버튼을 눌렀을 때 실행되는 핵심 로직
  void _cropAndPop() async {
    _isCropping.value = true; // 로딩 시작
    // 1. 현재 화면에 표시된 이미지의 바이트 데이터를 가져옴
    final originalBytes = await _imageBytes;
    // image 패키지를 사용하여 디코딩
    final originalImage = img.decodeImage(originalBytes);
    if (originalImage == null) return;

    // 2. 화면 크기와 크롭 영역의 크기를 가져옴
    final screenSize = MediaQuery.of(context).size;
    final cropSize = screenSize.width * 0.8; // 크롭 영역은 화면 너비의 80%

    // 3. InteractiveViewer의 현재 상태(확대/축소 배율, 이동 위치)를 가져옴
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final position = matrix.getTranslation();

    // 4. 원본 이미지에서 잘라낼 영역의 좌표와 크기를 계산
    // (화면 좌표를 원본 이미지 좌표로 변환하는 과정)
    final x = (cropSize / 2 - position.x) / scale;
    final y = (cropSize / 2 - position.y) / scale;
    final size = cropSize / scale;

    // 5. image 패키지의 copyCrop 함수를 사용하여 이미지를 자름
    final croppedImage = img.copyCrop(
      originalImage,
      x: x.round(),
      y: y.round(),
      width: size.round(),
      height: (size / widget.aspectRatio).round(),
    );
    _isCropping.value = false; // 로딩 끝
    // 6. 잘린 이미지를 PNG 형식의 바이트 데이터로 인코딩하여 이전 화면으로 반환
    Navigator.of(context).pop(Uint8List.fromList(img.encodePng(croppedImage)));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cropSize = screenSize.width * 0.8;
    final cropHeight = cropSize / widget.aspectRatio;

    return Dialog(
      // [수정] 배경색을 AppColors.white로 설정합니다.
      backgroundColor: AppColors.white,
      // [추가] 둥근 모서리를 적용합니다.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 이미지 편집 영역
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: screenSize.width,
                  height: screenSize.height * 0.6,
                  child: FutureBuilder<Uint8List>(
                    future: _imageBytes,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Stack(
                        children: [
                          InteractiveViewer(
                            transformationController: _transformationController,
                            maxScale: 5.0,
                            child: Center(child: Image.memory(snapshot.data!)),
                          ),
                          IgnorePointer(
                            child: Center(
                              child: CustomPaint(
                                painter: CropperOverlayPainter(
                                  cropSize: Size(cropSize, cropHeight),
                                  isCircle: widget.aspectRatio == 1.0,
                                ),
                                child: SizedBox(
                                  width: cropSize,
                                  height: cropHeight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              // 하단 버튼 영역
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isCropping,
                      builder: (context, isCropping, child) => ElevatedButton(
                        onPressed: isCropping ? null : _cropAndPop,
                        child: isCropping
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('자르기'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          // [추가] 우측 상단에 닫기(X) 버튼을 추가합니다.
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

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
