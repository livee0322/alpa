'use client';

import { useCampaignFormStore } from '@/lib/stores/campaignFormStore';

export default function ProductListSection() {
    const { products, removeProduct } = useCampaignFormStore();

    return (
        <div className="my-4">
            {products.length === 0 ? (
                <div className="p-4 border border-gray-300 rounded-lg text-center text-gray-500">
                    아직 등록된 상품이 없습니다.
                </div>
            ) : (
                <ul className="space-y-2">
                    {products.map((product, index) => (
                        <li key={index} className="bg-gray-50 p-3 rounded-lg flex items-center space-x-3">
                            <img
                                src={product.thumbnail || `https://picsum.photos/seed/${product.title}/64/64`}
                                alt={product.title || '상품 이미지'}
                                className="w-16 h-16 rounded-lg object-cover"
                            />
                            <div className="flex-1">
                                <p className="font-semibold">{product.title}</p>
                                <p className="text-sm text-gray-500">{product.price?.toLocaleString()}원</p>
                            </div>
                            <button type="button" onClick={() => removeProduct(index)} className="text-red-500">
                                삭제
                            </button>
                        </li>
                    ))}
                </ul>
            )}
        </div>
    );
}