'use client';

import { useCampaignFormStore } from '@/lib/stores/campaignFormStore';

export default function CampaignTypeSelector() {
    const { campaignType, setCampaignType } = useCampaignFormStore();

    const buildTypeButton = (type: 'product' | 'recruit', label: string) => {
        const isSelected = campaignType === type;
        return (
            <button
                type="button"
                onClick={() => setCampaignType(type)}
                className={`flex-1 px-4 py-3 rounded-lg text-center font-bold transition-colors ${isSelected
                        ? 'bg-indigo-600 text-white'
                        : 'bg-gray-100 text-gray-700'
                    }`}
            >
                {label}
            </button>
        );
    };

    return (
        <div className="flex space-x-2">
            {buildTypeButton('product', '상품 공고')}
            {buildTypeButton('recruit', '쇼호스트 모집')}
        </div>
    );
}