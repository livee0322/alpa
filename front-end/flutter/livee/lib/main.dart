import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';
import 'package:livee/presentation/providers/recruit_list_provider.dart';
import 'package:livee/presentation/providers/showhost_list_provider.dart';
import 'package:livee/presentation/routes/app_router.dart';
import 'package:livee/service_locator.dart';
import 'package:provider/provider.dart';

void main() {
  // 웹 주소(URL)에서 '#' 문자를 제거하여 깨끗한 경로를 사용
  usePathUrlStrategy();

  // 앱 시작 전 서비스 로케이터 설정 실행
  setupLocator();

  // GetIt을 통해 AuthProvider 인스턴스 가져오기
  final authProvider = locator<AuthProvider>();

  // 라우터를 생성
  final router = createRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        // 각 Provider를 GetIt을 통해 생성하도록 변경
        ChangeNotifierProvider(create: (_) => locator<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => locator<CampaignFormProvider>()),
        ChangeNotifierProvider(create: (_) => locator<RecruitListProvider>()),
        ChangeNotifierProvider(create: (_) => locator<ShowhostListProvider>()),

        // Repository나 UseCase는 이제 Provider가 직접 locator에서 가져오므로 여기서 등록할 필요 없음
      ],
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  // 생성자를 통해 GoRouter 인스턴스를 전달
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '라이비',
      theme: ThemeData(
        fontFamily: 'NEXONLv1',
        scaffoldBackgroundColor: Colors.white,
      ),
      // 전달받은 router 인스턴스를 routerConfig에 설정
      routerConfig: router,
    );
  }
}
