'use client';

import { useCampaignFormStore } from '@/lib/stores/campaignFormStore';
import React, { ChangeEvent } from 'react';

export default function SaleAndLiveSection() {
    const { liveDate, liveTime, salePrice, saleDuration, setFormData, setSaleDuration } = useCampaignFormStore();

    const handleInputChange = (e: ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
        setFormData({ [name]: value });
    };

    return (
        <div className="space-y-4">
            {/* 할인 정보 */}
            <div className="flex space-x-4">
                <input
                    type="number"
                    name="salePrice"
                    placeholder="공통 할인가(선택)"
                    value={salePrice || ''}
                    onChange={handleInputChange}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
                <select
                    name="saleDuration"
                    value={saleDuration || ''}
                    onChange={(e) => setSaleDuration(e.target.value || null)}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                >
                    <option value="">할인 유지시간</option>
                    <option value="3600">1시간</option>
                    <option value="7200">2시간</option>
                    <option value="10800">3시간 (최대)</option>
                </select>
            </div>

            {/* 라이브 일정 */}
            <div className="flex space-x-4">
                <input
                    type="date"
                    name="liveDate"
                    placeholder="라이브 날짜"
                    value={liveDate}
                    onChange={handleInputChange}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
                <input
                    type="time"
                    name="liveTime"
                    placeholder="라이브 시간"
                    value={liveTime}
                    onChange={handleInputChange}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
            </div>
        </div>
    );
}