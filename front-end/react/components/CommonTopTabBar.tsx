'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const tabs = [
    { label: '숏클립', path: '/clips' },
    { label: '쇼핑라이브', path: '/live' },
    { label: '뉴스', path: '/news' },
    { label: '이벤트', path: '/event' },
    { label: '서비스', path: '/service' },
];

export default function CommonTopTabBar() {
    const pathname = usePathname();

    return (
        <div className="w-full bg-white border-b border-gray-200 h-12 overflow-x-auto">
            <div className="flex items-center space-x-2 px-3 h-full">
                {tabs.map((tab) => {
                    const isActive = pathname === tab.path;
                    return (
                        <Link key={tab.path} href={tab.path} className="flex flex-col justify-center items-center h-full px-3">
                            <span
                                className={`text-sm font-semibold transition-colors ${isActive ? 'text-indigo-600' : 'text-gray-600'
                                    }`}
                            >
                                {tab.label}
                            </span>
                            {isActive && <div className="mt-1 h-0.5 w-6 bg-indigo-600 rounded-full" />}
                        </Link>
                    );
                })}
            </div>
        </div>
    );
}