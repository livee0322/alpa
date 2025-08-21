import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/campaign_detail_screen.dart';
import 'package:livee/presentation/screens/campaign_form_screen.dart';
import 'package:livee/presentation/screens/campaigns_screen.dart';
import 'package:livee/presentation/screens/login_screen.dart';
import 'package:livee/presentation/screens/main_screen.dart';
import 'package:livee/presentation/screens/mypage_screen.dart';
import 'package:livee/presentation/screens/recruit_list_screen.dart';
import 'package:livee/presentation/screens/signup_screen.dart';

// GoRouter 인스턴스를 생성
// AuthProvider를 인자로 받아서 refreshListenable에 연결
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/login',
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
        builder: (context, state) =>
            CampaignFormScreen(campaignId: state.extra as String?),
      ),
      GoRoute(
        path: '/campaign/:campaignId',
        builder: (context, state) {
          final campaignId = state.pathParameters['campaignId']!;
          return CampaignDetailScreen(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: '/recruits',
        builder: (context, state) => const RecruitListScreen(),
      ),
    ],
    redirect: (context, state) {
      // redirect 내부에서는 listen: false로 현재 상태만 읽기
      final isLoggedIn = authProvider.isLoggedIn;

      final publicRoutes = ['/login', '/signup', '/', '/recruits'];
      final isGoingToPublic = publicRoutes.contains(state.uri.toString());

      if (!isLoggedIn && !isGoingToPublic) {
        return '/login';
      }
      if (isLoggedIn &&
          (state.uri.toString() == '/login' ||
              state.uri.toString() == '/signup')) {
        return '/';
      }
      return null;
    },
  );
}
