interface DetailMetaCardProps {
    icon: string; // Tailwind CSS 클래스 또는 SVG
    label: string;
    value: string;
}

export default function DetailMetaCard({ icon, label, value }: DetailMetaCardProps) {
    return (
        <div className="bg-white rounded-xl shadow-sm p-4 flex items-center space-x-3">
            {/* 아이콘: 여기서는 예시로 SVG를 사용하거나 icon prop을 Tailwind 클래스로 받을 수 있습니다 */}
            <span className="text-xl text-gray-500">{icon}</span>
            <div className="flex-grow">
                <p className="text-xs text-gray-500">{label}</p>
                <p className="font-bold text-gray-900 mt-1 truncate">{value}</p>
            </div>
        </div>
    );
}