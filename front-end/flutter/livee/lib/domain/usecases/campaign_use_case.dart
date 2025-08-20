import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/repositories/campaign_repository.dart';

class CampaignUseCase {
  final CampaignRepository _repository;

  CampaignUseCase(this._repository);

  Future<List<Campaign>> getMyCampaigns() {
    return _repository.getMyCampaigns();
  }

  Future<List<Campaign>> getAllCampaigns({String? type, int? limit}) {
    return _repository.getAllCampaigns(type: type, limit: limit);
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
