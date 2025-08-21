import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
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
    _campaignsFuture = Provider.of<CampaignUseCase>(context, listen: false).getMyCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캠페인 관리'),
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
                    child: Text('캠페인이 없습니다.'),
                  );
                } else {
                  final campaigns = snapshot.data!;
                  return ListView.builder(
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = campaigns[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: InkWell(
                          onTap: () => GoRouter.of(context).push('/campaign/${campaign.id}'),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  campaign.coverImageUrl != null
                                      ? Image.network(
                                          campaign.coverImageUrl!,
                                          width: 148,
                                          height: 84,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 148,
                                          height: 84,
                                          color: Colors.grey[300],
                                        ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          campaign.title ?? '제목 없음',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '유형: ${campaign.type}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () {
                                          GoRouter.of(context).go('/campaign-form', extra: campaign.id);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('삭제 확인'),
                                              content: const Text('이 캠페인을 삭제하시겠어요?'),
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
                                              await Provider.of<CampaignUseCase>(context, listen: false)
                                                  .deleteCampaign(campaign.id!);
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
