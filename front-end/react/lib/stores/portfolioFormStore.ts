import { create } from 'zustand';
import { Portfolio } from '@/lib/domain/models/portfolio';
import { Live } from '@/lib/domain/models/live';
import { PortfolioUseCase } from '@/lib/domain/usecases/portfolioUseCase';
import { PortfolioRepository } from '@/lib/domain/repositories/portfolioRepository';

const portfolioUseCase = new PortfolioUseCase(new PortfolioRepository());

interface PortfolioFormState {
    isLoading: boolean;
    isSubmitting: boolean;
    editingPortfolioId: string | null;

    // Form fields
    mainThumbnailSource: File | string | null;
    backgroundImageSource: File | string | null;
    subThumbnailSources: (File | string)[];
    nickname: string;
    oneLineIntro: string;
    detailedIntro: string;
    experienceYears: number | null;
    age: number | null;
    mainLink: string;
    publicScope: string;
    isReceivingOffers: boolean;
    recentLives: Live[];
    tags: string[];

    // Actions
    setFormData: (data: Partial<PortfolioFormState>) => void;
    addImage: (type: 'main' | 'background', file: File) => void;
    addSubImage: (file: File) => void;
    removeSubImage: (index: number) => void;
    addRecentLive: () => void;
    removeRecentLive: (index: number) => void;
    addTag: (tag: string) => void;
    removeTag: (tag: string) => void;
    loadPortfolioForEdit: (id: string) => Promise<void>;
    submitForm: (status: string) => Promise<void>;
    resetForm: () => void;
}

const initialState = {
    isLoading: false,
    isSubmitting: false,
    editingPortfolioId: null,
    mainThumbnailSource: null,
    backgroundImageSource: null,
    subThumbnailSources: [],
    nickname: '',
    oneLineIntro: '',
    detailedIntro: '',
    experienceYears: null,
    age: null,
    mainLink: '',
    publicScope: '전체공개',
    isReceivingOffers: true,
    recentLives: [{ title: '', url: '', date: '' }],
    tags: [],
};

export const usePortfolioFormStore = create<PortfolioFormState>((set, get) => ({
    ...initialState,

    setFormData: (data) => set(data),
    resetForm: () => set(initialState),
    addImage: (type, file) => {
        if (type === 'main') {
            set({ mainThumbnailSource: file });
        } else {
            set({ backgroundImageSource: file });
        }
    },
    addSubImage: (file) => {
        if (get().subThumbnailSources.length < 5) {
            set((state) => ({ subThumbnailSources: [...state.subThumbnailSources, file] }));
        }
    },
    removeSubImage: (index) => {
        set((state) => ({ subThumbnailSources: state.subThumbnailSources.filter((_, i) => i !== index) }));
    },
    addRecentLive: () => {
        set((state) => ({ recentLives: [...state.recentLives, { title: '', url: '', date: '' }] }));
    },
    removeRecentLive: (index) => {
        set((state) => ({ recentLives: state.recentLives.filter((_, i) => i !== index) }));
    },
    addTag: (tag) => {
        if (tag.trim() && !get().tags.includes(tag.trim())) {
            set((state) => ({ tags: [...state.tags, tag.trim()] }));
        }
    },
    removeTag: (tag) => {
        set((state) => ({ tags: state.tags.filter((t) => t !== tag) }));
    },
    loadPortfolioForEdit: async (id) => {
        set({ isLoading: true, editingPortfolioId: id });
        try {
            const portfolio = await portfolioUseCase.getPortfolioById(id);
            set({
                mainThumbnailSource: portfolio.mainThumbnailUrl || null,
                backgroundImageSource: portfolio.backgroundImageUrl || null,
                subThumbnailSources: portfolio.subThumbnailUrls || [],
                nickname: portfolio.nickname || '',
                oneLineIntro: portfolio.oneLineIntro || '',
                detailedIntro: portfolio.detailedIntro || '',
                experienceYears: portfolio.experienceYears || null,
                age: portfolio.age || null,
                mainLink: portfolio.mainLink || '',
                publicScope: portfolio.publicScope || '전체공개',
                isReceivingOffers: portfolio.isReceivingOffers ?? true,
                recentLives: portfolio.recentLives?.length ? portfolio.recentLives : [{ title: '', url: '', date: '' }],
                tags: portfolio.tags || [],
                isLoading: false,
            });
        } catch (e) {
            console.error('Error loading portfolio:', e);
            set({ isLoading: false });
            throw e;
        }
    },
    submitForm: async (status) => {
        set({ isSubmitting: true });
        try {
            const state = get();
            const payload = {
                nickname: state.nickname,
                oneLineIntro: state.oneLineIntro,
                detailedIntro: state.detailedIntro,
                experienceYears: state.experienceYears,
                age: state.age,
                mainLink: state.mainLink,
                publicScope: state.publicScope,
                isReceivingOffers: state.isReceivingOffers,
                // TODO: 이미지 업로드 로직 추가
                mainThumbnailUrl: typeof state.mainThumbnailSource === 'string' ? state.mainThumbnailSource : null,
                backgroundImageUrl: typeof state.backgroundImageSource === 'string' ? state.backgroundImageSource : null,
                subThumbnailUrls: state.subThumbnailSources.filter((s): s is string => typeof s === 'string'),
                tags: state.tags,
                recentLives: state.recentLives.filter(live => live.title || live.url || live.date),
                status,
            };

            if (state.editingPortfolioId) {
                await portfolioUseCase.updatePortfolio(state.editingPortfolioId, payload);
            } else {
                await portfolioUseCase.createPortfolio(payload);
            }

            console.log('Form submitted successfully');
            set({ isSubmitting: false, editingPortfolioId: null });
            return Promise.resolve();
        } catch (e) {
            console.error('Form submission failed:', e);
            set({ isSubmitting: false });
            throw e;
        }
    },
}));