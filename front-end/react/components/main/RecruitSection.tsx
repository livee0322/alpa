'use client';

import { useQuery } from '@tanstack/react-query';
import { CampaignUseCase } from '@/lib/domain/usecases/campaignUseCase';
import { CampaignRepository } from '@/lib/domain/repositories/campaignRepository';
import Link from 'next/link';

const campaignUseCase = new CampaignUseCase(new CampaignRepository());

export default function RecruitSection() {
    const { data, isLoading, isError } = useQuery({
        queryKey: ['recruits'],
        queryFn: () => campaignUseCase.getAllCampaigns('recruit', 10),
    });

    const calculateDday = (dateStr?: string) => {
        if (!dateStr) return '';
        const date = new Date(dateStr);
        const today = new Date();
        const difference = Math.floor((date.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
        if (difference < 0) return '마감';
        if (difference === 0) return 'D-DAY';
        return `D-${difference}`;
    };

    const formatFee = (fee?: number) => {
        if (fee && fee > 0) {
            return `${(fee / 10000).toLocaleString()}만원`;
        }
        return '협의';
    };

    if (isLoading) {
        return <div className="text-center py-8">로딩 중...</div>;
    }

    if (isError) {
        return <div className="text-center py-8 text-red-500">모집 공고 로딩 실패</div>;
    }

    if (!data || data.length === 0) {
        return <div className="text-center py-8 text-gray-500">등록된 공고가 없습니다.</div>;
    }

    return (
        <div className="space-y-3">
            {data.map((campaign) => (
                <Link key={campaign.id} href={`/campaign/${campaign.id}`} className="block">
                    <div className="bg-white rounded-xl shadow-sm overflow-hidden p-4 flex items-center space-x-4">
                        <div className="flex-grow">
                            <p className="text-xs text-gray-500">{campaign.brand || '브랜드 미정'}</p>
                            <p className="font-bold text-gray-900 mt-1 truncate">{campaign.title || '제목 없음'}</p>
                            <div className="flex items-center space-x-2 mt-2">
                                <span className="bg-red-100 text-red-700 text-xs font-bold py-1 px-2 rounded-full">
                                    {calculateDday(campaign.closeAt)}
                                </span>
                                <span className="text-sm text-gray-500">출연료 {formatFee(campaign.fee)}</span>
                            </div>
                        </div>
                        <img
                            src={campaign.coverImageUrl || `https://picsum.photos/seed/recruit${campaign.id}/112/112`}
                            alt={campaign.title || '공고 이미지'}
                            className="w-14 h-14 rounded-lg object-cover"
                        />
                    </div>
                </Link>
            ))}
        </div>
    );
}