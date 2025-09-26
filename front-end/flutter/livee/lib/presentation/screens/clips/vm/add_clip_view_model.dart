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

  bool _isScraping = false;
  bool get isScraping => _isScraping;

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

  /// URL을 스크래핑하여 영상 제목을 자동으로 채우기
  Future<void> scrapeUrl() async {
    if (urlController.text.trim().isEmpty) return;
    _isScraping = true;
    notifyListeners();
    try {
      final videoInfo = await _clipUseCase.scrapeVideoInfo(urlController.text);
      titleController.text = videoInfo['title'] ?? '';
    } catch (e) {
      debugPrint('Scraping failed: $e');
    } finally {
      _isScraping = false;
      notifyListeners();
    }
  }

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
      await _clipUseCase.createClip(
        url: url,
        title: titleController.text,
        description: descriptionController.text,
      );
      urlController.clear();
      titleController.clear();
      descriptionController.clear();
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
