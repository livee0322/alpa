import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_banner.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<Campaign>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    // Provider 설정 후 데이터 로딩
    final campaignUseCase = Provider.of<CampaignUseCase>(context, listen: false);
    _scheduleFuture = campaignUseCase.getAllCampaigns(type: 'recruit', limit: 50);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonHeader(isLoggedIn: authProvider.isLoggedIn),
                const CommonBanner(),
                const CommonTopTabBar(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        title: '오늘의 라이브 라인업',
                        onTap: () {
                          GoRouter.of(context).go('/schedule');
                        },
                      ),
                      _buildScheduleSection(),
                      // TODO: '라이브 상품' 섹션 추가
                      // TODO: '추천 공고' 섹션 추가
                      // TODO: '인기 쇼호스트' 섹션 추가
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const CommonBottomNavBar(),
        );
      },
    );
  }

  Widget _buildSectionHeader({required String title, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          if (onTap != null)
            InkWell(
              onTap: onTap,
              child: const Text(
                '더보기',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return FutureBuilder<List<Campaign>>(
      future: _scheduleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('일정 로딩 실패'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '예정된 일정이 없습니다.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9AA3AF),
                ),
              ),
            ),
          );
        } else {
          final items = snapshot.data!;
          return Column(
            children: items.map((campaign) {
              final recruit = campaign.recruit;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFF1F3F5),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.06),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // TODO: 이미지 위젯 추가
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: Placeholder(), // 임시 이미지
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.title ?? '무제',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            recruit?.date ?? '',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}
