import { create } from 'zustand';
import { AuthUseCase } from '../domain/usecases/authUseCase';
import { User } from '../domain/models/user';
import { AuthRepository } from '../domain/repositories/authRepository';

// 의존성 주입: AuthRepository 인스턴스 생성
const authRepository = new AuthRepository();
const authUseCase = new AuthUseCase(authRepository);

interface AuthState {
    isLoggedIn: boolean;
    user: User | null;
    role: string | null;
    login: (email: string, password: string) => Promise<void>;
    signup: (name: string, email: string, password: string, role: string) => Promise<void>;
    logout: () => void;
    checkAuthStatus: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
    isLoggedIn: false,
    user: null,
    role: null,

    login: async (email, password) => {
        try {
            const loggedInUser = await authUseCase.login(email, password);
            set({
                isLoggedIn: true,
                user: loggedInUser,
                role: loggedInUser.role,
            });
            console.log('Login successful');
        } catch (error) {
            console.error('Login failed:', error);
            throw error;
        }
    },

    signup: async (name, email, password, role) => {
        try {
            await authUseCase.signup(name, email, password, role);
            console.log('Signup successful');
        } catch (error) {
            console.error('Signup failed:', error);
            throw error;
        }
    },

    logout: () => {
        authUseCase.logout();
        set({
            isLoggedIn: false,
            user: null,
            role: null,
        });
        console.log('Logout successful');
    },

    checkAuthStatus: () => {
        const token = authUseCase.getAuthToken();
        const role = authUseCase.getUserRole();
        if (token && role) {
            set({
                isLoggedIn: true,
                role: role,
                // TODO: 사용자 정보(이름, 이메일 등)를 API에서 가져와서 user 상태 업데이트
                user: { name: '사용자', role: role },
            });
        }
    },
}));