import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// CustomCropperDialog의 상태와 비즈니스 로직
class CustomCropperViewModel with ChangeNotifier {
  final BuildContext context;
  final XFile imageFile;
  final double aspectRatio;

  CustomCropperViewModel({
    required this.context,
    required this.imageFile,
    required this.aspectRatio,
  }) {
    // ViewModel 생성 시 이미지 파일을 바이트 데이터로 변환 시작
    _imageBytes = imageFile.readAsBytes();
  }

  // --- 상태 변수 ---
  final TransformationController transformationController =
      TransformationController();
  late final Future<Uint8List> _imageBytes;
  bool _isCropping = false;

  // --- Getter ---
  Future<Uint8List> get imageBytes => _imageBytes;
  bool get isCropping => _isCropping;

  /// '자르기' 버튼을 눌렀을 때 실행되는 핵심 로직
  void cropAndPop() async {
    _isCropping = true;
    notifyListeners(); // 로딩 시작을 UI에 알림

    final originalBytes = await _imageBytes;
    final originalImage = img.decodeImage(originalBytes);
    if (originalImage == null) {
      _finishCropping();
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    final cropWidth = screenSize.width * 0.8;
    final cropHeight = cropWidth / aspectRatio;

    final matrix = transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final position = matrix.getTranslation();

    // 원본 이미지에서 잘라낼 영역의 좌표와 크기를 계산
    final x = (cropWidth / 2 -
            position.x +
            (originalImage.width - cropWidth / scale) / 2 * scale) /
        scale;
    final y = (cropHeight / 2 -
            position.y +
            (originalImage.height - cropHeight / scale) / 2 * scale) /
        scale;
    final size = cropWidth / scale;

    final croppedImage = img.copyCrop(
      originalImage,
      x: x.round(),
      y: y.round(),
      width: size.round(),
      height: (size / aspectRatio).round(),
    );

    _finishCropping();
    // 잘린 이미지를 이전 화면으로 반환하며 다이얼로그 닫기
    Navigator.of(context).pop(Uint8List.fromList(img.encodePng(croppedImage)));
  }

  void _finishCropping() {
    _isCropping = false;
    notifyListeners(); // 로딩 종료를 UI에 알림
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }
}
