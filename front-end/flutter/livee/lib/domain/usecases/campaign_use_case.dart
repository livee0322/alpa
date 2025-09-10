import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/repositories/campaign_repository.dart';

class CampaignUseCase {
  final CampaignRepository _repository;

  CampaignUseCase(this._repository);

  Future<List<Campaign>> getMyCampaigns() {
    return _repository.getMyCampaigns();
  }

  Future<PaginatedResponse<Campaign>> getAllCampaigns({
    String? type,
    int? limit,
    int? page,
    String? search,
    String? sort,
  }) {
    return _repository.getAllCampaigns(
      type: type,
      limit: limit,
      page: page,
      search: search,
      sort: sort,
    );
  }

  Future<Campaign> getCampaignById(String id) {
    return _repository.getCampaignById(id);
  }

  Future<void> createCampaign(Map<String, dynamic> data) {
    return _repository.createCampaign(data);
  }

  Future<void> updateCampaign(String id, Map<String, dynamic> data) {
    return _repository.updateCampaign(id, data);
  }

  Future<void> deleteCampaign(String id) {
    return _repository.deleteCampaign(id);
  }
}
