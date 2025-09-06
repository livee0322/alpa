'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/lib/stores/authStore';

export default function MypagePage() {
    const router = useRouter();
    const { isLoggedIn, user } = useAuthStore();

    useEffect(() => {
        // isLoggedIn 상태가 false이면 로그인 페이지로 리디렉션
        if (!isLoggedIn) {
            router.push('/login');
        }
    }, [isLoggedIn, router]);

    if (!isLoggedIn) {
        // 로그인되지 않은 경우, 화면 깜빡임 방지를 위해 null 또는 로딩 상태 반환
        return null;
    }

    return (
        <main className="min-h-screen p-8 bg-gray-50">
            <h1 className="text-2xl font-bold text-gray-900 mb-6">마이페이지</h1>
            <div className="bg-white p-6 rounded-lg shadow-sm">
                <div className="text-lg font-semibold">안녕하세요, {user?.name ?? '사용자'}님!</div>
                <p className="text-gray-600 mt-2">이곳은 로그인 회원만 접근 가능한 마이페이지입니다.</p>
                <p className="text-gray-600 mt-1">로그인 상태: {isLoggedIn ? '로그인됨' : '로그인되지 않음'}</p>
            </div>
            {/* TODO: 사용자 역할(role)에 따른 메뉴 구현 */}
        </main>
    );
}