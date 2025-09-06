'use client';

import { useQuery } from '@tanstack/react-query';
import { PortfolioUseCase } from '@/lib/domain/usecases/portfolioUseCase';
import { PortfolioRepository } from '@/lib/domain/repositories/portfolioRepository';
import Link from 'next/link';
import { useState } from 'react';

// 임시 리포지토리 및 유스케이스 인스턴스 생성
const portfolioUseCase = new PortfolioUseCase(new PortfolioRepository());

export default function ShowhostsPage() {
    const [selectedCategory, setSelectedCategory] = useState('');

    const { data: showhosts, isLoading, isError } = useQuery({
        queryKey: ['showhosts', selectedCategory],
        queryFn: async () => {
            const allShowhosts = await portfolioUseCase.getAllPublicPortfolios();
            if (selectedCategory) {
                return allShowhosts.filter(host => host.category === selectedCategory);
            }
            return allShowhosts;
        },
    });

    if (isLoading) {
        return <div className="text-center py-12">로딩 중...</div>;
    }

    if (isError) {
        return <div className="text-center py-12 text-red-500">쇼호스트 목록 로딩 실패</div>;
    }

    if (!showhosts || showhosts.length === 0) {
        return <div className="text-center py-12 text-gray-500">등록된 쇼호스트가 없습니다.</div>;
    }

    return (
        <main className="min-h-screen bg-gray-50 p-4">
            <h1 className="text-2xl font-bold mb-4">쇼호스트 리스트</h1>

            {/* 필터링 UI */}
            <div className="flex space-x-2 mb-4">
                <select
                    value={selectedCategory}
                    onChange={(e) => setSelectedCategory(e.target.value)}
                    className="px-4 py-2 border rounded-lg"
                >
                    <option value="">카테고리</option>
                    <option value="뷰티">뷰티</option>
                    <option value="음식">음식</option>
                    {/* TODO: 출연료 필터 추가 */}
                </select>
            </div>

            {/* 쇼호스트 목록 */}
            <ul className="space-y-3">
                {showhosts.map((host) => (
                    <li key={host.id} className="bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200">
                        <Link href={`/showhosts/${host.id}`} className="block p-4 flex items-center space-x-4">
                            <img
                                src={host.profileImage || `https://picsum.photos/seed/${host.id}/96/96`}
                                alt={host.name || '프로필 이미지'}
                                className="w-12 h-12 rounded-full object-cover"
                            />
                            <div className="flex-1">
                                <h2 className="text-lg font-bold">{host.name || '이름 없음'}</h2>
                                <p className="text-sm text-gray-500">
                                    경력: {host.experienceYears ?? '-'}년 | 지역: {host.region ?? '-'}
                                </p>
                            </div>
                        </Link>
                    </li>
                ))}
            </ul>
        </main>
    );
}