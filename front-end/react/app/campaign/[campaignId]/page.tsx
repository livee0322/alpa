export default function CampaignDetailPage({ params }: { params: { campaignId: string } }) {
    return <div>캠페인 상세 화면 (ID: {params.campaignId})</div>;
}