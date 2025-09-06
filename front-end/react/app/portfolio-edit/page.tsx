'use client';

import { useEffect, useRef } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import FormSectionContainer from '@/components/campaign-form/FormSectionContainer';
import PortfolioPreviewSection from '@/components/portfolio-form/PortfolioPreviewSection';
import PortfolioSubThumbnailSection from '@/components/portfolio-form/PortfolioSubThumbnailSection';
import PortfolioBasicInfoSection from '@/components/portfolio-form/PortfolioBasicInfoSection';
import PortfolioExperienceSection from '@/components/portfolio-form/PortfolioExperienceSection';
import PortfolioScopeSection from '@/components/portfolio-form/PortfolioScopeSection';
import PortfolioRecentLiveSection from '@/components/portfolio-form/PortfolioRecentLiveSection';
import PortfolioTagsSection from '@/components/portfolio-form/PortfolioTagsSection';
import { usePortfolioFormStore } from '@/lib/stores/portfolioFormStore';
import Link from 'next/link';

export default function PortfolioEditPage() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const portfolioId = searchParams.get('id');

    const {
        isLoading,
        isSubmitting,
        nickname,
        oneLineIntro,
        submitForm,
        loadPortfolioForEdit,
        resetForm,
        setFormData,
    } = usePortfolioFormStore();

    const formRef = useRef<HTMLFormElement>(null);

    useEffect(() => {
        resetForm();
        if (portfolioId) {
            loadPortfolioForEdit(portfolioId);
        }
    }, [portfolioId, loadPortfolioForEdit, resetForm]);

    const handleSubmit = async (status: 'published' | 'draft') => {
        // TODO: 클라이언트 측 유효성 검사 로직 추가
        if (!nickname || !oneLineIntro) {
            alert('닉네임과 한 줄 소개는 필수 항목입니다.');
            return;
        }

        try {
            await submitForm(status);
            alert(`포트폴리오가 성공적으로 ${status === 'published' ? '발행' : '임시 저장'}되었습니다.`);
            router.push('/my-portfolios');
        } catch (e: any) {
            alert(`저장 실패: ${e.message}`);
        }
    };

    return (
        <main className="p-4 bg-gray-50 min-h-screen">
            <h1 className="text-2xl font-bold mb-6">포트폴리오 등록</h1>
            {isLoading ? (
                <div className="text-center py-12">데이터를 불러오는 중...</div>
            ) : (
                <form ref={formRef} className="space-y-6">
                    <FormSectionContainer title="미리보기">
                        <PortfolioPreviewSection />
                    </FormSectionContainer>

                    <FormSectionContainer title="서브 썸네일">
                        <PortfolioSubThumbnailSection />
                    </FormSectionContainer>

                    <FormSectionContainer title="기본 정보">
                        <PortfolioBasicInfoSection />
                    </FormSectionContainer>

                    <FormSectionContainer title="상세 정보">
                        <PortfolioExperienceSection />
                        <div className="mt-4">
                            <input
                                type="text"
                                placeholder="대표 링크"
                                value={usePortfolioFormStore.getState().mainLink}
                                onChange={(e) => setFormData({ mainLink: e.target.value })}
                                className="w-full px-4 py-3 border border-gray-300 rounded-lg"
                            />
                        </div>
                    </FormSectionContainer>

                    <FormSectionContainer title="공개 범위">
                        <PortfolioScopeSection />
                    </FormSectionContainer>

                    <FormSectionContainer title="최근 라이브 링크">
                        <PortfolioRecentLiveSection />
                    </FormSectionContainer>

                    <FormSectionContainer title="태그">
                        <PortfolioTagsSection />
                    </FormSectionContainer>

                    <div className="flex justify-end space-x-2 mt-8">
                        <button
                            type="button"
                            onClick={() => handleSubmit('draft')}
                            disabled={isSubmitting}
                            className="py-3 px-6 rounded-lg text-gray-700 font-bold"
                        >
                            임시 저장
                        </button>
                        <button
                            type="button"
                            onClick={() => handleSubmit('published')}
                            disabled={isSubmitting}
                            className={`py-3 px-6 rounded-lg font-bold text-white transition-colors ${isSubmitting ? 'bg-gray-400 cursor-not-allowed' : 'bg-indigo-600 hover:bg-indigo-700'
                                }`}
                        >
                            {isSubmitting ? '저장 중...' : '발행'}
                        </button>
                    </div>
                </form>
            )}
        </main>
    );
}