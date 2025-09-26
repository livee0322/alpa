import 'package:flutter/material.dart';
import 'package:livee/domain/usecases/clip_use_case.dart';
import 'package:livee/service_locator.dart';

/// '숏클립 추가' 바텀시트의 상태와 로직을 관리
class AddClipViewModel with ChangeNotifier {
  final ClipUseCase _clipUseCase = locator<ClipUseCase>();

  // --- 숏클립 추가 관련 상태 ---
  final urlController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String? _thumbnailUrl;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isSubmitButtonEnabled = false;
  bool get isSubmitButtonEnabled => _isSubmitButtonEnabled;

  // --- 생성자 ---
  AddClipViewModel() {
    // urlController의 텍스트 변경을 감지하여 버튼 활성화 상태를 업데이트
    urlController.addListener(_updateSubmitButtonState);
  }

  /// URL 입력창의 텍스트 유무에 따라 저장 버튼의 활성화 상태를 변경
  void _updateSubmitButtonState() {
    final hasText = urlController.text.trim().isNotEmpty;
    if (_isSubmitButtonEnabled != hasText) {
      _isSubmitButtonEnabled = hasText;
      notifyListeners();
    }
  }

  /// URL이 유효한 형식(숏츠, 릴스, 틱톡 비디오)인지 검사
  bool _isValidUrl(String url) {
    final lowercasedUrl = url.toLowerCase();
    return lowercasedUrl.contains('youtube.com/shorts/') ||
        lowercasedUrl.contains('instagram.com/reel/') ||
        lowercasedUrl.contains('tiktok.com');
  }

  // --- 메소드: 숏클립 추가 ---

  /// 입력된 정보로 숏클립을 생성
  Future<String?> submitClip() async {
    final url = urlController.text.trim();
    if (url.isEmpty) return 'URL을 입력해주세요.';

    if (!_isValidUrl(url)) {
      return '유튜브 숏츠, 인스타그램 릴스, 틱톡 영상 주소만 등록할 수 있습니다.';
    }

    _isSaving = true;
    notifyListeners();
    try {
      // [추가] 1. 저장 직전에 스크래핑 로직을 실행하여 제목과 썸네일 URL을 가져옵니다.
      final videoInfo = await _clipUseCase.scrapeVideoInfo(url);

      final scrapedTitle = videoInfo['title'] ?? '';
      final scrapedThumbnailUrl = videoInfo['image'];

      // [추가] 2. 사용자가 제목을 직접 입력하지 않은 경우에만 스크래핑된 제목으로 덮어씁니다.
      if (titleController.text.isEmpty) {
        titleController.text = scrapedTitle;
      }

      // [추가] 3. 썸네일 URL을 업데이트합니다.
      _thumbnailUrl = scrapedThumbnailUrl;

      // [수정] 4. 스크래핑된 정보를 포함하여 클립 생성을 요청합니다.
      await _clipUseCase.createClip(
        url: url,
        title: titleController.text,
        description: descriptionController.text,
        thumbnailUrl: _thumbnailUrl,
      );

      urlController.clear();
      titleController.clear();
      descriptionController.clear();
      _thumbnailUrl = null; // 초기화
      return null;
    } catch (e) {
      debugPrint('Clip creation failed: $e');
      return '숏클립 생성에 실패했습니다. 잠시 후 다시 시도해주세요.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    urlController.removeListener(_updateSubmitButtonState);
    urlController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
