import { AuthRepository } from '../repositories/authRepository';
import { User } from '../models/user';

export class AuthUseCase {
    private repository: AuthRepository;

    constructor(repository: AuthRepository) {
        this.repository = repository;
    }

    public async login(email: string, password: string): Promise<User> {
        return this.repository.login(email, password);
    }

    public async signup(name: string, email: string, password: string, role: string): Promise<User> {
        return this.repository.signup(name, email, password, role);
    }

    public async logout(): Promise<void> {
        return this.repository.logout();
    }

    public getAuthToken(): string | null {
        return this.repository.getAuthToken();
    }

    public getUserRole(): string | null {
        return this.repository.getUserRole();
    }
}