import 'package:flutter/material.dart';
import 'package:livee/domain/models/news.dart';
import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/usecases/news_use_case.dart';
import 'package:livee/service_locator.dart';

/// '뉴스 목록' 화면의 상태와 로직을 관리
class NewsListViewModel with ChangeNotifier {
  final NewsUseCase _newsUseCase = locator<NewsUseCase>();

  NewsListViewModel() {
    fetchNews(); // ViewModel 생성 시 첫 페이지 데이터를 불러오기
  }

  // --- 상태 변수 ---
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<News> _newsList = [];
  int _currentPage = 1;
  int _totalPages = 1;

  // --- Getter ---
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<News> get newsList => _newsList;
  bool get hasMore => _currentPage < _totalPages; // 더 불러올 페이지가 있는지 확인

  /// 서버에서 뉴스 목록을 불러오는 메소드
  Future<void> fetchNews({bool isLoadMore = false}) async {
    if (_isLoadingMore) return; // 중복 호출 방지

    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentPage = 1; // 새로고침 시 1페이지부터 다시 시작
    }
    notifyListeners();

    try {
      final response = await _newsUseCase.getNewsList(page: _currentPage, limit: 10);
      if (isLoadMore) {
        _newsList.addAll(response.items); // 기존 목록에 추가
      } else {
        _newsList = response.items; // 새 목록으로 교체
      }
      _totalPages = response.totalPages;
    } catch (e) {
      debugPrint('Error fetching news: $e');
    } finally {
      if (isLoadMore) {
        _isLoadingMore = false;
      } else {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// 다음 페이지를 불러오는 메소드
  void fetchNextPage() {
    if (hasMore) {
      _currentPage++;
      fetchNews(isLoadMore: true);
    }
  }
}
