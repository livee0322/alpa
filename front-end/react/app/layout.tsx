
import './globals.css';
import { Inter } from 'next/font/google';
import Providers from './providers';
import CommonHeader from '@/components/CommonHeader';
import CommonBottomNavBar from '@/components/CommonBottomNavBar';

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
          <CommonHeader />
          {children}
          <CommonBottomNavBar />
        </Providers>
      </body>
    </html>
  );
}
