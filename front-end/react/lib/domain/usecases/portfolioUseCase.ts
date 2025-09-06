import { PortfolioRepository } from '../repositories/portfolioRepository';
import { Portfolio } from '../models/portfolio';

export class PortfolioUseCase {
    private repository: PortfolioRepository;

    constructor(repository: PortfolioRepository) {
        this.repository = repository;
    }

    public async getAllPublicPortfolios(): Promise<Portfolio[]> {
        return this.repository.getAllPublicPortfolios();
    }

    public async getPortfolioById(id: string): Promise<Portfolio> {
        return this.repository.getPortfolioById(id);
    }
}