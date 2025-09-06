import { Live } from './live';

export interface Portfolio {
    id: string;
    name?: string;
    profileImage?: string;
    jobTag?: string;
    experienceYears?: number;
    region?: string;
    category?: string;
    nickname?: string;
    oneLineIntro?: string;
    detailedIntro?: string;
    age?: number;
    mainLink?: string;
    mainThumbnailUrl?: string;
    backgroundImageUrl?: string;
    subThumbnailUrls?: string[];
    publicScope?: string;
    isReceivingOffers?: boolean;
    recentLives?: Live[];
    tags?: string[];
    status?: string;
}