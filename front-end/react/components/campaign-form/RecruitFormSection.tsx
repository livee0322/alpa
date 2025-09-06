'use client';

import { useCampaignFormStore } from '@/lib/stores/campaignFormStore';
import { useState, ChangeEvent } from 'react';

export default function RecruitFormSection() {
    const {
        titleRecruit,
        brand,
        descriptionRecruit,
        categoryRecruit,
        locationRecruit,
        dateRecruit,
        deadlineRecruit,
        timeStartRecruit,
        timeEndRecruit,
        payWan,
        payNegotiable,
        setFormData,
        setPayNegotiable,
    } = useCampaignFormStore();

    const handleInputChange = (field: string, value: any) => {
        setFormData({ [field]: value });
    };

    return (
        <div className="space-y-4">
            <div className="flex space-x-4">
                <input
                    type="text"
                    placeholder="브랜드명 *"
                    value={brand}
                    onChange={(e) => handleInputChange('brand', e.target.value)}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
                <input
                    type="text"
                    placeholder="제목 *"
                    value={titleRecruit}
                    onChange={(e) => handleInputChange('titleRecruit', e.target.value)}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
            </div>
            <textarea
                placeholder="내용(브리프) *"
                value={descriptionRecruit}
                onChange={(e) => handleInputChange('descriptionRecruit', e.target.value)}
                rows={5}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
            />
            <select
                value={categoryRecruit}
                onChange={(e) => handleInputChange('categoryRecruit', e.target.value)}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
            >
                <option value="">카테고리 선택</option>
                <option value="뷰티">뷰티</option>
                <option value="패션">패션</option>
                <option value="식품">식품</option>
                <option value="가전">가전</option>
                <option value="생활/리빙">생활/리빙</option>
            </select>
            <input
                type="text"
                placeholder="장소 (선택)"
                value={locationRecruit}
                onChange={(e) => handleInputChange('locationRecruit', e.target.value)}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
            />
            <div className="flex space-x-4">
                <input
                    type="date"
                    placeholder="촬영일 *"
                    value={dateRecruit}
                    onChange={(e) => handleInputChange('dateRecruit', e.target.value)}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
                <input
                    type="date"
                    placeholder="마감일 *"
                    value={deadlineRecruit}
                    onChange={(e) => handleInputChange('deadlineRecruit', e.target.value)}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
            </div>
            <div className="flex space-x-4">
                <input
                    type="time"
                    placeholder="시작 *"
                    value={timeStartRecruit}
                    onChange={(e) => handleInputChange('timeStartRecruit', e.target.value)}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
                <input
                    type="time"
                    placeholder="종료 *"
                    value={timeEndRecruit}
                    onChange={(e) => handleInputChange('timeEndRecruit', e.target.value)}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
            </div>
            <input
                type="number"
                placeholder="출연료 (원)"
                value={payWan || ''}
                onChange={(e) => handleInputChange('payWan', e.target.value ? parseInt(e.target.value) : null)}
                disabled={payNegotiable}
                className={`w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500 ${payNegotiable ? 'bg-gray-100' : ''}`}
            />
            <div className="flex items-center space-x-2">
                <input
                    type="checkbox"
                    checked={payNegotiable}
                    onChange={(e) => setPayNegotiable(e.target.checked)}
                    className="h-4 w-4 text-indigo-600 rounded"
                />
                <label className="text-gray-700 text-sm">협의 가능 (체크 시 출연료 입력 비활성화)</label>
            </div>
        </div>
    );
}