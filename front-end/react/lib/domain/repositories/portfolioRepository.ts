import { apiClient } from '../../apiClient';
import { Portfolio } from '../models/portfolio';

export class PortfolioRepository {
    public async getAllPublicPortfolios(): Promise<Portfolio[]> {
        try {
            const response = await apiClient.get<any>('/portfolio/all');
            return response.map((item: any) => item as Portfolio);
        } catch (e) {
            console.error('Failed to fetch all public portfolios:', e);
            throw new Error('Failed to load showhosts');
        }
    }

    public async getPortfolioById(id: string): Promise<Portfolio> {
        try {
            const response = await apiClient.get<any>(`/portfolios/${id}`);
            const data = response.data || response;
            return data as Portfolio;
        } catch (e) {
            console.error(`Failed to fetch portfolio with id ${id}:`, e);
            throw new Error('Failed to load showhost details');
        }
    }

    // TODO: getMyPortfolioList 등 나머지 메서드 구현
}