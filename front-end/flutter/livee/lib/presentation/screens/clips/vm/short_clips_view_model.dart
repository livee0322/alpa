import 'package:flutter/material.dart';
import 'package:livee/domain/models/clip.dart';
import 'package:livee/domain/usecases/clip_use_case.dart';
import 'package:livee/service_locator.dart';

/// 숏클립 '목록'의 상태와 로직을 관리
class ShortClipsViewModel with ChangeNotifier {
  final ClipUseCase _clipUseCase = locator<ClipUseCase>();

  // --- 숏클립 목록 관련 상태 ---
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Clip> _clips = [];
  List<Clip> get clips => _clips;

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
}
