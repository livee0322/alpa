import { Product } from '@/lib/domain/models/product';

interface DetailProductCardProps {
    product: Product;
}

export default function DetailProductCard({ product }: DetailProductCardProps) {
    return (
        <div className="bg-white rounded-xl shadow-sm p-3 flex items-center space-x-3 mt-2">
            <img
                src={product.thumbnail || `https://picsum.photos/seed/${product.title}/128/128`}
                alt={product.title || '상품 이미지'}
                className="w-16 h-16 rounded-lg object-cover"
            />
            <div className="flex-grow">
                <p className="text-sm font-semibold truncate">{product.title || '상품명 미정'}</p>
            </div>
            <p className="font-extrabold text-sm">{product.price?.toLocaleString() || '0'}원</p>
        </div>
    );
}