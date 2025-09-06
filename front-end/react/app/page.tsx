import Link from 'next/link';
import CommonBanner from '@/components/CommonBanner';
import CommonTopTabBar from '@/components/CommonTopTabBar';
import ProductSection from '@/components/main/ProductSection';
import RecruitSection from '@/components/main/RecruitSection';
import ScheduleSection from '@/components/main/ScheduleSection';

const SectionHeader = ({ title, link }: { title: string; link?: string }) => (
  <div className="flex items-center justify-between mt-6 mb-4">
    <h2 className="text-xl font-bold">{title}</h2>
    {link && (
      <Link href={link} className="text-sm text-gray-500 hover:underline">
        더보기
      </Link>
    )}
  </div>
);

export default function MainPage() {
  return (
    <main>
      <CommonBanner />
      <CommonTopTabBar />
      <div className="p-4">
        <SectionHeader title="오늘의 라이브 라인업" link="/schedule" />
        <ScheduleSection />
        <SectionHeader title="라이브 상품" link="/products" />
        <ProductSection />
        <SectionHeader title="추천 공고" link="/recruits" />
        <RecruitSection />
      </div>
    </main>
  );
}