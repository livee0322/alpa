import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/repositories/auth_repository.dart';
import 'package:livee/domain/repositories/campaign_repository.dart';
import 'package:livee/domain/usecases/auth_use_case.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';
import 'package:livee/presentation/providers/recruit_list_provider.dart';
import 'package:livee/presentation/routes/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  // 웹 주소(URL)에서 '#' 문자를 제거하여 깨끗한 경로를 사용
  usePathUrlStrategy();

  // 주요 의존성 인스턴스를 미리 생성
  final authRepository = AuthRepository();
  final authUseCase = AuthUseCase(authRepository);
  final campaignRepository = CampaignRepository();
  final campaignUseCase = CampaignUseCase(campaignRepository);

  // AuthProvider 인스턴스를 생성
  final authProvider = AuthProvider(authUseCase);

  // 3. 생성된 AuthProvider를 createRouter 함수에 전달하여 GoRouter 인스턴스를 생성
  final router = createRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider는 이미 위에서 생성했으므로, 그 인스턴스를 그대로 사용
        ChangeNotifierProvider.value(value: authProvider),

        // 다른 Provider들은 기존과 동일하게 등록
        Provider.value(value: campaignRepository),
        Provider.value(value: campaignUseCase),
        ChangeNotifierProvider(
          create: (context) => CampaignFormProvider(
            campaignUseCase,
            campaignRepository,
            ApiClient(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RecruitListProvider(
            campaignUseCase,
          ),
        ),
      ],
      // 4. MyApp 위젯에는 생성된 router를 전달
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
