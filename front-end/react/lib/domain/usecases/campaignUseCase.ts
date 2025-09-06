import { CampaignRepository } from '../repositories/campaignRepository';
import { Campaign } from '../models/campaign';

export class CampaignUseCase {
    private repository: CampaignRepository;

    constructor(repository: CampaignRepository) {
        this.repository = repository;
    }

    public async createCampaign(data: any): Promise<void> {
        return this.repository.createCampaign(data);
    }

    public async updateCampaign(id: string, data: any): Promise<void> {
        return this.repository.updateCampaign(id, data);
    }

    public async getAllCampaigns(type?: string, limit?: number): Promise<Campaign[]> {
        return this.repository.getAllCampaigns(type, limit);
    }

    public async getCampaignById(id: string): Promise<Campaign> {
        return this.repository.getCampaignById(id);
    }

    // TODO: getMyCampaigns 등 나머지 메서드 구현
}