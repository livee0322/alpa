import 'package:flutter/material.dart';

/// 상세 페이지 등 단일 데이터를 불러오는 모든 ViewModel이 상속받아야 할 추상 클래스
/// <T>는 각 ViewModel이 다룰 데이터 모델의 타입 (예: Campaign, Portfolio)
abstract class DetailViewModelBase<T> with ChangeNotifier {
  // --- 상태 변수 ---
  bool _isLoading = true;
  T? _item;
  String? _errorMessage;

  // --- Getter ---
  bool get isLoading => _isLoading;
  T? get item => _item;
  String? get errorMessage => _errorMessage;

  /// 하위 클래스가 반드시 구현해야 하는 메소드
  /// 실제 서버 API를 호출하여 ID에 해당하는 단일 데이터를 가져오는 역할
  Future<T> fetchItem(String id);

  /// 데이터를 불러오는 공통 로직
  Future<void> loadItem(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _item = await fetchItem(id);
    } catch (e) {
      debugPrint('[DetailViewModelBase] 데이터 로딩 실패: $e');
      _errorMessage = '데이터를 불러오는 데 실패했습니다.';
      _item = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
