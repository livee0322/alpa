'use client';

import { useQuery } from '@tanstack/react-query';
import { CampaignUseCase } from '@/lib/domain/usecases/campaignUseCase';
import { CampaignRepository } from '@/lib/domain/repositories/campaignRepository';

const campaignUseCase = new CampaignUseCase(new CampaignRepository());

export default function ScheduleSection() {
    const { data, isLoading, isError } = useQuery({
        queryKey: ['schedule'],
        queryFn: () => campaignUseCase.getAllCampaigns('recruit', 6),
    });

    if (isLoading) {
        return <div className="text-center py-8">로딩 중...</div>;
    }

    if (isError) {
        return <div className="text-center py-8 text-red-500">일정 로딩 실패</div>;
    }

    if (!data || data.length === 0) {
        return (
            <div className="text-center py-8 border border-gray-200 rounded-lg text-gray-500 font-bold">
                예정된 일정이 없습니다.
            </div>
        );
    }

    return (
        <div className="space-y-3">
            {data.map((campaign) => (
                <div key={campaign.id} className="bg-white rounded-lg shadow-sm p-3 flex items-center space-x-3">
                    <img
                        src={campaign.coverImageUrl || `https://picsum.photos/seed/schedule${campaign.id}/96/96`}
                        alt={campaign.title || '이미지'}
                        className="w-12 h-12 rounded-lg object-cover"
                    />
                    <div className="flex-grow">
                        <p className="text-xs text-gray-500 font-bold">{campaign.brand || '브랜드 미정'}</p>
                        <p className="text-sm font-bold mt-1 truncate">{campaign.title || '제목 없음'}</p>
                        <p className="text-xs text-gray-500 mt-1">{campaign.liveTime || '시간 미정'}</p>
                    </div>
                </div>
            ))}
        </div>
    );
}