import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/service_locator.dart';
import 'package:provider/provider.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  late Future<List<Campaign>> _campaignsFuture;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  void _loadCampaigns() {
    // locator를 통해 UseCase 인스턴스를 직접 가져오기
    _campaignsFuture = locator<CampaignUseCase>().getMyCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공고 관리'),
        actions: [
          IconButton(
            onPressed: () => GoRouter.of(context).go('/campaign-form'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CommonHeader(isLoggedIn: authProvider.isLoggedIn);
            },
          ),
          Expanded(
            child: FutureBuilder<List<Campaign>>(
              future: _campaignsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('에러: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('등록된 공고가 없습니다.'),
                  );
                } else {
                  final campaigns = snapshot.data!;
                  return ListView.builder(
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = campaigns[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          shadowColor: Colors.black12,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => GoRouter.of(context).push('/campaign/${campaign.id}'),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      // 썸네일 이미지
                                      campaign.coverImageUrl != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                campaign.coverImageUrl!,
                                                width: 120,
                                                height: 68,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              width: 120,
                                              height: 68,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                      const SizedBox(width: 12),
                                      // 캠페인 제목 및 유형
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              campaign.title ?? '제목 없음',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '유형: ${campaign.type}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 수정 및 삭제 아이콘 버튼
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () =>
                                                GoRouter.of(context).go('/campaign-form', extra: campaign.id),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                            onPressed: () async {
                                              final confirm = await showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('삭제 확인'),
                                                  content: const Text('이 공고를 삭제하시겠어요?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: const Text('취소'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(true),
                                                      child: const Text('삭제'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                try {
                                                  // locator를 사용
                                                  await locator<CampaignUseCase>().deleteCampaign(campaign.id!);
                                                  setState(() {
                                                    _loadCampaigns();
                                                  });
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // '지원자 현황 보기' 버튼을 위한 영역
                              const Divider(height: 1),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () => GoRouter.of(context).go('/campaign/${campaign.id}/applicants'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  child: const Text('지원자 현황 보기'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }
}
