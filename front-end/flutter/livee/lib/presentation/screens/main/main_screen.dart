import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/main/vm/main_view_model.dart';
import 'package:livee/presentation/screens/main/widgets/banner_slider_section.dart';
import 'package:livee/presentation/screens/main/widgets/consultation_section.dart';
import 'package:livee/presentation/screens/main/widgets/featured_showhost_section.dart';
import 'package:livee/presentation/screens/main/widgets/hot_clip_section.dart';
import 'package:livee/presentation/screens/main/widgets/news_section.dart';
import 'package:livee/presentation/screens/main/widgets/recruit_section.dart';
import 'package:livee/presentation/screens/main/widgets/section_container.dart';
import 'package:livee/presentation/widgets/colored_title.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';

/// 메인 화면
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
                    // 로딩 중이 아닐 때만 Padding을 적용하여 일관성 유지
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

        // 지금 뜨는 쇼핑 라이브 공고
        SectionContainer(
          title: ColoredTitle(
            blackText: '쇼핑 라이브 공고',
            purpleText: '지금 뜨는 ',
            purpleFirst: true,
          ),
          onMorePressed: () => GoRouter.of(context).go('/recruits'),
          child: _buildScheduleSection(context, viewModel.schedules),
        ),
        const SizedBox(height: 18),

        // 브랜드 pick
        SectionContainer(
          title: ColoredTitle(
            blackText: '브랜드 ',
            purpleText: 'pick',
          ),
          onMorePressed: () => GoRouter.of(context).go('/recruits'),
          child: RecruitSection(recruits: viewModel.recruits),
        ),
        const SizedBox(height: 18),

        // 라이비 뉴스
        SectionContainer(
          title: ColoredTitle(
            blackText: '라이비 ',
            purpleText: '뉴스',
          ),
          onMorePressed: () => GoRouter.of(context).go('/news'),
          child: const NewsSection(),
        ),
        const SizedBox(height: 18),

        // 이런 쇼호스트는 어떠세요?
        SectionContainer(
          title: ColoredTitle(
            blackText: '는 어떠세요?',
            purpleText: '이런 쇼호스트',
            purpleFirst: true,
          ),
          onMorePressed: () => GoRouter.of(context).go('/showhosts'),
          child: FeaturedShowhostSection(showhosts: viewModel.featuredShowhosts),
        ),
        const SizedBox(height: 18),

        // 'HOT clip' 섹션 (자체 헤더를 사용하므로 SectionContainer 미적용)
        const HotClipSection(),
        const SizedBox(height: 18),

        // '무료 상담' 섹션 (별도 디자인이므로 SectionContainer 미적용)
        const ConsultationSection(),
      ],
    );
  }

  /// '지금 뜨는 쇼핑 라이브 공고' 섹션 UI를 구성하는 메소드
  Widget _buildScheduleSection(BuildContext context, List<Campaign> schedules) {
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
          // [리팩토링] 기존 Container 디자인을 StandardContentCard로 교체
          return StandardContentCard(
            onTap: () => GoRouter.of(context).push('/campaign/${campaign.id}'),
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
