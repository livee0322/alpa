import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/di_container.dart';
import 'package:livee/presentation/routes/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  // 웹 주소(URL)에서 '#' 문자를 제거하여 깨끗한 경로를 사용
  usePathUrlStrategy();

  // DiContainer에서 AuthProvider 인스턴스를 가져옴
  final authProvider = DiContainer.authProvider;

  // 라우터를 생성
  final router = createRouter(authProvider);

  runApp(
    MultiProvider(
      // DiContainer에서 전체 Provider 목록을 가져와 설정
      providers: DiContainer.providers,
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
      title: 'Livee',
      // 전달받은 router 인스턴스를 routerConfig에 설정
      routerConfig: router,
    );
  }
}
