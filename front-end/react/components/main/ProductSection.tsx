'use client';

import Link from 'next/link';
import { useQuery } from '@tanstack/react-query';
import { CampaignUseCase } from '@/lib/domain/usecases/campaignUseCase';
import { CampaignRepository } from '@/lib/domain/repositories/campaignRepository';

const campaignUseCase = new CampaignUseCase(new CampaignRepository());

export default function ProductSection() {
    const { data, isLoading, isError } = useQuery({
        queryKey: ['products'],
        queryFn: () => campaignUseCase.getAllCampaigns('product', 10),
    });

    if (isLoading) {
        return <div className="text-center py-8">로딩 중...</div>;
    }

    if (isError) {
        return <div className="text-center py-8 text-red-500">상품 공고 로딩 실패</div>;
    }

    if (!data || data.length === 0) {
        return <div className="text-center py-8 text-gray-500">등록된 상품 공고가 없습니다.</div>;
    }

    return (
        <div className="grid grid-cols-2 gap-4">
            {data.map((campaign) => {
                const product = campaign.products?.[0];
                return (
                    <Link key={campaign.id} href={`/campaign/${campaign.id}`} className="block">
                        <div className="bg-white rounded-xl overflow-hidden shadow-sm">
                            <div className="aspect-w-1 aspect-h-1">
                                <img
                                    src={campaign.coverImageUrl || `https://picsum.photos/seed/${campaign.id}/300/300`}
                                    alt={campaign.title || '상품 이미지'}
                                    className="w-full h-full object-cover"
                                />
                            </div>
                            <div className="p-3">
                                <p className="text-xs text-gray-400 truncate">{campaign.brand || '브랜드 미정'}</p>
                                <p className="font-semibold text-gray-800 mt-1 truncate">{campaign.title || '상품명 미정'}</p>
                                <p className="font-extrabold text-sm text-gray-900 mt-2">{product?.price?.toLocaleString() || '가격 미정'}</p>
                            </div>
                        </div>
                    </Link>
                );
            })}
        </div>
    );
}