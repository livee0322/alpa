'use client';

import { useRef } from 'react';
import { CloudinaryUploader } from '@/lib/data/cloudinaryUploader';
import { useCampaignFormStore } from '@/lib/stores/campaignFormStore';

export default function ImagePickerSection() {
    const { imageUrl, setFormData, isLoading, setLoading } = useCampaignFormStore();
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleImagePick = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setLoading(true);
        try {
            const url = await new CloudinaryUploader().uploadImage(file);
            setFormData({ imageUrl: url });
        } catch (error) {
            alert(`이미지 업로드 실패: ${error}`);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div>
            <input
                type="file"
                ref={fileInputRef}
                onChange={handleImagePick}
                className="hidden"
                accept="image/*"
            />
            <div className="w-full h-40 bg-gray-200 rounded-lg flex items-center justify-center overflow-hidden mb-3">
                {imageUrl ? (
                    <img src={imageUrl} alt="Preview" className="w-full h-full object-cover" />
                ) : (
                    <span className="text-gray-500">이미지 미리보기</span>
                )}
            </div>
            <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                disabled={isLoading}
                className={`w-full py-3 rounded-lg font-bold transition-colors ${isLoading ? 'bg-gray-200 text-gray-500 cursor-not-allowed' : 'bg-gray-800 text-white hover:bg-gray-700'
                    }`}
            >
                {isLoading ? '업로드 중...' : '이미지 선택 및 업로드'}
            </button>
        </div>
    );
}