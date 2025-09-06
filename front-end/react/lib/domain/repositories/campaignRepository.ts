import { apiClient } from '../../apiClient';
import { Campaign } from '../models/campaign';

export class CampaignRepository {
    public async createCampaign(data: any): Promise<void> {
        try {
            await apiClient.post('/campaigns', data);
        } catch (e: any) {
            throw new Error(e.response?.data?.message || 'Failed to create campaign');
        }
    }

    public async updateCampaign(id: string, data: any): Promise<void> {
        try {
            await apiClient.put(`/campaigns/${id}`, data);
        } catch (e: any) {
            throw new Error(e.response?.data?.message || 'Failed to update campaign');
        }
    }

    public async getAllCampaigns(type?: string, limit?: number): Promise<Campaign[]> {
        const params = new URLSearchParams();
        if (type) params.append('type', type);
        if (limit) params.append('limit', limit.toString());

        try {
            const response = await apiClient.get<any>(`/campaigns?${params.toString()}`);
            // API 응답 구조에 따라 데이터 파싱
            const items = response.items || response.data?.items || response.docs || response.data?.docs || [];
            return items.map((e: any) => e as Campaign);
        } catch (error) {
            console.error('Failed to load all campaigns:', error);
            throw new Error('Failed to load all campaigns');
        }
    }

    public async getCampaignById(id: string): Promise<Campaign> {
        try {
            const response = await apiClient.get<any>(`/campaigns/${id}`);
            // API 응답 구조에 따라 데이터 파싱
            const data = response.data || response;
            return data as Campaign;
        } catch (error) {
            console.error(`Failed to load campaign with ID ${id}:`, error);
            throw new Error('Failed to load campaign details');
        }
    }

    // TODO: getMyCampaigns 등 나머지 메서드 구현
}