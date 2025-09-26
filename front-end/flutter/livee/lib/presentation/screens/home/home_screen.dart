import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/home/sections/concept_model_section.dart';
import 'package:livee/presentation/screens/home/sections/footer_section.dart';
import 'package:livee/presentation/screens/home/sections/schedule_section.dart';
import 'package:livee/presentation/screens/home/sections/banner_slider_section.dart';
import 'package:livee/presentation/screens/home/sections/consultation_section.dart';
import 'package:livee/presentation/screens/home/sections/featured_showhost_section.dart';
import 'package:livee/presentation/screens/home/sections/hot_clip_section.dart';
import 'package:livee/presentation/screens/home/sections/news_section.dart';
import 'package:livee/presentation/screens/home/sections/recruit_section.dart';
import 'package:livee/presentation/screens/home/vm/home_view_model.dart';
import 'package:livee/presentation/screens/main/widgets/section_container.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/colored_title.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

/// 메인 화면
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => HomeViewModel(),
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) => LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: SingleChildScrollView(
              child: _buildBody(context, viewModel),
            ),
          ),
        ),
      );

  /// 화면 본문을 빌드하는 헬퍼 메소드
  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(
          child: Text("데이터를 불러오는 데 실패했습니다: ${viewModel.errorMessage}"));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BannerSliderSection(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 지금 뜨는 쇼핑 라이브 공고
              SectionContainer(
                title: ColoredTitle(
                  blackText: '쇼핑 라이브 공고',
                  purpleText: '지금 뜨는 ',
                  purpleFirst: true,
                ),
                onMorePressed: () => GoRouter.of(context).go('/recruits'),
                child: ScheduleSection(schedules: viewModel.schedules),
              ),

              // 브랜드 pick
              SectionContainer(
                title: ColoredTitle(
                  blackText: '브랜드 ',
                  purpleText: 'PICK',
                ),
                onMorePressed: () => GoRouter.of(context).go('/recruits'),
                child: RecruitSection(recruits: viewModel.recruits),
              ),

              // 라이비 뉴스
              SectionContainer(
                title: ColoredTitle(
                  blackText: '라이비 ',
                  purpleText: '뉴스',
                ),
                onMorePressed: () => GoRouter.of(context).go('/news'),
                child: NewsSection(news: viewModel.news),
              ),

              // "이런 쇼호스트는 어떠세요?" 섹션
              SectionContainer(
                title: ColoredTitle(
                  blackText: '는 어떠세요?',
                  purpleText: '이런 쇼호스트',
                  purpleFirst: true,
                ),
                // onMorePressed: () => GoRouter.of(context).go('/showhosts'),
                child: FeaturedShowhostListSection(
                    models: viewModel.featuredShowhosts),
              ),

              // "컨셉에 맞는 모델 찾기" 섹션
              SectionContainer(
                title: ColoredTitle(
                  blackText: '컨셉에 맞는 ',
                  purpleText: '모델 찾기',
                ),
                onMorePressed: () => GoRouter.of(context).go('/models'),
                child: ConceptModelSection(models: viewModel.conceptModels),
              ),

              // 'HOT clip' 섹션
              SectionContainer(
                title: const Text.rich(
                  TextSpan(
                    text: 'HOT ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                    children: [
                      TextSpan(
                        text: 'CLIP',
                        style: TextStyle(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                onMorePressed: () => GoRouter.of(context).go('/clips'),
                child: const HotClipSection(),
              ),

              // '무료 상담' 섹션 (별도 디자인이므로 SectionContainer 미적용)
              const ConsultationSection(),

              // [추가] 5:1 비율의 광고 배너를 추가합니다.
              const SizedBox(height: 24), // 상담 섹션과의 간격
              InkWell(
                onTap: () =>
                    GoRouter.of(context).go('/studio/68d5496374657fbb21213e7b'),
                borderRadius: BorderRadius.circular(12.0), // 물결 효과를 위해 추가
                child: AspectRatio(
                  aspectRatio: 5 / 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'assets/images/banner_03.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24), // 상담 섹션과의 간격
            ],
          ),
        ),
        FooterSection(),
      ],
    );
  }
}
