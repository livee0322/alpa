// lib/stores/campaignFormStore.ts

import { create } from 'zustand';
import { Campaign } from '@/lib/domain/models/campaign';
import { Product } from '@/lib/domain/models/product';
import { CampaignUseCase } from '@/lib/domain/usecases/campaignUseCase';
import { apiClient } from '../apiClient';
import { CampaignRepository } from '@/lib/domain/repositories/campaignRepository';

interface CampaignFormState {
    campaignType: 'product' | 'recruit';
    isLoading: boolean;
    isSubmitting: boolean;
    editingCampaign?: Campaign | null;
    // Common Fields
    internalTitle: string;
    imageUrl: string;
    // Product Campaign Fields
    title: string;
    productUrl: string;
    products: Product[];
    salePrice: number | null;
    saleDuration: string | null;
    liveDate: string;
    liveTime: string;
    brand: string;
    category: string;
    description: string;
    // Recruit Campaign Fields
    titleRecruit: string;
    dateRecruit: string;
    deadlineRecruit: string;
    timeStartRecruit: string;
    timeEndRecruit: string;
    locationRecruit: string;
    payWan: number | null;
    payNegotiable: boolean;
    categoryRecruit: string;
    descriptionRecruit: string;

    setCampaignType: (type: 'product' | 'recruit') => void;
    setLoading: (loading: boolean) => void;
    setPayNegotiable: (value: boolean) => void;
    setSaleDuration: (duration: string | null) => void;
    addProductFromUrl: (url: string) => Promise<void>;
    removeProduct: (index: number) => void;
    setFormData: (data: Partial<CampaignFormState>) => void;
    loadCampaignForEdit: (id: string) => Promise<void>;
    submitForm: () => Promise<void>;
    resetForm: () => void;
}

const initialState = {
    campaignType: 'product' as const,
    isLoading: false,
    isSubmitting: false,
    editingCampaign: null,
    internalTitle: '',
    imageUrl: '',
    title: '',
    productUrl: '',
    products: [],
    salePrice: null,
    saleDuration: null,
    liveDate: '',
    liveTime: '',
    brand: '',
    category: '',
    description: '',
    titleRecruit: '',
    dateRecruit: '',
    deadlineRecruit: '',
    timeStartRecruit: '',
    timeEndRecruit: '',
    locationRecruit: '',
    payWan: null,
    payNegotiable: false,
    categoryRecruit: '',
    descriptionRecruit: '',
};

const campaignUseCase = new CampaignUseCase(new CampaignRepository());

export const useCampaignFormStore = create<CampaignFormState>((set, get) => ({
    ...initialState,

    setCampaignType: (type) => set({ campaignType: type }),
    setLoading: (loading) => set({ isLoading: loading }),
    setPayNegotiable: (value) => set({ payNegotiable: value }),
    setSaleDuration: (duration) => set({ saleDuration: duration }),

    setFormData: (data) => set(data),
    resetForm: () => set(initialState),

    addProductFromUrl: async (url) => {
        try {
            const response = await apiClient.get<any>(`/scrape/product?url=${encodeURIComponent(url)}`);
            const productData = response.data || response;
            const newProduct: Product = {
                url: productData.url,
                title: productData.title,
                price: productData.price,
                salePrice: productData.salePrice,
                thumbnail: productData.thumbnail,
            };
            set((state) => ({ products: [...state.products, newProduct] }));
        } catch (e) {
            console.error('Failed to add product from URL:', e);
            throw e;
        }
    },

    removeProduct: (index) => {
        set((state) => ({ products: state.products.filter((_, i) => i !== index) }));
    },

    loadCampaignForEdit: async (id) => {
        set({ isLoading: true });
        try {
            const campaign = await campaignUseCase.getCampaignById(id);
            const stateUpdate: Partial<CampaignFormState> = {
                editingCampaign: campaign,
                campaignType: (campaign.type as 'product' | 'recruit') || 'product',
                imageUrl: campaign.coverImageUrl || '',
            };

            if (campaign.type === 'product') {
                stateUpdate.title = campaign.title || '';
                stateUpdate.products = campaign.products || [];
                // TODO: Map other product fields
            } else if (campaign.type === 'recruit') {
                stateUpdate.titleRecruit = campaign.title || '';
                stateUpdate.brand = campaign.brand || '';
                stateUpdate.dateRecruit = campaign.liveTime?.split('T')[0] || '';
                stateUpdate.deadlineRecruit = campaign.closeAt?.split('T')[0] || '';
                stateUpdate.timeStartRecruit = campaign.liveTime || '';
                stateUpdate.locationRecruit = campaign.recruit?.location || '';
                stateUpdate.payWan = campaign.fee || null;
                stateUpdate.payNegotiable = campaign.feeNegotiable || false;
                stateUpdate.categoryRecruit = campaign.category || '';
                stateUpdate.descriptionRecruit = campaign.descriptionHTML || '';
            }
            set({ ...stateUpdate, isLoading: false });
        } catch (e) {
            console.error('Error loading campaign for edit:', e);
            set({ isLoading: false });
            throw e;
        }
    },

    submitForm: async () => {
        set({ isSubmitting: true });
        try {
            const state = get();
            let payload: any;
            if (state.campaignType === 'product') {
                payload = {
                    type: 'product',
                    title: state.title,
                    coverImageUrl: state.imageUrl,
                    products: state.products.map(p => ({
                        url: p.url,
                        title: p.title,
                        price: p.price,
                        salePrice: p.salePrice,
                        thumbnail: p.thumbnail,
                    })),
                };
            } else { // recruit
                payload = {
                    type: 'recruit',
                    title: state.titleRecruit,
                    coverImageUrl: state.imageUrl,
                    brand: state.brand,
                    recruit: {
                        shootDate: state.dateRecruit,
                        applyDeadline: state.deadlineRecruit,
                        startAt: state.timeStartRecruit,
                        endAt: state.timeEndRecruit,
                        location: state.locationRecruit,
                        fee: state.payWan,
                        isNegotiable: state.payNegotiable,
                        category: state.categoryRecruit,
                        description: state.descriptionRecruit,
                    },
                };
            }

            const campaignId = state.editingCampaign?.id;
            if (campaignId) {
                await campaignUseCase.updateCampaign(campaignId, payload);
            } else {
                await campaignUseCase.createCampaign(payload);
            }

            console.log('Form submitted successfully');
            set({ isSubmitting: false });
            return Promise.resolve();
        } catch (e) {
            console.error('Form submission failed:', e);
            set({ isSubmitting: false });
            throw e;
        }
    },
}));