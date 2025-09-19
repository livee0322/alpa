import 'package:flutter/material.dart';
import 'package:livee/domain/models/model.dart';
import 'package:livee/domain/usecases/model_use_case.dart';
import 'package:livee/service_locator.dart';

/// '모델 상세' 페이지의 상태와 로직을 관리하는 ViewModel
class ModelDetailViewModel with ChangeNotifier {
  final ModelUseCase _modelUseCase = locator<ModelUseCase>();
  final String modelId;

  ModelDetailViewModel({required this.modelId}) {
    fetchModelDetail(); // ViewModel 생성 시 데이터 로딩 시작
  }

  // --- 상태 변수 ---
  bool _isLoading = true;
  Model? _model;
  String? _errorMessage;

  // --- Getter ---
  bool get isLoading => _isLoading;
  Model? get model => _model;
  String? get errorMessage => _errorMessage;

  /// 서버에서 특정 모델의 상세 정보를 불러오는 메소드
  Future<void> fetchModelDetail() async {
    _isLoading = true;
    notifyListeners();
    try {
      _model = await _modelUseCase.getModelById(modelId);
    } catch (e) {
      _errorMessage = '모델 정보를 불러오는 데 실패했습니다.';
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
