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

    public async getMyPortfolioList(): Promise<Portfolio[]> {
        try {
            const response = await apiClient.get<any>('/portfolios/my/list');
            const items = response.items || response.data?.items || response;
            return items.map((item: any) => item as Portfolio);
        } catch (e) {
            console.error('Failed to load my portfolio list:', e);
            throw new Error('Failed to load my portfolio list');
        }
    }

    public async deletePortfolio(id: string): Promise<void> {
        try {
            await apiClient.delete(`/portfolios/${id}`);
        } catch (e) {
            console.error(`Failed to delete portfolio with id ${id}:`, e);
            throw new Error('Failed to delete portfolio');
        }
    }
}