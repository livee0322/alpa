'use client';
import { usePortfolioFormStore } from '@/lib/stores/portfolioFormStore';

export default function PortfolioBasicInfoSection() {
    const { nickname, oneLineIntro, detailedIntro, setFormData } = usePortfolioFormStore();
    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        const { name, value } = e.target;
        setFormData({ [name]: value });
    };

    return (
        <div className="space-y-4">
            <input
                type="text"
                name="nickname"
                placeholder="닉네임 *"
                value={nickname}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg"
            />
            <input
                type="text"
                name="oneLineIntro"
                placeholder="한 줄 소개 *"
                value={oneLineIntro}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg"
            />
            <textarea
                name="detailedIntro"
                placeholder="상세 소개 (자유)"
                rows={5}
                value={detailedIntro}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg"
            />
        </div>
    );
}