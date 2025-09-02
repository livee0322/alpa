import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/account/account_edit_screen.dart';
import 'package:livee/presentation/screens/campaign/applicant_list_screen.dart';
import 'package:livee/presentation/screens/recruit/bookmarked_recruits_screen.dart';
import 'package:livee/presentation/screens/campaign/detail/campaign_detail_screen.dart';
import 'package:livee/presentation/screens/campaign/form/campaign_form_screen.dart';
import 'package:livee/presentation/screens/campaign/campaigns_screen.dart';
import 'package:livee/presentation/screens/showhost/casting_request_screen.dart';
import 'package:livee/presentation/screens/tabs/event_screen.dart';
import 'package:livee/presentation/screens/auth/login_screen.dart';
import 'package:livee/presentation/screens/main/main_screen.dart';
import 'package:livee/presentation/screens/recruit/my_applications_screen.dart';
import 'package:livee/presentation/screens/account/mypage_screen.dart';
import 'package:livee/presentation/screens/tabs/news_screen.dart';
import 'package:livee/presentation/screens/showhost/portfolio_edit_screen.dart';
import 'package:livee/presentation/screens/recruit/received_offers_screen.dart';
import 'package:livee/presentation/screens/recruit/recruit_list_screen.dart';
import 'package:livee/presentation/screens/tabs/service_screen.dart';
import 'package:livee/presentation/screens/tabs/shopping_live_screen.dart';
import 'package:livee/presentation/screens/tabs/short_clips_screen.dart';
import 'package:livee/presentation/screens/showhost/showhost_detail_screen.dart';
import 'package:livee/presentation/screens/showhost/showhost_list_screen.dart';
import 'package:livee/presentation/screens/auth/signup_screen.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';

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
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
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
      GoRoute(
        path: '/campaigns',
        builder: (context, state) => const CampaignsScreen(),
      ),
      GoRoute(
        path: '/campaign-form',
        builder: (context, state) => CampaignFormScreen(campaignId: state.extra as String?),
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
        path: '/recruits',
        builder: (context, state) => const RecruitListScreen(),
      ),
      GoRoute(
        path: '/portfolio-edit',
        builder: (context, state) => const PortfolioEditScreen(),
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
        path: '/my-applications',
        builder: (context, state) => const MyApplicationsScreen(),
      ),
      GoRoute(
        path: '/showhosts',
        builder: (context, state) => const ShowhostListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final showhostId = state.pathParameters['id']!;
              return ShowhostDetailScreen(showhostId: showhostId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/casting-request',
        builder: (context, state) {
          final showhostId = state.extra as String;
          return CastingRequestScreen(showhostId: showhostId);
        },
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
    ],
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final role = authProvider.role;
      final location = state.uri.toString();

      final brandOnlyRoutes = ['/campaigns', '/campaign-form', '/casting-request'];
      final showhostOnlyRoutes = ['/portfolio-edit', '/my-applications', '/bookmarked-recruits', '/received-offers'];
      final authRequiredRoutes = brandOnlyRoutes + showhostOnlyRoutes + ['/mypage', '/account-edit'];

      if (authRequiredRoutes.any((route) => location.startsWith(route))) {
        if (!isLoggedIn) {
          // showCustomToast 함수 사용
          showCustomToast(context, '로그인이 필요한 서비스입니다.');
          return '/';
        }

        if (brandOnlyRoutes.any((route) => location.startsWith(route)) && role != 'brand') {
          showCustomToast(context, '브랜드 회원만 이용 가능합니다.', type: ToastType.error);
          return '/';
        }

        if (showhostOnlyRoutes.any((route) => location.startsWith(route)) && role != 'showhost') {
          showCustomToast(context, '쇼호스트 회원만 이용 가능합니다.', type: ToastType.error);
          return '/';
        }
      }

      if (isLoggedIn && (location == '/login' || location == '/signup')) {
        return '/';
      }

      return null;
    },
  );
}
