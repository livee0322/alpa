'use client';

import { useCampaignFormStore } from '@/lib/stores/campaignFormStore';

export default function ProductUrlInputSection() {
    const { productUrl, addProductFromUrl, isLoading, setFormData } = useCampaignFormStore();

    const handleAddProduct = async () => {
        if (!productUrl.trim()) return;
        setFormData({ isLoading: true });
        try {
            await addProductFromUrl(productUrl);
            setFormData({ productUrl: '' });
            alert('상품을 추가했습니다.');
        } catch (e: any) {
            alert(`상품 불러오기 실패: ${e.message}`);
        } finally {
            setFormData({ isLoading: false });
        }
    };

    return (
        <div>
            <label className="block text-sm font-bold text-gray-700 mb-2">상품 등록</label>
            <div className="flex space-x-2">
                <input
                    type="text"
                    placeholder="네이버/쿠팡 등 상품 URL"
                    value={productUrl}
                    onChange={(e) => setFormData({ productUrl: e.target.value })}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                />
                <button
                    type="button"
                    onClick={handleAddProduct}
                    disabled={isLoading}
                    className={`px-6 py-3 rounded-lg font-bold transition-colors ${isLoading ? 'bg-gray-200 text-gray-500 cursor-not-allowed' : 'bg-gray-800 text-white hover:bg-gray-700'
                        }`}
                >
                    {isLoading ? '불러오는 중...' : '불러오기'}
                </button>
            </div>
        </div>
    );
}