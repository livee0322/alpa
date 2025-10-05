import 'package:livee/domain/models/model.dart';
import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/usecases/model_use_case.dart';
import 'package:livee/presentation/common/vm/paginated_view_model_base.dart';
import 'package:livee/service_locator.dart';

/// '모델' 목록 화면의 상태와 로직을 관리
class ModelListViewModel extends PaginatedViewModelBase<Model> {
  final ModelUseCase _modelUseCase = locator<ModelUseCase>();

  /// 서버에서 모델 목록을 불러오는 메소드
  @override
  Future<PaginatedResponse<Model>> fetchPage(int page) {
    // '모델' 목록을 가져오는 API를 호출하여 부모 클래스에 결과를 반환
    return _modelUseCase.getAllModels(page: page, limit: 10);
  }
}
