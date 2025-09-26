import 'package:flutter/material.dart';
import 'package:livee/domain/models/news.dart';
import 'package:livee/domain/usecases/news_use_case.dart';
import 'package:livee/service_locator.dart';

/// '뉴스 상세' 페이지의 상태와 로직을 관리
class NewsDetailViewModel with ChangeNotifier {
  final NewsUseCase _newsUseCase = locator<NewsUseCase>();
  final String newsId;

  NewsDetailViewModel({required this.newsId}) {
    fetchNewsDetail(); // ViewModel 생성 시 데이터 로딩 시작
  }

  // --- 상태 변수 ---
  bool _isLoading = true;
  News? _news;
  String? _errorMessage;

  // --- Getter ---
  bool get isLoading => _isLoading;
  News? get news => _news;
  String? get errorMessage => _errorMessage;

  /// 서버에서 특정 뉴스의 상세 정보를 불러오는 메소드
  Future<void> fetchNewsDetail() async {
    _isLoading = true;
    notifyListeners();
    try {
      _news = await _newsUseCase.getNewsById(newsId);
    } catch (e) {
      _errorMessage = '뉴스 정보를 불러오는 데 실패했습니다.';
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
