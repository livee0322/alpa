import { useState } from 'react';
import Link from 'next/link';

export default function LoginPage() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [errorMessage, setErrorMessage] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [selectedRole, setSelectedRole] = useState('brand');

    const handleLogin = (e: React.FormEvent) => {
        e.preventDefault();
        // TODO: 로그인 로직 구현
    };

    const buildRoleButton = (role: string, label: string) => {
        const isSelected = selectedRole === role;
        return (
            <div
                onClick={() => setSelectedRole(role)}
                className={`flex-1 flex justify-center items-center h-12 rounded-xl font-bold transition-colors cursor-pointer ${isSelected ? 'bg-white text-gray-900' : 'bg-transparent text-gray-700'
                    }`}
            >
                {label}
            </div>
        );
    };

    return (
        <main className="flex min-h-screen flex-col items-center justify-center bg-white px-4">
            <div className="w-full max-w-sm flex flex-col items-center">
                <img src="/liveelogo.png" alt="Livee Logo" className="mb-8" />
                <div className="w-full bg-gray-100 rounded-xl p-1 mb-6 flex">
                    {buildRoleButton('brand', '브랜드')}
                    {buildRoleButton('showhost', '쇼호스트')}
                </div>
                <form onSubmit={handleLogin} className="w-full">
                    <input
                        type="email"
                        placeholder="you@example.com"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        className="w-full px-4 py-3 border border-gray-200 rounded-xl mb-4 focus:outline-none focus:border-indigo-500"
                    />
                    <input
                        type="password"
                        placeholder="••••••••"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="w-full px-4 py-3 border border-gray-200 rounded-xl mb-6 focus:outline-none focus:border-indigo-500"
                    />
                    {errorMessage && (
                        <div className="text-red-500 font-bold text-sm text-center mb-4">
                            {errorMessage}
                        </div>
                    )}
                    <button
                        type="submit"
                        disabled={isLoading}
                        className={`w-full py-3 rounded-xl font-extrabold transition-colors ${isLoading ? 'bg-gray-200 text-gray-500 cursor-not-allowed' : 'bg-indigo-600 text-white hover:bg-indigo-700'
                            }`}
                    >
                        {isLoading ? '로그인 중...' : '로그인'}
                    </button>
                </form>
                <div className="mt-8 text-center text-sm text-gray-600">
                    아직 계정이 없으신가요?{' '}
                    <Link href="/signup" className="text-indigo-600 font-bold underline">
                        회원가입
                    </Link>
                </div>
            </div>
        </main>
    );
}