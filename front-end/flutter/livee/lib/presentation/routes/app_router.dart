import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/account/account_edit_screen.dart';
import 'package:livee/presentation/screens/campaign/applicant_list_screen.dart';
import 'package:livee/presentation/screens/main/root_shell_screen.dart';
import 'package:livee/presentation/screens/main/top_bar_shell_screen.dart';
import 'package:livee/presentation/screens/model/model_detail_screen.dart';
import 'package:livee/presentation/screens/model/model_edit_screen.dart';
import 'package:livee/presentation/screens/model/model_screen.dart';
import 'package:livee/presentation/screens/portfolio/portfolio_screen.dart';
import 'package:livee/presentation/screens/recruit/bookmarked_recruits_screen.dart';
import 'package:livee/presentation/screens/campaign/detail/campaign_detail_screen.dart';
import 'package:livee/presentation/screens/campaign/form/campaign_form_screen.dart';
import 'package:livee/presentation/screens/campaign/campaigns_screen.dart';
import 'package:livee/presentation/screens/showhost/casting_request_screen.dart';
import 'package:livee/presentation/screens/showhost/my_portfolio_list_screen.dart';
import 'package:livee/presentation/screens/showhost/portfolio_detail_screen.dart';
import 'package:livee/presentation/screens/event/event_screen.dart';
import 'package:livee/presentation/screens/auth/login_screen.dart';
import 'package:livee/presentation/screens/home/home_screen.dart';
import 'package:livee/presentation/screens/recruit/my_applications_screen.dart';
import 'package:livee/presentation/screens/account/mypage_screen.dart';
import 'package:livee/presentation/screens/news/news_screen.dart';
import 'package:livee/presentation/screens/portfolio/portfolio_edit_screen.dart';
import 'package:livee/presentation/screens/recruit/received_offers_screen.dart';
import 'package:livee/presentation/screens/recruit/recruit_list_screen.dart';
import 'package:livee/presentation/screens/service/service_screen.dart';
import 'package:livee/presentation/screens/live/shopping_live_screen.dart';
import 'package:livee/presentation/screens/clips/short_clips_screen.dart';
import 'package:livee/presentation/screens/auth/signup_screen.dart';
import 'package:livee/presentation/screens/studio/studio_edit_screen.dart';
import 'package:livee/presentation/screens/studio/studio_screen.dart';

// GoRouter 인스턴스를 생성
// AuthProvider를 인자로 받아서 refreshListenable에 연결
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    // refreshListenable에 외부에서 생성된 AuthProvider 인스턴스를 전달받아 사용
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/studio/:studioId',
        builder: (context, state) {
          final studioId = state.pathParameters['studioId']!;
          return StudioScreen(studioId: studioId);
        },
      ),
      GoRoute(
        path: '/studio-edit',
        builder: (context, state) => const StudioEditScreen(),
      ),
      // 네비게이션 포함한 앱 전체를 감싸는 최상위 하단 ShellRoute
      ShellRoute(
        builder: (context, state, child) => RootShellScreen(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          // 상단 바가 필요한 페이지 ShellRoute
          ShellRoute(
            builder: (context, state, child) => TopBarShellScreen(
              location: state.uri.toString(),
              child: child,
            ),
            routes: [
              // 상단 탭바가 필요한 페이지들을 이 곳으로 이동
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/clips',
                builder: (context, state) => const ShortClipsScreen(),
              ),
              GoRoute(
                path: '/live',
                builder: (context, state) => const ShoppingLiveScreen(),
              ),
              GoRoute(
                path: '/news',
                builder: (context, state) => const NewsScreen(),
              ),
              GoRoute(
                path: '/event',
                builder: (context, state) => const EventScreen(),
              ),
              GoRoute(
                path: '/service',
                builder: (context, state) => const ServiceScreen(),
              ),
              GoRoute(
                path: '/recruits',
                builder: (context, state) => const RecruitListScreen(),
              ),
              GoRoute(
                path: '/models',
                builder: (context, state) => const ModelScreen(),
              ),
              GoRoute(
                path: '/portfolios',
                builder: (context, state) => const PortfolioScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final portfolioId = state.pathParameters['id']!;
                      return PortfolioDetailScreen(portfolioId: portfolioId);
                    },
                  ),
                ],
              ),
// ...
            ],
          ),
          // 상단 바는 없지만 하단 바는 필요한 페이지들을 여기에 배치
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: '/mypage',
            builder: (context, state) => const MypageScreen(),
          ),
          // 상세 페이지들도 모두 RootShellRoute의 자식으로 두기
          GoRoute(
            path: '/campaigns',
            builder: (context, state) => const CampaignsScreen(),
          ),
          GoRoute(
            path: '/campaign-form',
            builder: (context, state) =>
                CampaignFormScreen(campaignId: state.extra as String?),
          ),
          GoRoute(
            path: '/campaign/:campaignId',
            builder: (context, state) {
              final campaignId = state.pathParameters['campaignId']!;
              return CampaignDetailScreen(campaignId: campaignId);
            },
            routes: [
              GoRoute(
                path: 'applicants',
                builder: (context, state) {
                  final campaignId = state.pathParameters['campaignId']!;
                  return ApplicantListScreen(campaignId: campaignId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/portfolios/:id',
            builder: (context, state) {
              final portfolioId = state.pathParameters['id']!;
              return PortfolioDetailScreen(portfolioId: portfolioId);
            },
          ),
          GoRoute(
            path: '/portfolio-edit',
            builder: (context, state) =>
                PortfolioEditScreen(portfolioId: state.extra as String?),
          ),
          GoRoute(
            path: '/models',
            builder: (context, state) => const ModelScreen(),
            routes: [
              GoRoute(
                path: ':id', // 예: /models/123
                builder: (context, state) {
                  final modelId = state.pathParameters['id']!;
                  return ModelDetailScreen(modelId: modelId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/my-portfolios',
            builder: (context, state) => const MyPortfolioListScreen(),
          ),
          GoRoute(
            path: '/bookmarked-recruits',
            builder: (context, state) => const BookmarkedRecruitsScreen(),
          ),
          GoRoute(
            path: '/received-offers',
            builder: (context, state) => const ReceivedOffersScreen(),
          ),
          GoRoute(
            path: '/account-edit',
            builder: (context, state) => const AccountEditScreen(),
          ),
          GoRoute(
            path: '/model-edit',
            builder: (context, state) => const ModelEditScreen(),
          ),
          GoRoute(
            path: '/my-applications',
            builder: (context, state) => const MyApplicationsScreen(),
          ),
          GoRoute(
            path: '/casting-request',
            builder: (context, state) {
              final showhostId = state.extra as String;
              return CastingRequestScreen(showhostId: showhostId);
            },
          ),
        ],
      ),
    ],
    redirect: (context, GoRouterState state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final location = state.uri.toString();

      // 로그인한 사용자가 로그인/회원가입 페이지로 가려고 하면 메인으로 리디렉션
      if (isLoggedIn && (location == '/login' || location == '/signup')) {
        return '/';
      }

      // 그 외의 경우는 모두 허용 (접근 제어는 UI 단에서 처리)
      return null;
    },
  );
}
