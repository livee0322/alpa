import axios, { AxiosInstance, AxiosRequestConfig } from 'axios';

const API_BASE = 'https://main-server-ekgr.onrender.com/api/v1';

class ApiClient {
    private axiosInstance: AxiosInstance;

    constructor() {
        this.axiosInstance = axios.create({
            baseURL: API_BASE,
            headers: {
                'Content-Type': 'application/json',
            },
        });

        this.axiosInstance.interceptors.request.use(async (config) => {
            // TODO: 로컬 스토리지에서 토큰을 가져와 헤더에 추가하는 로직 구현
            const token = localStorage.getItem('liveeToken');
            if (token) {
                config.headers.Authorization = `Bearer ${token}`;
            }
            return config;
        });
    }

    public async get<T>(path: string, config?: AxiosRequestConfig): Promise<T> {
        const response = await this.axiosInstance.get<T>(path, config);
        return response.data;
    }

    public async post<T>(path: string, body: any, config?: AxiosRequestConfig): Promise<T> {
        const response = await this.axiosInstance.post<T>(path, body, config);
        return response.data;
    }

    public async put<T>(path: string, body: any, config?: AxiosRequestConfig): Promise<T> {
        const response = await this.axiosInstance.put<T>(path, body, config);
        return response.data;
    }

    public async delete<T>(path: string, config?: AxiosRequestConfig): Promise<T> {
        const response = await this.axiosInstance.delete<T>(path, config);
        return response.data;
    }
}

export const apiClient = new ApiClient();