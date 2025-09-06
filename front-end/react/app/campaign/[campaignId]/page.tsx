'use client';

import { useQuery } from '@tanstack/react-query';
import { CampaignUseCase } from '@/lib/domain/usecases/campaignUseCase';
import { CampaignRepository } from '@/lib/domain/repositories/campaignRepository';
import DetailMetaCard from '@/components/campaign/DetailMetaCard';
import DetailProductCard from '@/components/campaign/DetailProductCard';
import DetailStickyBottomBar from '@/components/campaign/DetailStickyBottomBar';

interface CampaignDetailPageProps {
    params: { campaignId: string };
}

const campaignUseCase = new CampaignUseCase(new CampaignRepository());

export default function CampaignDetailPage({ params }: CampaignDetailPageProps) {
    const { campaignId } = params;

    const { data: campaign, isLoading, isError } = useQuery({
        queryKey: ['campaign', campaignId],
        queryFn: () => campaignUseCase.getCampaignById(campaignId),
    });

    if (isLoading) {
        return <div className="text-center py-12">로딩 중...</div>;
    }

    if (isError) {
        return <div className="text-center py-12 text-red-500">공고 정보를 찾을 수 없습니다.</div>;
    }

    if (!campaign) {
        return <div className="text-center py-12">공고 정보가 없습니다.</div>;
    }

    const getMetaItems = () => {
        if (campaign.type === 'recruit') {
            const feeText = campaign.fee ? `${(campaign.fee / 10000).toLocaleString()}만원` : '협의';
            return [
                { icon: '📅', label: '촬영일', value: campaign.liveTime?.substring(0, 10) || '미정' },
                { icon: '⏰', label: '시간', value: campaign.liveTime || '미정' },
                { icon: '📍', label: '장소', value: campaign.recruit?.location || '미정' },
                { icon: '💰', label: '출연료', value: feeText },
            ];
        } else if (campaign.type === 'product') {
            const price = campaign.products?.[0]?.salePrice || campaign.products?.[0]?.price;
            return [
                { icon: '📅', label: '라이브 날짜', value: campaign.liveTime?.substring(0, 10) || '미정' },
                { icon: '⏰', label: '라이브 시간', value: campaign.liveTime || '미정' },
                { icon: '🏷️', label: '판매가', value: `${price?.toLocaleString() || '미정'}원` },
                { icon: '📦', label: '카테고리', value: campaign.category || '미정' },
            ];
        }
        return [];
    };

    const renderProducts = () => {
        if (campaign.type === 'product' && campaign.products && campaign.products.length > 0) {
            return (
                <div className="mt-8">
                    <h2 className="text-lg font-bold">구성 상품</h2>
                    {campaign.products.map((product, index) => (
                        <DetailProductCard key={index} product={product} />
                    ))}
                </div>
            );
        }
        return null;
    };

    const getBottomBarProps = () => {
        let priceLabel = '';
        let buttonLabel = '';
        if (campaign.type === 'recruit') {
            priceLabel = campaign.fee ? `출연료 ${(campaign.fee / 10000).toLocaleString()}만원` : '출연료 협의';
            buttonLabel = '지원자 현황';
        } else if (campaign.type === 'product') {
            const price = campaign.products?.[0]?.salePrice || campaign.products?.[0]?.price;
            priceLabel = price ? `판매가 ${price.toLocaleString()}원` : '판매가 미정';
            buttonLabel = '상품 상세 보기';
        }
        return { priceLabel, buttonLabel };
    };

    const bottomBarProps = getBottomBarProps();

    return (
        <main className="bg-gray-50 min-h-screen pb-24">
            <div className="p-4">
                <img
                    src={campaign.coverImageUrl || `https://picsum.photos/seed/${campaign.id}/1280/720`}
                    alt={campaign.title || '캠페인 이미지'}
                    className="w-full h-48 object-cover rounded-xl shadow-sm mb-4"
                />
                <div className="bg-white p-6 rounded-xl shadow-sm">
                    <p className="text-sm text-gray-500">{campaign.brand || '브랜드 미정'}</p>
                    <h1 className="text-2xl font-bold mt-1">{campaign.title || '제목 없음'}</h1>
                    <div className="grid grid-cols-2 gap-4 mt-6">
                        {getMetaItems().map((item, index) => (
                            <DetailMetaCard key={index} icon={item.icon} label={item.label} value={item.value} />
                        ))}
                    </div>
                    {renderProducts()}
                    <div className="mt-8">
                        <h2 className="text-lg font-bold">상세 설명</h2>
                        <div className="prose max-w-none text-gray-700 mt-2" dangerouslySetInnerHTML={{ __html: campaign.descriptionHTML || '상세 설명이 없습니다.' }} />
                    </div>
                </div>
            </div>
            <DetailStickyBottomBar
                priceLabel={bottomBarProps.priceLabel}
                buttonLabel={bottomBarProps.buttonLabel}
                campaignId={campaignId}
            />
        </main>
    );
}