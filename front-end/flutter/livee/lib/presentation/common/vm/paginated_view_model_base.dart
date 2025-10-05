import 'package:flutter/material.dart';
import 'package:livee/domain/models/paginated_response.dart';

/// 페이지네이션을 사용하는 모든 ViewModel이 상속받아야 할 추상 클래스(설계도)
/// <T>는 각 ViewModel이 다룰 데이터 모델의 타입 (예: Campaign, News)
abstract class PaginatedViewModelBase<T> with ChangeNotifier {
  // --- 상태 변수 ---
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<T> _items = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  // --- Getter ---
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<T> get items => _items;
  bool get hasMore => _currentPage < _totalPages;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;

  // --- 생성자 ---
  PaginatedViewModelBase() {
    loadData(); // ViewModel이 생성되면 첫 페이지 데이터를 자동으로 불러오기
  }

  // --- 핵심 추상 메소드 ---
  /// 하위 클래스가 반드시 구현해야 하는 메소드
  /// 실제 서버 API를 호출하여 특정 페이지의 데이터를 가져오는 역할
  Future<PaginatedResponse<T>> fetchPage(int page);

  // --- 공통 기능 메소드 ---

  /// 데이터를 처음 불러오거나 새로고침할 때 사용
  Future<void> loadData() async {
    _isLoading = true;
    _currentPage = 1;
    notifyListeners();

    try {
      final response = await fetchPage(_currentPage);
      _items = response.items;
      _totalPages = response.totalPages;
      _currentPage = response.currentPage;
      _totalItems = response.totalItems;
    } catch (e) {
      debugPrint('[PaginatedViewModel] 데이터 로딩 실패: $e');
      _items = []; // 에러 발생 시 목록을 비우기
      _totalItems = 0; // 에러 발생 시 0으로 초기화
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 스크롤을 맨 아래로 내렸을 때 다음 페이지를 불러오기
  Future<void> loadMore() async {
    if (!hasMore || _isLoadingMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();
    _currentPage++;

    try {
      final response = await fetchPage(_currentPage);
      _items.addAll(response.items);
      _totalPages = response.totalPages;
      _currentPage = response.currentPage;
    } catch (e) {
      debugPrint('[PaginatedViewModel] 추가 데이터 로딩 실패: $e');
      _currentPage--; // 실패 시 페이지 번호를 원래대로 돌려놓기
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// 목록을 새로고침
  Future<void> refresh() {
    return loadData();
  }
}
