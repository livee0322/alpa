import 'package:flutter/material.dart';
import 'package:livee/domain/models/clip.dart';
import 'package:livee/domain/usecases/clip_use_case.dart';
import 'package:livee/service_locator.dart';

// 숏클립 CRUD 등 모든 관련 상태와 로직을 관리
class ShortClipsViewModel with ChangeNotifier {
  final ClipUseCase _clipUseCase = locator<ClipUseCase>();

  // --- 숏클립 목록 관련 상태 ---
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Clip> _clips = [];
  List<Clip> get clips => _clips;

  // --- 숏클립 추가 관련 상태 ---
  final urlController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  bool _isScraping = false;
  bool get isScraping => _isScraping;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  // 저장 버튼 활성화 여부를 관리하는 상태 변수
  bool _isSubmitButtonEnabled = false;
  bool get isSubmitButtonEnabled => _isSubmitButtonEnabled;

  // --- 생성자 ---
  ShortClipsViewModel() {
    fetchClips();
    // urlController의 텍스트 변경을 감지하여 버튼 활성화 상태를 업데이트
    urlController.addListener(_updateSubmitButtonState);
  }

  /// URL 입력창의 텍스트 유무에 따라 저장 버튼의 활성화 상태를 변경하는 메소드
  void _updateSubmitButtonState() {
    final hasText = urlController.text.trim().isNotEmpty;
    if (_isSubmitButtonEnabled != hasText) {
      _isSubmitButtonEnabled = hasText;
      notifyListeners();
    }
  }

  /// [추가] URL이 유효한 형식(숏츠, 릴스, 틱톡 비디오)인지 검사하는 메소드
  bool _isValidUrl(String url) {
    final lowercasedUrl = url.toLowerCase();
    return lowercasedUrl.contains('youtube.com/shorts/') ||
        lowercasedUrl.contains('instagram.com/reel/') ||
        lowercasedUrl.contains('tiktok.com'); // 틱톡은 도메인만 검사해도 충분
  }

  // --- 메소드: 목록 관리 ---

  // 서버에서 숏클립 목록을 불러오기
  Future<void> fetchClips() async {
    _isLoading = true;
    notifyListeners();
    try {
      _clips = await _clipUseCase.getClips();
    } catch (e) {
      debugPrint('Error fetching clips: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 특정 숏클립을 삭제
  Future<void> deleteClip(String clipId) async {
    try {
      await _clipUseCase.deleteClip(clipId);
      await fetchClips(); // 삭제 후 목록을 새로고침
    } catch (e) {
      debugPrint('Error deleting clip: $e');
    }
  }

  // --- 메소드: 숏클립 추가 ---

  // URL을 스크래핑하여 영상 제목을 자동으로 채우기
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

  // [수정] 입력된 정보로 숏클립을 생성하는 메소드 (URL 유효성 검사 추가)
  // 반환 타입을 Future<String?>으로 변경하여 성공 시 null, 실패 시 에러 메시지를 반환하도록 합니다.
  Future<String?> submitClip() async {
    final url = urlController.text.trim();
    if (url.isEmpty) return 'URL을 입력해주세요.';

    // [추가] 저장 버튼을 누르는 시점에 URL 유효성을 검사합니다.
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
      // 성공 후 컨트롤러 초기화
      urlController.clear();
      titleController.clear();
      descriptionController.clear();
      return null; // 성공 시 null 반환
    } catch (e) {
      debugPrint('Clip creation failed: $e');
      return '숏클립 생성에 실패했습니다. 잠시 후 다시 시도해주세요.'; // 실패 시 사용자에게 보여줄 메시지
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
