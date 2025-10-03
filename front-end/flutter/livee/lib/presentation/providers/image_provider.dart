import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/presentation/widgets/custom_cropper_dialog.dart';

/// 이미지 선택, 크롭, 업로드 등 이미지 관련 기능을 전역으로 제공
class ImageHandlerProvider  with ChangeNotifier {
  final CloudinaryUploader _uploader = CloudinaryUploader();
  bool _isLoading = false;

  /// 현재 이미지 처리(업로드 등)가 진행 중인지 여부
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 갤러리에서 이미지를 선택하고, 필요 시 크롭하여 이미지 원본 데이터(Uint8List)를 반환

  /*  [context]와 [aspectRatio]를 제공하면,
      이미지 선택 후 [CustomCropperDialog]를 통해
      지정된 비율로 이미지를 크롭하는 UI를 표시
  */
  Future<Uint8List?> pickImage({
    BuildContext? context,
    double? aspectRatio,
  }) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    // context와 aspectRatio가 모두 제공된 경우에만 크롭 다이얼로그를 표시
    if (context != null && aspectRatio != null) {
      // Dialog는 context가 mounted 된 상태에서만 호출해야 안전
      if (!context.mounted) return null;
      final croppedBytes = await showDialog<Uint8List>(
        context: context,
        builder: (_) => CustomCropperDialog(
          imageFile: pickedFile,
          aspectRatio: aspectRatio,
        ),
      );
      return croppedBytes;
    }

    // 크롭이 필요 없는 경우, 선택한 파일의 원본 바이트 데이터를 반환
    return await pickedFile.readAsBytes();
  }

  /// 이미지 바이트 데이터를 Cloudinary에 업로드하고 이미지 URL을 반환
  Future<String?> uploadImage(Uint8List imageBytes,
      {String? fileName, String type = 'image'}) async {
    _setLoading(true);
    try {
      final url = await _uploader.uploadFile(imageBytes,
          fileName: fileName, type: type);
      return url;
    } catch (e) {
      debugPrint('Image upload failed in ImageProvider: $e');
      rethrow; // 에러를 다시 던져서 호출한 쪽에서 UI 피드백(예: 토스트)을 줄 수 있도록 하기
    } finally {
      _setLoading(false);
    }
  }
}
