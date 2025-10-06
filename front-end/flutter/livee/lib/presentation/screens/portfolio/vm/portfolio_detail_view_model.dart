import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/presentation/common/vm/detail_view_model_base.dart';
import 'package:livee/service_locator.dart';

/// '포트폴리오 상세' 페이지의 상태와 로직을 관리하는 ViewModel
class PortfolioDetailViewModel extends DetailViewModelBase<Portfolio> {
  final PortfolioRepository _portfolioRepository = locator<PortfolioRepository>();

  PortfolioDetailViewModel({required String portfolioId}) {
    loadItem(portfolioId);
  }

  @override
  Future<Portfolio> fetchItem(String id) {
    return _portfolioRepository.getPortfolioById(id);
  }
}
