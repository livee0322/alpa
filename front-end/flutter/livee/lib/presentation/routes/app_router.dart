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
import 'package:provider/provider.dart';

// GoRouter 인스턴스
final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/login',
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
    // AuthProvider의 인스턴스를 가져오기
    // main.dart에 등록된 Provider가 변경될 때마다 이 redirect 로직이 다시 실행
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final isLoggedIn = authProvider.isLoggedIn;

    // 로그인 없이 접근 가능한 페이지 목록 정의
    final publicRoutes = ['/login', '/signup', '/', '/recruits'];

    // 현재 이동하려는 경로가 공개 경로인지 확인
    final isGoingToPublic = publicRoutes.contains(state.uri.toString());

    // 사용자가 로그인하지 않았고, 비공개 경로로 가려고 할 때만 로그인 페이지로 리디렉션
    if (!isLoggedIn && !isGoingToPublic) {
      return '/login';
    }

    // 로그인한 사용자가 로그인/회원가입 페이지로 가려고 할 때 메인 페이지로 리디렉션
    if (isLoggedIn &&
        (state.uri.toString() == '/login' ||
            state.uri.toString() == '/signup')) {
      return '/';
    }

    // 그 외의 모든 경우는 리디렉션하지 않음 (null 반환)
    return null;
  },
);
