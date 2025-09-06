'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useAuthStore } from '../../lib/stores/authStore';
import { useRouter } from 'next/navigation';

export default function SignupPage() {
    const [nickname, setNickname] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [errorMessage, setErrorMessage] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [selectedRole, setSelectedRole] = useState('brand');
    const signup = useAuthStore((state) => state.signup);
    const router = useRouter();

    const handleSignup = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);
        setErrorMessage('');
        try {
            // Zustand 스토어의 signup 함수 호출
            await signup(nickname, email, password, selectedRole);
            // 회원가입 성공 시 로그인 페이지로 이동
            alert('회원가입이 완료되었습니다. 로그인 해주세요.');
            router.push('/login');
        } catch (e: any) {
            setErrorMessage(e.message);
        } finally {
            setIsLoading(false);
        }
    };

    const buildRoleButton = (role: string, label: string) => {
        const isSelected = selectedRole === role;
        return (
            <div
                onClick={() => setSelectedRole(role)}
                className={`flex-1 flex justify-center items-center h-12 rounded-full font-bold transition-colors cursor-pointer ${isSelected
                    ? 'bg-gray-900 text-white border border-gray-900'
                    : 'bg-gray-50 text-gray-700 border border-gray-200'
                    }`}
            >
                {label}
            </div>
        );
    };

    return (
        <main className="flex min-h-screen flex-col items-center justify-center bg-white px-4">
            <div className="w-full max-w-md flex flex-col items-center">
                <h1 className="text-3xl font-extrabold mb-4">회원가입</h1>
                <div className="w-full flex space-x-2 mb-4">
                    {buildRoleButton('brand', '브랜드(업체)')}
                    {buildRoleButton('showhost', '쇼호스트')}
                </div>
                <form onSubmit={handleSignup} className="w-full">
                    <input
                        type="text"
                        placeholder="닉네임"
                        value={nickname}
                        onChange={(e) => setNickname(e.target.value)}
                        className="w-full px-4 py-3 border border-gray-300 rounded-xl mb-3 focus:outline-none focus:border-indigo-500"
                    />
                    <input
                        type="email"
                        placeholder="이메일"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        className="w-full px-4 py-3 border border-gray-300 rounded-xl mb-3 focus:outline-none focus:border-indigo-500"
                    />
                    <input
                        type="password"
                        placeholder="비밀번호"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="w-full px-4 py-3 border border-gray-300 rounded-xl mb-6 focus:outline-none focus:border-indigo-500"
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
                        가입하기
                    </button>
                </form>
                <div className="mt-6 text-center text-sm text-gray-600">
                    이미 계정이 있나요?{' '}
                    <Link href="/login" className="font-bold text-gray-800">
                        로그인
                    </Link>
                </div>
            </div>
        </main>
    );
}