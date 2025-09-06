'use client';
import { usePortfolioFormStore } from '@/lib/stores/portfolioFormStore';
import React from 'react';

export default function PortfolioRecentLiveSection() {
    const { recentLives, addRecentLive, removeRecentLive, setFormData } = usePortfolioFormStore();

    const handleInputChange = (index: number, e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
        const newLives = [...recentLives];
        newLives[index] = { ...newLives[index], [name]: value };
        setFormData({ recentLives: newLives });
    };

    return (
        <div className="space-y-4">
            {recentLives.map((live, index) => (
                <div key={index} className="p-4 border border-gray-300 rounded-lg relative">
                    <input
                        type="text"
                        name="title"
                        placeholder="제목"
                        value={live.title || ''}
                        onChange={(e) => handleInputChange(index, e)}
                        className="w-full px-2 py-1 mb-2 border border-gray-200 rounded-lg"
                    />
                    <div className="flex space-x-2">
                        <input
                            type="text"
                            name="url"
                            placeholder="링크"
                            value={live.url || ''}
                            onChange={(e) => handleInputChange(index, e)}
                            className="flex-1 px-2 py-1 border border-gray-200 rounded-lg"
                        />
                        <input
                            type="text"
                            name="date"
                            placeholder="날짜"
                            value={live.date || ''}
                            onChange={(e) => handleInputChange(index, e)}
                            className="flex-1 px-2 py-1 border border-gray-200 rounded-lg"
                        />
                    </div>
                    {recentLives.length > 1 && (
                        <button type="button" onClick={() => removeRecentLive(index)} className="absolute top-1 right-1 text-red-500">
                            &times;
                        </button>
                    )}
                </div>
            ))}
            <button type="button" onClick={addRecentLive} className="w-full py-2 border border-gray-300 rounded-lg text-gray-700 font-bold">
                + 추가
            </button>
        </div>
    );
}