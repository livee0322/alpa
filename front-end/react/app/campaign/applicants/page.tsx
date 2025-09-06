export default function ApplicantListPage({ params }: { params: { campaignId: string } }) {
    return <div>지원자 현황 화면 (캠페인 ID: {params.campaignId})</div>;
}