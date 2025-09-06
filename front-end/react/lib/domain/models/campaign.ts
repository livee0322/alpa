import { Product } from './product';
import { Recruit } from './recruit';

export interface Campaign {
    id?: string;
    title?: string;
    thumbnailUrl?: string;
    coverImageUrl?: string;
    type?: string;
    products?: Product[];
    recruit?: Recruit;
    brand?: string;
    category?: string;
    fee?: number;
    feeNegotiable?: boolean;
    liveTime?: string;
    closeAt?: string;
    descriptionHTML?: string;
}