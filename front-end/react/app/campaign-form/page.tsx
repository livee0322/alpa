'use client';

import { useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import FormSectionContainer from '@/components/campaign-form/FormSectionContainer';
import ImagePickerSection from '@/components/campaign-form/ImagePickerSection';
import CampaignTypeSelector from '@/components/campaign-form/CampaignTypeSelector';
import ProductFormSection from '@/components/campaign-form/ProductFormSection';
import RecruitFormSection from '@/components/campaign-form/RecruitFormSection';
import { useCampaignFormStore } from '@/lib/stores/campaignFormStore';
import Link from 'next/link';

export default function CampaignFormPage() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const campaignId = searchParams.get('id');

    const {
        campaignType,
        internalTitle,
        editingCampaign,
        isLoading,
        isSubmitting,
        setFormData,
        loadCampaignForEdit,
        submitForm,
    } = useCampaignFormStore();

    useEffect(() => {
        if (campaignId) {
            loadCampaignForEdit(campaignId);
        }
    }, [campaignId, loadCampaignForEdit]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await submitForm();
            alert(`캠페인이 성공적으로 ${editingCampaign ? '수정' : '등록'}되었습니다.`);
            router.push('/campaigns');
        } catch (e: any) {
            alert(`저장 실패: ${e.message}`);
        }
    };

    if (isLoading) {
        return <div className="text-center py-12">데이터를 불러오는 중...</div>;
    }

    return (
        <main className="p-4 bg-gray-50 min-h-screen">
            <h1 className="text-2xl font-bold mb-6">
                {editingCampaign ? '공고 수정' : '공고 등록'}
            </h1>
            <form onSubmit={handleSubmit} className="space-y-6">
                <FormSectionContainer title="공고 제목">
                    <input
                        type="text"
                        placeholder="예) 9월 2주차 뷰티 런칭"
                        value={internalTitle}
                        onChange={(e) => setFormData({ internalTitle: e.target.value })}
                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
                    />
                    <p className="text-sm text-gray-500 mt-1">
                        본인에게만 보이는 메모용 제목입니다. 외부에 노출되지 않습니다.
                    </p>
                </FormSectionContainer>

                <FormSectionContainer title="대표 썸네일">
                    <ImagePickerSection />
                </FormSectionContainer>

                <FormSectionContainer title="공고 유형">
                    <CampaignTypeSelector />
                </FormSectionContainer>

                {campaignType === 'product' ? (
                    <FormSectionContainer title="상품 공고">
                        <ProductFormSection />
                    </FormSectionContainer>
                ) : (
                    <FormSectionContainer title="쇼호스트 모집 상세">
                        <RecruitFormSection />
                    </FormSectionContainer>
                )}

                <div className="flex justify-end space-x-2">
                    <Link href="/campaigns">
                        <button
                            type="button"
                            disabled={isSubmitting}
                            className="py-3 px-6 rounded-lg text-gray-700 font-bold"
                        >
                            취소
                        </button>
                    </Link>
                    <button
                        type="submit"
                        disabled={isSubmitting}
                        className={`py-3 px-6 rounded-lg font-bold text-white transition-colors ${isSubmitting ? 'bg-gray-400 cursor-not-allowed' : 'bg-indigo-600 hover:bg-indigo-700'
                            }`}
                    >
                        {isSubmitting ? '저장 중...' : editingCampaign ? '수정 저장' : '등록하기'}
                    </button>
                </div>
            </form>
        </main>
    );
}