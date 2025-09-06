'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { PortfolioUseCase } from '@/lib/domain/usecases/portfolioUseCase';
import { PortfolioRepository } from '@/lib/domain/repositories/portfolioRepository';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

const portfolioUseCase = new PortfolioUseCase(new PortfolioRepository());

export default function MyPortfoliosPage() {
    const queryClient = useQueryClient();
    const router = useRouter();

    // 목록 조회
    const { data: portfolios, isLoading, isError } = useQuery({
        queryKey: ['myPortfolios'],
        queryFn: () => portfolioUseCase.getMyPortfolioList(),
    });

    // 삭제 뮤테이션
    const deleteMutation = useMutation({
        mutationFn: (id: string) => portfolioUseCase.deletePortfolio(id),
        onSuccess: () => {
            alert('포트폴리오가 삭제되었습니다.');
            queryClient.invalidateQueries({ queryKey: ['myPortfolios'] });
        },
        onError: (error: any) => {
            alert(`삭제 실패: ${error.message}`);
        },
    });

    const handleDelete = (id: string) => {
        if (window.confirm('정말로 이 포트폴리오를 삭제하시겠습니까?')) {
            deleteMutation.mutate(id);
        }
    };

    if (isLoading) {
        return <div className="text-center py-12">로딩 중...</div>;
    }

    if (isError) {
        return <div className="text-center py-12 text-red-500">오류: 포트폴리오를 불러올 수 없습니다.</div>;
    }

    if (!portfolios || portfolios.length === 0) {
        return (
            <div className="text-center py-12 text-gray-500">
                <p>등록된 포트폴리오가 없습니다.</p>
                <Link href="/portfolio-edit" className="mt-4 inline-block bg-indigo-600 text-white py-2 px-4 rounded-lg font-bold">
                    + 등록
                </Link>
            </div>
        );
    }

    return (
        <main className="min-h-screen bg-gray-50 p-4">
            <div className="flex justify-between items-center mb-4">
                <h1 className="text-2xl font-bold">내 포트폴리오</h1>
                <Link href="/portfolio-edit" className="bg-indigo-600 text-white py-2 px-4 rounded-lg font-bold">
                    + 등록
                </Link>
            </div>

            <div className="space-y-4">
                {portfolios.map((portfolio) => (
                    <div key={portfolio.id} className="bg-white rounded-xl shadow-sm overflow-hidden border border-gray-200 p-4">
                        <div className="flex items-center space-x-4">
                            <img
                                src={portfolio.profileImage || `https://picsum.photos/seed/${portfolio.id}/96/96`}
                                alt="프로필 이미지"
                                className="w-12 h-12 rounded-full object-cover"
                            />
                            <div className="flex-1">
                                <h2 className="text-lg font-bold truncate">{portfolio.name || '무명'}</h2>
                            </div>
                        </div>
                        <div className="mt-4 pt-4 border-t border-gray-200 flex justify-end space-x-2">
                            <Link href={`/portfolio-edit?id=${portfolio.id}`} passHref>
                                <button className="py-2 px-4 border border-gray-400 rounded-lg text-gray-700 font-bold">
                                    수정
                                </button>
                            </Link>
                            <button
                                onClick={() => handleDelete(portfolio.id)}
                                disabled={deleteMutation.isPending}
                                className="py-2 px-4 border border-red-500 text-red-500 rounded-lg font-bold"
                            >
                                삭제
                            </button>
                        </div>
                    </div>
                ))}
            </div>
        </main>
    );
}