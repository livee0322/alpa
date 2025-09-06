'use client';

import { useCampaignFormStore } from '@/lib/stores/campaignFormStore';
import ProductUrlInputSection from './ProductUrlInputSection';
import ProductListSection from './ProductListSection';
import SaleAndLiveSection from './SaleAndLiveSection';

export default function ProductFormSection() {
    const { title, brand, category, description, setFormData } = useCampaignFormStore();

    const handleInputChange = (field: string, value: any) => {
        setFormData({ [field]: value });
    };

    return (
        <div className="space-y-4">
            <div className="flex space-x-4">
                <input
                    type="text"
                    placeholder="공개 제목 *"
                    value={title}
                    onChange={(e) => handleInputChange('title', e.target.value)}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
                <input
                    type="text"
                    placeholder="브랜드명"
                    value={brand}
                    onChange={(e) => handleInputChange('brand', e.target.value)}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
            </div>
            <ProductUrlInputSection />
            <ProductListSection />
            <SaleAndLiveSection />
            <input
                type="text"
                placeholder="상품군"
                value={category}
                onChange={(e) => handleInputChange('category', e.target.value)}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
            />
            <textarea
                placeholder="상세 설명 (HTML 가능)"
                value={description}
                onChange={(e) => handleInputChange('description', e.target.value)}
                rows={7}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
            />
        </div>
    );
}