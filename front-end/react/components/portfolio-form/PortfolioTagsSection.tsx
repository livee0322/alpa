'use client';
import { usePortfolioFormStore } from '@/lib/stores/portfolioFormStore';
import { useState } from 'react';

export default function PortfolioTagsSection() {
    const { tags, addTag, removeTag } = usePortfolioFormStore();
    const [tagInput, setTagInput] = useState('');

    const handleAddTag = () => {
        if (tagInput.trim()) {
            addTag(tagInput);
            setTagInput('');
        }
    };

    return (
        <div className="space-y-4">
            <div className="flex">
                <input
                    type="text"
                    placeholder="태그 입력 후 Enter"
                    value={tagInput}
                    onChange={(e) => setTagInput(e.target.value)}
                    onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                            e.preventDefault();
                            handleAddTag();
                        }
                    }}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg"
                />
                <button type="button" onClick={handleAddTag} className="ml-2 px-4 py-3 bg-gray-800 text-white rounded-lg font-bold">
                    추가
                </button>
            </div>
            {tags.length > 0 && (
                <div className="flex flex-wrap gap-2">
                    {tags.map((tag, index) => (
                        <div key={index} className="bg-gray-100 text-gray-700 px-3 py-1 rounded-full flex items-center space-x-1">
                            <span>{tag}</span>
                            <button type="button" onClick={() => removeTag(tag)} className="text-sm text-red-500">
                                &times;
                            </button>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}