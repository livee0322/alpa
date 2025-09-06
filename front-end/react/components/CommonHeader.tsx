'use client';

import { useAuthStore } from '@/lib/stores/authStore';
import Link from 'next/link';

export default function CommonHeader() {
    const { isLoggedIn, logout } = useAuthStore();

    const handleLogout = () => {
        logout();
    };

    return (
        <header className="flex items-center justify-between h-16 px-4 bg-white border-b border-gray-200">
            <Link href="/">
                <img src="/liveelogo.png" alt="Livee Logo" className="h-8" />
            </Link>
            <div className="flex items-center space-x-2">
                <button aria-label="Notifications" className="p-2">
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="24"
                        height="24"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                    >
                        <path d="M18 8a6 6 0 0 0-12 0c0 4.5-3.6 7.2-6 9.6v.4a2 2 0 0 0 2 2h20a2 2 0 0 0 2-2v-.4c-2.4-2.4-6-5.1-6-9.6z" />
                        <path d="M9 18v1a3 3 0 0 0 6 0v-1" />
                    </svg>
                </button>
                <button aria-label="Search" className="p-2">
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="24"
                        height="24"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                    >
                        <circle cx="11" cy="11" r="8" />
                        <line x1="21" y1="21" x2="16.65" y2="16.65" />
                    </svg>
                </button>
                {isLoggedIn ? (
                    <button onClick={handleLogout} aria-label="Logout" className="p-2">
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="24"
                            height="24"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="2"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                        >
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
                            <polyline points="16 17 21 12 16 7" />
                            <line x1="21" y1="12" x2="9" y2="12" />
                        </svg>
                    </button>
                ) : (
                    <Link href="/login" className="py-2 px-4 rounded-full border border-gray-300">
                        로그인
                    </Link>
                )}
            </div>
        </header>
    );
}