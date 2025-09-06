'use client';
import { usePortfolioFormStore } from '@/lib/stores/portfolioFormStore';
import { useRef } from 'react';
import { CloudinaryUploader } from '@/lib/data/cloudinaryUploader';

export default function PortfolioPreviewSection() {
    const { mainThumbnailSource, backgroundImageSource, setFormData, isLoading, setFormData: setLoading } = usePortfolioFormStore();
    const fileInputRefMain = useRef<HTMLInputElement>(null);
    const fileInputRefBg = useRef<HTMLInputElement>(null);

    const handleImagePick = async (type: 'main' | 'background', e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setLoading({ isLoading: true });
        try {
            const url = await new CloudinaryUploader().uploadImage(file);
            if (type === 'main') {
                setFormData({ mainThumbnailSource: url });
            } else {
                setFormData({ backgroundImageSource: url });
            }
        } catch (error) {
            alert(`이미지 업로드 실패: ${error}`);
        } finally {
            setLoading({ isLoading: false });
        }
    };

    const renderImagePreview = (source: string | File | null, isCircle = false) => {
        let imageUrl = '';
        if (source instanceof File) {
            imageUrl = URL.createObjectURL(source);
        } else if (typeof source === 'string') {
            imageUrl = source;
        }

        return (
            <div className={`w-full h-32 bg-gray-200 flex items-center justify-center overflow-hidden ${isCircle ? 'rounded-full' : 'rounded-lg'}`}>
                {imageUrl ? (
                    <img src={imageUrl} alt="Preview" className="w-full h-full object-cover" />
                ) : (
                    <span className="text-gray-500">이미지 미리보기</span>
                )}
            </div>
        );
    };

    return (
        <div className="flex space-x-4">
            <div className="flex-1">
                {renderImagePreview(mainThumbnailSource, true)}
                <input type="file" ref={fileInputRefMain} onChange={(e) => handleImagePick('main', e)} className="hidden" accept="image/*" />
                <button type="button" onClick={() => fileInputRefMain.current?.click()} className="mt-2 w-full py-2 bg-white border border-gray-300 rounded-lg text-gray-700 font-bold">
                    메인 썸네일
                </button>
            </div>
            <div className="flex-1">
                {renderImagePreview(backgroundImageSource)}
                <input type="file" ref={fileInputRefBg} onChange={(e) => handleImagePick('background', e)} className="hidden" accept="image/*" />
                <button type="button" onClick={() => fileInputRefBg.current?.click()} className="mt-2 w-full py-2 bg-white border border-gray-300 rounded-lg text-gray-700 font-bold">
                    배경 이미지
                </button>
            </div>
        </div>
    );
}