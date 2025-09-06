'use client';

import { useQuery } from '@tanstack/react-query';
import { PortfolioUseCase } from '@/lib/domain/usecases/portfolioUseCase';
import { PortfolioRepository } from '@/lib/domain/repositories/portfolioRepository';
import Link from 'next/link';

// 임시 리포지토리 및 유스케이스 인스턴스 생성
const portfolioUseCase = new PortfolioUseCase(new PortfolioRepository());

interface ShowhostDetailPageProps {
    params: { id: string };
}

export default function ShowhostDetailPage({ params }: ShowhostDetailPageProps) {
    const { id } = params;

    const { data: host, isLoading, isError } = useQuery({
        queryKey: ['showhost', id],
        queryFn: () => portfolioUseCase.getPortfolioById(id),
    });

    const buildInfoRow = (title: string, content?: string | number) => (
        <div className="mb-4">
            <p className="text-sm font-bold text-gray-800">{title}</p>
            <p className="text-sm text-gray-600 mt-1">{content || '-'}</p>
        </div>
    );

    if (isLoading) {
        return <div className="text-center py-12">로딩 중...</div>;
    }

    if (isError) {
        return <div className="text-center py-12 text-red-500">상세 정보를 찾을 수 없습니다.</div>;
    }

    if (!host) {
        return <div className="text-center py-12 text-gray-500">쇼호스트 정보가 없습니다.</div>;
    }

    return (
        <main className="min-h-screen bg-gray-50 p-4">
            <h1 className="text-2xl font-bold mb-4">쇼호스트 상세 정보</h1>

            {/* 프로필 섹션 */}
            <div className="bg-white p-6 rounded-xl shadow-sm mb-6 flex items-center space-x-4">
                <img
                    src={host.profileImage || `https://picsum.photos/seed/${host.id}/96/96`}
                    alt={host.name || '프로필 이미지'}
                    className="w-24 h-24 rounded-lg object-cover"
                />
                <div className="flex-1">
                    <h2 className="text-xl font-bold">{host.name || '이름 없음'}</h2>
                    <p className="text-sm text-gray-500">카테고리: {host.category || '-'}</p>
                </div>
            </div>

            {/* 상세 정보 섹션 */}
            <div className="bg-white p-6 rounded-xl shadow-sm mb-6">
                {buildInfoRow('한 줄 소개', host.oneLineIntro)}
                {buildInfoRow('경력', `${host.experienceYears ?? '-'}년`)}
                {buildInfoRow('나이', host.age)}
                {buildInfoRow('대표 링크', host.mainLink)}
            </div>

            {/* 섭외 요청 버튼 */}
            <Link href={`/casting-request?showhostId=${host.id}`} passHref>
                <button className="w-full bg-indigo-600 text-white font-bold py-3 rounded-lg hover:bg-indigo-700 transition-colors">
                    섭외 요청하기
                </button>
            </Link>
        </main>
    );
}