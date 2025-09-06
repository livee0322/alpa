import Link from 'next/link';

interface DetailStickyBottomBarProps {
    priceLabel: string;
    buttonLabel: string;
    campaignId: string;
}

export default function DetailStickyBottomBar({ priceLabel, buttonLabel, campaignId }: DetailStickyBottomBarProps) {
    return (
        <div className="fixed bottom-0 left-0 right-0 z-10 bg-white border-t border-gray-200 shadow-md p-4">
            <div className="flex items-center justify-between">
                <p className="font-bold text-lg">{priceLabel}</p>
                <Link href={`/campaign/${campaignId}/applicants`} passHref>
                    <button className="bg-indigo-600 text-white font-bold py-3 px-6 rounded-xl hover:bg-indigo-700 transition-colors">
                        {buttonLabel}
                    </button>
                </Link>
            </div>
        </div>
    );
}