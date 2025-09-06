
import './globals.css';
import { Inter } from 'next/font/google';
import Providers from './providers';
import CommonHeader from '@/components/CommonHeader';

const inter = Inter({ subsets: ['latin'] });

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      <body className={inter.className}>
        <Providers>
          <CommonHeader /> {/* 수정된 위치: Providers 컴포넌트 내부에 헤더 추가 */}
          {children}
        </Providers>
      </body>
    </html>
  );
}
