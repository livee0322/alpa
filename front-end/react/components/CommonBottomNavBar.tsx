'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useAuthStore } from '@/lib/stores/authStore';

// Flutter의 CommonBottomNavBar에서 가져온 아이템 데이터
const navItems = [
    { label: '홈', icon: '🏠', path: '/' },
    { label: '모집공고', icon: '📦', path: '/recruits' },
    { label: '라이브러리', icon: '🔖', path: '/library' },
    { label: '인플루언서', icon: '👤', path: '/showhosts' },
    { label: '마이페이지', icon: '⚙️', path: '/mypage' },
];

// 로그인이 필요한 페이지 목록
const authRequiredRoutes = ['/mypage', '/library'];

export default function CommonBottomNavBar() {
    const router = useRouter();
    const pathname = usePathname();
    const isLoggedIn = useAuthStore((state) => state.isLoggedIn);

    const handleNavClick = (path: string) => {
        if (authRequiredRoutes.includes(path) && !isLoggedIn) {
            // Flutter의 showLoginPromptDialog와 유사한 기능
            alert('로그인이 필요합니다.');
            router.push('/login');
        } else {
            router.push(path);
        }
    };

    return (
        <nav className="fixed bottom-0 left-0 right-0 z-10 bg-white border-t border-gray-200 shadow-md">
            <div className="flex justify-around py-2">
                {navItems.map((item) => (
                    <button
                        key={item.path}
                        onClick={() => handleNavClick(item.path)}
                        className="flex flex-col items-center flex-1 focus:outline-none"
                    >
                        <span className="text-xl">{item.icon}</span>
                        <span
                            className={`text-xs font-semibold mt-1 transition-colors ${pathname === item.path ? 'text-indigo-600' : 'text-gray-500'
                                }`}
                        >
                            {item.label}
                        </span>
                    </button>
                ))}
            </div>
        </nav>
    );
}