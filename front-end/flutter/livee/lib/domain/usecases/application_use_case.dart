import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/application_repository.dart';

/// 지원 관련 비즈니스 로직을 처리하는 유스케이스
class ApplicationUseCase {
  final ApplicationRepository _repository;

  ApplicationUseCase(this._repository);

  Future<void> applyToCampaign({
    required String campaignId,
    required String portfolioId,
    required String message,
  }) {
    return _repository.createApplication(
      campaignId: campaignId,
      portfolioId: portfolioId,
      message: message,
    );
  }

  Future<List<Portfolio>> getApplicantsForCampaign(String campaignId) {
    return _repository.getApplicantsForCampaign(campaignId);
  }
}
