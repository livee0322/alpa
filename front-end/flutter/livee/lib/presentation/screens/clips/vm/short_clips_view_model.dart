import 'package:flutter/material.dart';
import 'package:livee/domain/models/clip.dart';
import 'package:livee/domain/usecases/clip_use_case.dart';
import 'package:livee/service_locator.dart';

// [설명] 숏클립 CRUD 등 모든 관련 상태와 로직을 관리
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

  // --- 생성자 ---
  ShortClipsViewModel() {
    fetchClips();
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

  // 입력된 정보로 숏클립을 생성
  Future<bool> submitClip() async {
    if (urlController.text.trim().isEmpty) return false;
    _isSaving = true;
    notifyListeners();
    try {
      await _clipUseCase.createClip(
        url: urlController.text,
        title: titleController.text,
        description: descriptionController.text,
      );
      // 성공 후 컨트롤러 초기화
      urlController.clear();
      titleController.clear();
      descriptionController.clear();
      return true; // 성공
    } catch (e) {
      debugPrint('Clip creation failed: $e');
      return false; // 실패
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    urlController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
