import { apiClient } from '../../apiClient';
import { User } from '../models/user';

export class AuthRepository {
    public async login(email: string, password: string): Promise<User> {
        try {
            const response = await apiClient.post<User>('/users/login', { email, password });
            if (response.token && response.role) {
                localStorage.setItem('liveeToken', response.token);
                localStorage.setItem('liveeRole', response.role);
            }
            return response;
        } catch (e: any) {
            throw new Error(e.response?.data?.message || '로그인 실패');
        }
    }

    public async signup(name: string, email: string, password: string, role: string): Promise<User> {
        try {
            const response = await apiClient.post<User>('/users/signup', { name, email, password, role });
            return response;
        } catch (e: any) {
            throw new Error(e.response?.data?.message || '회원가입 실패');
        }
    }

    public async logout(): Promise<void> {
        localStorage.removeItem('liveeToken');
        localStorage.removeItem('liveeRole');
    }

    public getAuthToken(): string | null {
        return localStorage.getItem('liveeToken');
    }

    public getUserRole(): string | null {
        return localStorage.getItem('liveeRole');
    }
}