import 'package:flutter/material.dart';
import 'package:livee/domain/models/studio.dart';
import 'package:livee/domain/usecases/studio_use_case.dart';
import 'package:livee/service_locator.dart';

/// '스튜디오 상세' 페이지의 상태와 로직을 관리
class StudioViewModel with ChangeNotifier {
  final StudioUseCase _studioUseCase = locator<StudioUseCase>();
  final String studioId;

  StudioViewModel({required this.studioId}) {
    fetchStudioDetail();
  }

  bool _isLoading = true;
  Studio? _studio;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Studio? get studio => _studio;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStudioDetail() async {
    _isLoading = true;
    notifyListeners();
    try {
      _studio = await _studioUseCase.getStudioById(studioId);
    } catch (e) {
      _errorMessage = '스튜디오 정보를 불러오는 데 실패했습니다.';
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
