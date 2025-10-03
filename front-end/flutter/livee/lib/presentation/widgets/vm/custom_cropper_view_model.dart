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
    notifyListeners();

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

    // 화면상 크롭 영역의 좌상단 좌표
    final cropLeftOnScreen = (screenSize.width - cropWidth) / 2;
    final cropTopOnScreen =
        (screenSize.height * 0.6 - cropHeight) / 2 + 16; // Dialog Padding 고려

    // 이미지 기준 좌표로 변환
    final x = (cropLeftOnScreen - position.x) / scale;
    final y = (cropTopOnScreen - position.y) / scale;
    final width = cropWidth / scale;
    final height = cropHeight / scale;

    final croppedImage = img.copyCrop(
      originalImage,
      x: x.round(),
      y: y.round(),
      width: width.round(),
      height: height.round(),
    );

    _finishCropping();
    Navigator.of(context).pop(Uint8List.fromList(img.encodePng(croppedImage)));
  }

  void _finishCropping() {
    _isCropping = false;
    notifyListeners();
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }
}
