'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { CampaignUseCase } from '@/lib/domain/usecases/campaignUseCase';
import { CampaignRepository } from '@/lib/domain/repositories/campaignRepository';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

const campaignUseCase = new CampaignUseCase(new CampaignRepository());

export default function CampaignsPage() {
    const queryClient = useQueryClient();
    const router = useRouter();

    // 목록 조회
    const { data: campaigns, isLoading, isError } = useQuery({
        queryKey: ['myCampaigns'],
        queryFn: () => campaignUseCase.getMyCampaigns(),
    });

    // 삭제 뮤테이션
    const deleteMutation = useMutation({
        mutationFn: (id: string) => campaignUseCase.deleteCampaign(id),
        onSuccess: () => {
            alert('공고가 삭제되었습니다.');
            queryClient.invalidateQueries({ queryKey: ['myCampaigns'] });
        },
        onError: (error) => {
            alert(`삭제 실패: ${error.message}`);
        },
    });

    const handleDelete = async (id: string) => {
        if (window.confirm('이 공고를 삭제하시겠어요?')) {
            deleteMutation.mutate(id);
        }
    };

    if (isLoading) {
        return <div className="text-center py-12">로딩 중...</div>;
    }

    if (isError) {
        return <div className="text-center py-12 text-red-500">에러: 공고를 불러올 수 없습니다.</div>;
    }

    if (!campaigns || campaigns.length === 0) {
        return (
            <div className="text-center py-12 text-gray-500">
                <p>등록된 공고가 없습니다.</p>
                <Link href="/campaign-form" className="mt-4 inline-block text-indigo-600 font-bold">
                    + 공고 등록하기
                </Link>
            </div>
        );
    }

    return (
        <main className="min-h-screen bg-gray-50 p-4">
            <div className="flex justify-between items-center mb-4">
                <h1 className="text-2xl font-bold">공고 관리</h1>
                <Link href="/campaign-form" className="bg-indigo-600 text-white py-2 px-4 rounded-lg font-bold">
                    + 등록
                </Link>
            </div>

            <div className="space-y-4">
                {campaigns.map((campaign) => (
                    <div key={campaign.id} className="bg-white rounded-xl shadow-sm overflow-hidden border border-gray-200">
                        <Link href={`/campaign/${campaign.id}`} className="block p-4">
                            <div className="flex items-center space-x-4">
                                <img
                                    src={campaign.coverImageUrl || `https://picsum.photos/seed/${campaign.id}/120/68`}
                                    alt="캠페인 썸네일"
                                    className="w-32 h-20 object-cover rounded-lg"
                                />
                                <div className="flex-1">
                                    <h2 className="text-lg font-bold truncate">{campaign.title || '제목 없음'}</h2>
                                    <p className="text-sm text-gray-500 mt-1">유형: {campaign.type}</p>
                                </div>
                                <div className="flex space-x-2">
                                    <button
                                        onClick={(e) => {
                                            e.preventDefault();
                                            router.push(`/campaign-form?id=${campaign.id}`);
                                        }}
                                        className="text-gray-500 hover:text-gray-900"
                                    >
                                        수정
                                    </button>
                                    <button
                                        onClick={(e) => {
                                            e.preventDefault();
                                            handleDelete(campaign.id!);
                                        }}
                                        disabled={deleteMutation.isPending}
                                        className="text-red-500 hover:text-red-700"
                                    >
                                        삭제
                                    </button>
                                </div>
                            </div>
                        </Link>
                        <div className="border-t border-gray-200 mt-4">
                            <Link href={`/campaign/${campaign.id}/applicants`} className="block text-center py-3 text-indigo-600 font-bold hover:bg-gray-50">
                                지원자 현황 보기
                            </Link>
                        </div>
                    </div>
                ))}
            </div>
        </main>
    );
}