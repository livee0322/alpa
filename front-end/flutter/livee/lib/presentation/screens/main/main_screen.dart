import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/models/news_article.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/news_repository.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/main/widgets/consultation_section.dart';
import 'package:livee/presentation/screens/main/widgets/featured_showhost_section.dart';
import 'package:livee/presentation/screens/main/widgets/news_section.dart';
import 'package:livee/presentation/screens/main/widgets/recruit_section.dart';
import 'package:livee/presentation/widgets/colored_title.dart';
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
  List<Portfolio> _featuredShowhosts = [];
  // List<NewsArticle> _newsArticles = [];
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
      final portfolioRepository = locator<PortfolioRepository>();
      // final newsRepository = NewsRepository();
      // 여러 API를 동시에 호출하여 성능 향상
      final results = await Future.wait([
        campaignUseCase.getAllCampaigns(type: 'recruit', limit: 6),
        campaignUseCase.getAllCampaigns(type: 'recruit', limit: 10),
        portfolioRepository.getPublicPortfolios(limit: 5),
        // newsRepository.getLiveCommerceNews(limit: 3),
      ]);
      setState(() {
        _schedules = results[0] as List<Campaign>;
        _recruits = results[1] as List<Campaign>;
        _featuredShowhosts = results[2] as List<Portfolio>;
        // _newsArticles = results[3] as List<NewsArticle>;
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
        backgroundColor: Color(0xFFF6F7F9),
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
          blackTitle: '쇼핑 라이브 공고',
          purpleTitle: '지금 뜨는 ',
          purpleFirst: true,
          onTap: () => GoRouter.of(context).go('/schedule'),
        ),
        _buildScheduleSection(),
        const SizedBox(height: 18),
        _buildSectionHeader(
          blackTitle: '브랜드 ',
          purpleTitle: 'pick',
          onTap: () => GoRouter.of(context).go('/schedule'),
        ),
        RecruitSection(recruits: _recruits),

        // 라이비 뉴스 섹션
        const SizedBox(height: 18),
        _buildSectionHeader(
          blackTitle: '라이비 ',
          purpleTitle: '뉴스',
          onTap: () {
            // TODO: 뉴스 전체 목록 페이지로 이동
          },
        ),
        // NewsSection(articles: _newsArticles),
        NewsSection(),
        const SizedBox(height: 18),

        _buildSectionHeader(
          blackTitle: '는 어떠세요?',
          purpleTitle: '이런 쇼호스트',
          purpleFirst: true,
          onTap: () {
            // TODO: 쇼호스트 전체 목록 페이지로 이동
          },
        ),
        FeaturedShowhostSection(showhosts: _featuredShowhosts),

        const SizedBox(height: 18),

        // 무료 상담 섹션
        const ConsultationSection(),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String blackTitle,
    required String purpleTitle,
    bool purpleFirst = false,
    VoidCallback? onTap,
  }) {
    return Padding(
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
      children: items.map(
        (campaign) {
          // 마감일 및 출연료 텍스트를 가공하는 로직
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
                    // 캠페인의 커버 이미지를 사용하고, 없을 경우 대체 이미지를 표시
                    campaign.coverImageUrl ?? 'https://picsum.photos/seed/schedule${campaign.id}/96/96',
                    width: 60,
                    height: 60,
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
                        campaign.brand ?? '브랜드',
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 제목
                      Text(
                        campaign.title ?? '제목 없음',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // 촬영 시간
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
