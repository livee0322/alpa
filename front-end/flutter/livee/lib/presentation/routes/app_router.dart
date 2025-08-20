import 'package:go_router/go_router.dart';
import 'package:livee/domain/repositories/auth_repository.dart';
import 'package:livee/domain/usecases/auth_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/campaign_form_screen.dart';
import 'package:livee/presentation/screens/campaigns_screen.dart';
import 'package:livee/presentation/screens/login_screen.dart';
import 'package:livee/presentation/screens/main_screen.dart';
import 'package:livee/presentation/screens/mypage_screen.dart';
import 'package:livee/presentation/screens/recruit_form_screen.dart';
import 'package:livee/presentation/screens/signup_screen.dart';
import 'package:provider/provider.dart';

// GoRouter 인스턴스
final GoRouter router = GoRouter(
  initialLocation: '/',
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
      path: '/campaigns',
      builder: (context, state) => const CampaignsScreen(),
    ),
    GoRoute(
      path: '/campaign-form',
      builder: (context, state) => CampaignFormScreen(campaignId: state.extra as String?),
    ),
    GoRoute(
      path: '/recruit-form',
      builder: (context, state) => RecruitFormScreen(recruitId: state.extra as String?),
    ),
  ],
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;

    final loggingIn = state.uri.toString() == '/login';
    final signingUp = state.uri.toString() == '/signup';
    final goingToProtected = state.uri.toString() == '/mypage';

    if (!isLoggedIn) {
      return (loggingIn || signingUp) ? null : '/login';
    }

    if (loggingIn || signingUp) {
      return '/';
    }

    return null;
  },

  // authProvider의 상태 변경을 감지하여 리디렉션을 재실행하도록 설정
  refreshListenable: AuthProvider(AuthUseCase(AuthRepository())),
);
