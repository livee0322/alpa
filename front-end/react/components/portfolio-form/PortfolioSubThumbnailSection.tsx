'use client';
import { usePortfolioFormStore } from '@/lib/stores/portfolioFormStore';
import { useRef } from 'react';
import { CloudinaryUploader } from '@/lib/data/cloudinaryUploader';

export default function PortfolioSubThumbnailSection() {
    const { subThumbnailSources, isLoading, setFormData, setFormData: setLoading } = usePortfolioFormStore();
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleImagePick = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setLoading({ isLoading: true });
        try {
            const url = await new CloudinaryUploader().uploadImage(file);
            setFormData({ subThumbnailSources: [...subThumbnailSources, url] });
        } catch (error) {
            alert(`이미지 업로드 실패: ${error}`);
        } finally {
            setLoading({ isLoading: false });
        }
    };

    const handleRemoveImage = (index: number) => {
        const newSources = subThumbnailSources.filter((_, i) => i !== index);
        setFormData({ subThumbnailSources: newSources });
    };

    return (
        <div>
            <div className="grid grid-cols-3 gap-2">
                {subThumbnailSources.map((source, index) => (
                    <div key={index} className="relative aspect-w-1 aspect-h-1 rounded-lg overflow-hidden">
                        <img src={typeof source === 'string' ? source : URL.createObjectURL(source)} alt="Sub Thumbnail" className="w-full h-full object-cover" />
                        <button onClick={() => handleRemoveImage(index)} className="absolute top-1 right-1 bg-black bg-opacity-50 text-white rounded-full p-1">
                            &times;
                        </button>
                    </div>
                ))}
                {subThumbnailSources.length < 5 && (
                    <div className="aspect-w-1 aspect-h-1 rounded-lg border-2 border-dashed border-gray-300 flex items-center justify-center cursor-pointer" onClick={() => fileInputRef.current?.click()}>
                        <input type="file" ref={fileInputRef} onChange={handleImagePick} className="hidden" accept="image/*" />
                        <span className="text-gray-500 text-2xl">+</span>
                    </div>
                )}
            </div>
            <p className="text-sm text-gray-500 mt-2">선택, 최대 5개</p>
        </div>
    );
}