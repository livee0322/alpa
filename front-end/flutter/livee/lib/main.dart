import 'package:flutter/material.dart';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/repositories/auth_repository.dart';
import 'package:livee/domain/repositories/campaign_repository.dart';
import 'package:livee/domain/usecases/auth_use_case.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';
import 'package:livee/presentation/routes/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Auth Providers
        Provider(create: (_) => AuthRepository()),
        Provider(
          create: (context) => AuthUseCase(
            context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<AuthUseCase>(),
          ),
        ),
        // Campaign Providers
        Provider(create: (_) => CampaignRepository()),
        Provider(
          create: (context) => CampaignUseCase(
            context.read<CampaignRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CampaignFormProvider(
            context.read<CampaignUseCase>(),
            context.read<CampaignRepository>(),
            ApiClient(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Livee',
      routerConfig: router,
    );
  }
}
