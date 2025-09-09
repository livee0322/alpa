import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/main/vm/main_view_model.dart'; // ViewModel import
import 'package:livee/presentation/screens/main/widgets/banner_slider_section.dart';
import 'package:livee/presentation/screens/main/widgets/consultation_section.dart';
import 'package:livee/presentation/screens/main/widgets/featured_showhost_section.dart';
import 'package:livee/presentation/screens/main/widgets/news_section.dart';
import 'package:livee/presentation/screens/main/widgets/recruit_section.dart';
import 'package:livee/presentation/widgets/colored_title.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

/// 메인 화면을 구성하는 StatelessWidget
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => MainViewModel(),
        child: Consumer<MainViewModel>(
          builder: (context, viewModel, child) => LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: Scaffold(
              backgroundColor: const Color(0xFFF6F7F9),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return CommonHeader(isLoggedIn: authProvider.isLoggedIn);
                      },
                    ),
                    const CommonTopTabBar(),
                    if (!viewModel.isLoading)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildBody(context, viewModel),
                      ),
                  ],
                ),
              ),
              bottomNavigationBar: const CommonBottomNavBar(),
            ),
          ),
        ),
      );

  /// 화면 본문을 빌드하는 헬퍼 메소드
  Widget _buildBody(BuildContext context, MainViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(child: Text("데이터를 불러오는 데 실패했습니다: ${viewModel.errorMessage}"));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BannerSliderSection(),
        const SizedBox(height: 24),
        _buildSectionHeader(
          blackTitle: '쇼핑 라이브 공고',
          purpleTitle: '지금 뜨는 ',
          purpleFirst: true,
          onTap: () => GoRouter.of(context).go('/schedule'),
        ),
        _buildScheduleSection(viewModel.schedules),
        const SizedBox(height: 18),
        _buildSectionHeader(
          blackTitle: '브랜드 ',
          purpleTitle: 'pick',
          onTap: () => GoRouter.of(context).go('/schedule'),
        ),
        RecruitSection(recruits: viewModel.recruits),
        const SizedBox(height: 18),
        _buildSectionHeader(
          blackTitle: '라이비 ',
          purpleTitle: '뉴스',
          onTap: () {
            // TODO: 뉴스 전체 목록 페이지로 이동
          },
        ),
        const NewsSection(), // NewsSection은 자체 목업 데이터 사용
        const SizedBox(height: 18),
        _buildSectionHeader(
          blackTitle: '는 어떠세요?',
          purpleTitle: '이런 쇼호스트',
          purpleFirst: true,
          onTap: () {
            // TODO: 쇼호스트 전체 목록 페이지로 이동
          },
        ),
        FeaturedShowhostSection(showhosts: viewModel.featuredShowhosts),
        const SizedBox(height: 18),
        const ConsultationSection(),
      ],
    );
  }

  /// 섹션 헤더 UI를 구성하는 메소드
  Widget _buildSectionHeader({
    required String blackTitle,
    required String purpleTitle,
    bool purpleFirst = false,
    VoidCallback? onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ColoredTitle(
              blackText: blackTitle,
              purpleText: purpleTitle,
              purpleFirst: purpleFirst,
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

  /// '지금 뜨는 쇼핑 라이브 공고' 섹션 UI를 구성하는 메소드
  Widget _buildScheduleSection(List<Campaign> schedules) {
    if (schedules.isEmpty) {
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

    return Column(
      children: schedules.map(
        (campaign) {
          final closeDate = campaign.closeAt?.substring(0, 10) ?? '미정';
          String feeText = '미정';
          if (campaign.fee != null && campaign.fee! > 0) {
            feeText = '${(campaign.fee! / 10000).round()}만원';
          } else if (campaign.feeNegotiable == true) {
            feeText = '협의';
          }
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
                    campaign.coverImageUrl ?? 'https://picsum.photos/seed/schedule${campaign.id}/96/96',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Placeholder(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.brand ?? '브랜드',
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        campaign.title ?? '제목 없음',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '마감 $closeDate · 출연료 $feeText',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }
}
