import 'package:flutter/widgets.dart';
import 'package:livee/domain/models/model.dart';
import 'package:livee/domain/usecases/model_use_case.dart';
import 'package:livee/service_locator.dart';

/// '모델' 목록 화면의 상태와 로직을 관리하는 ViewModel
class ModelListViewModel with ChangeNotifier {
  final ModelUseCase _modelUseCase = locator<ModelUseCase>();

  ModelListViewModel() {
    fetchModels(); // ViewModel 생성 시 첫 페이지 데이터를 불러오기
  }

  // --- 상태 변수 ---
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Model> _models = [];
  int _currentPage = 1;
  int _totalPages = 1;

  // --- Getter ---
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<Model> get models => _models;
  // '더 보기' 버튼을 표시할지 여부를 결정하는 getter
  bool get hasMore => _currentPage < _totalPages;

  /// 서버에서 모델 목록을 불러오는 메소드
  Future<void> fetchModels({bool isLoadMore = false}) async {
    // 이미 추가 로딩 중이면 중복 실행 방지
    if (_isLoadingMore) return;

    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentPage = 1; // 새로고침 시 1페이지부터
    }
    notifyListeners();

    try {
      final response = await _modelUseCase.getAllModels(page: _currentPage, limit: 10); // 한 페이지에 10개씩

      if (isLoadMore) {
        _models.addAll(response.items); // 기존 리스트에 추가
      } else {
        _models = response.items; // 새로운 리스트로 교체
      }
      _totalPages = response.totalPages;
    } catch (e) {
      debugPrint('Error fetching models: $e');
      // TODO: 사용자에게 에러 알림
    } finally {
      if (isLoadMore) {
        _isLoadingMore = false;
      } else {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// '더 보기' 버튼을 눌렀을 때 다음 페이지를 불러오는 메소드
  void fetchNextPage() {
    if (hasMore) {
      _currentPage++;
      fetchModels(isLoadMore: true);
    }
  }
}
