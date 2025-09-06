'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { CampaignUseCase } from '@/lib/domain/usecases/campaignUseCase';
import { CampaignRepository } from '@/lib/domain/repositories/campaignRepository';
import Link from 'next/link';

// 임시 리포지토리 및 유스케이스 인스턴스 생성
const campaignUseCase = new CampaignUseCase(new CampaignRepository());

// Flutter의 RecruitListScreen.dart에 있던 필터 목록
const filters = {
    'deadline': '⏳ 마감일 임박',
    'mukbang': '🍜 먹방 전용',
    'beauty': '💄 뷰티',
    'pay': '💸 출연료 미쳤다',
};

// D-day 계산 로직 (RecruitSection에서 재사용)
const calculateDday = (dateStr?: string) => {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    const today = new Date();
    const difference = Math.floor((date.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    if (difference < 0) return '마감';
    if (difference === 0) return 'D-DAY';
    return `D-${difference}`;
};

// 출연료 포맷팅 로직 (RecruitSection에서 재사용)
const formatFee = (fee?: number) => {
    if (fee && fee > 0) {
        return `${(fee / 10000).toLocaleString()}만원`;
    }
    return '협의';
};

export default function RecruitsPage() {
    const [activeFilter, setActiveFilter] = useState('deadline');

    // Flutter의 fetchRecruits() 및 applyFilter() 로직을 useQuery로 통합
    const { data: campaigns, isLoading, isError } = useQuery({
        queryKey: ['recruits', activeFilter],
        queryFn: async () => {
            const allCampaigns = await campaignUseCase.getAllCampaigns('recruit', 100);
            let filteredCampaigns = [...allCampaigns];

            // 필터링 및 정렬 로직
            switch (activeFilter) {
                case 'deadline':
                    filteredCampaigns.sort((a, b) => new Date(a.closeAt || '').getTime() - new Date(b.closeAt || '').getTime());
                    break;
                case 'mukbang':
                    filteredCampaigns = filteredCampaigns.filter(c =>
                        (c.title?.toLowerCase().includes('먹방') || c.category?.toLowerCase().includes('음식'))
                    );
                    break;
                case 'beauty':
                    filteredCampaigns = filteredCampaigns.filter(c =>
                        (c.title?.toLowerCase().includes('뷰티') || c.category?.toLowerCase().includes('뷰티'))
                    );
                    break;
                case 'pay':
                    filteredCampaigns.sort((a, b) => (b.fee || 0) - (a.fee || 0));
                    break;
            }

            return filteredCampaigns;
        },
    });

    return (
        <main className="min-h-screen bg-gray-50 p-4">
            <h1 className="text-2xl font-bold mb-4">공고 모아보기</h1>

            {/* 필터 탭 */}
            <div className="flex space-x-2 overflow-x-auto whitespace-nowrap mb-4">
                {Object.entries(filters).map(([key, value]) => (
                    <button
                        key={key}
                        onClick={() => setActiveFilter(key)}
                        className={`py-2 px-4 rounded-full font-bold text-sm transition-colors ${activeFilter === key ? 'bg-indigo-600 text-white' : 'bg-white text-gray-700 border border-gray-200'
                            }`}
                    >
                        {value}
                    </button>
                ))}
            </div>

            {/* 공고 목록 */}
            {isLoading && <div className="text-center py-8">로딩 중...</div>}
            {isError && <div className="text-center py-8 text-red-500">공고 로딩 실패</div>}
            {!isLoading && !isError && (!campaigns || campaigns.length === 0) && (
                <div className="text-center py-8 text-gray-500">조건에 맞는 공고가 아직 없어요.</div>
            )}

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {campaigns?.map((campaign) => (
                    <Link key={campaign.id} href={`/campaign/${campaign.id}`} className="block">
                        <div className="bg-white rounded-xl shadow-sm overflow-hidden border border-gray-200">
                            <img
                                src={campaign.coverImageUrl || `https://picsum.photos/seed/${campaign.id}/640/360`}
                                alt={campaign.title || '공고 이미지'}
                                className="w-full h-40 object-cover"
                            />
                            <div className="p-4">
                                <p className="text-xs text-gray-500">{campaign.brand || '브랜드 미정'}</p>
                                <h2 className="text-lg font-bold mt-1 truncate">{campaign.title || '제목 없음'}</h2>
                                <div className="flex items-center space-x-2 mt-2">
                                    {campaign.closeAt && (
                                        <span className="bg-red-100 text-red-700 text-xs font-bold py-1 px-2 rounded-full">
                                            {calculateDday(campaign.closeAt)}
                                        </span>
                                    )}
                                    <span className="text-sm text-gray-500">출연료 {formatFee(campaign.fee)}</span>
                                </div>
                            </div>
                        </div>
                    </Link>
                ))}
            </div>
        </main>
    );
}