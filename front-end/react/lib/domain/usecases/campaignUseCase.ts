import { CampaignRepository } from '../repositories/campaignRepository';
import { Campaign } from '../models/campaign';

export class CampaignUseCase {
    private repository: CampaignRepository;

    constructor(repository: CampaignRepository) {
        this.repository = repository;
    }

    public async getAllCampaigns(type?: string, limit?: number): Promise<Campaign[]> {
        return this.repository.getAllCampaigns(type, limit);
    }

    // TODO: getMyCampaigns, getCampaignById 등 나머지 메서드 구현
}