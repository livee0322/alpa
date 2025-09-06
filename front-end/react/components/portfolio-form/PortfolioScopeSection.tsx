'use client';
import { usePortfolioFormStore } from '@/lib/stores/portfolioFormStore';
import React from 'react';

export default function PortfolioScopeSection() {
    const { publicScope, isReceivingOffers, setFormData } = usePortfolioFormStore();
    return (
        <div className="space-y-4">
            <select
                value={publicScope}
                onChange={(e) => setFormData({ publicScope: e.target.value })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg"
            >
                <option value="전체공개">전체공개</option>
                <option value="링크 공개">링크 공개</option>
                <option value="비공개">비공개</option>
            </select>
            <div className="flex items-center">
                <input
                    type="checkbox"
                    checked={isReceivingOffers}
                    onChange={(e) => setFormData({ isReceivingOffers: e.target.checked })}
                    className="h-4 w-4 text-indigo-600 rounded"
                />
                <label className="ml-2 text-gray-700">제안 받기</label>
            </div>
        </div>
    );
}