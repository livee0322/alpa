import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/main/widgets/recruit_section.dart';
import 'package:livee/presentation/widgets/common_banner.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/service_locator.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoading = true;
  List<Campaign> _schedules = [];
  List<Campaign> _recruits = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 페이지에 필요한 모든 데이터를 한 번에 불러오는 메소드
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final campaignUseCase = locator<CampaignUseCase>();
      // 여러 API를 동시에 호출하여 성능 향상
      final results = await Future.wait([
        campaignUseCase.getAllCampaigns(type: 'recruit', limit: 6),
        campaignUseCase.getAllCampaigns(type: 'recruit', limit: 10),
      ]);
      setState(() {
        _schedules = results[0];
        _recruits = results[1];
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CommonHeader는 Consumer 외부로 이동하여 불필요한 재빌드 방지
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CommonHeader(isLoggedIn: authProvider.isLoggedIn);
                },
              ),
              const CommonBanner(),
              const CommonTopTabBar(),
              // 로딩이 끝난 후 본문 내용 표시
              if (!_isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildBody(),
                ),
            ],
          ),
        ),
        bottomNavigationBar: const CommonBottomNavBar(),
      ),
    );
  }

  // 화면 본문을 빌드하는 헬퍼 메소드
  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(child: Text("데이터를 불러오는 데 실패했습니다: $_errorMessage"));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: '오늘의 라이브',
          onTap: () => GoRouter.of(context).go('/schedule'),
        ),
        _buildScheduleSection(),
        const SizedBox(height: 18),
        _buildSectionHeader(
          title: '추천 공고',
          onTap: () {
            GoRouter.of(context).go('/recruits');
          },
        ),
        RecruitSection(recruits: _recruits), // 수정: recruitsFuture -> recruits
      ],
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
    if (_schedules.isEmpty) {
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
    }

    final items = _schedules;
    return Column(
      children: items.map((campaign) {
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  // 캠페인의 커버 이미지를 사용하고, 없을 경우 대체 이미지를 표시
                  campaign.coverImageUrl ?? 'https://picsum.photos/seed/schedule${campaign.id}/96/96',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  // 이미지 로딩 실패 시 Placeholder 표시
                  errorBuilder: (context, error, stackTrace) => const Placeholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 브랜드명
                    Text(
                      campaign.brand ?? '브랜드 미정',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 제목
                    Text(
                      campaign.title ?? '제목 없음',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // 촬영 시간
                    Text(
                      campaign.liveTime ?? '시간 미정',
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
}
