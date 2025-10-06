import 'package:livee/domain/models/model.dart';
import 'package:livee/domain/usecases/model_use_case.dart';
import 'package:livee/presentation/common/vm/detail_view_model_base.dart';
import 'package:livee/service_locator.dart';

/// '모델 상세' 페이지의 상태와 로직을 관리하는 ViewModel
class ModelDetailViewModel extends DetailViewModelBase<Model> {
  final ModelUseCase _modelUseCase = locator<ModelUseCase>();

  ModelDetailViewModel({required String modelId}) {
    loadItem(modelId);
  }

  /// 서버에서 특정 모델의 상세 정보를 불러오는 메소드
  @override
  Future<Model> fetchItem(String id) {
    return _modelUseCase.getModelById(id);
  }
}
