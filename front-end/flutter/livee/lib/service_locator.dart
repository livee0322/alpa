import 'package:get_it/get_it.dart';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/repositories/application_repository.dart';
import 'package:livee/domain/repositories/auth_repository.dart';
import 'package:livee/domain/repositories/campaign_repository.dart';
import 'package:livee/domain/repositories/clip_repository.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/domain/usecases/application_use_case.dart';
import 'package:livee/domain/usecases/auth_use_case.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/domain/usecases/clip_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';
import 'package:livee/presentation/providers/recruit_list_provider.dart';
import 'package:livee/presentation/providers/showhost_list_provider.dart';

// 전역으로 사용할 GetIt 인스턴스 생성
final locator = GetIt.instance;

// 서비스 로케이터를 설정하는 함수
void setupLocator() {
  // CORE
  locator.registerLazySingleton(() => ApiClient());

  // REPOSITORIES
  locator.registerLazySingleton(() => AuthRepository());
  locator.registerLazySingleton(() => CampaignRepository());
  locator.registerLazySingleton(() => PortfolioRepository());
  locator.registerLazySingleton(() => ApplicationRepository());
  locator.registerLazySingleton(() => ClipRepository());

  // USECASES
  locator.registerLazySingleton(() => AuthUseCase(locator<AuthRepository>()));
  locator.registerLazySingleton(() => CampaignUseCase(locator<CampaignRepository>()));
  locator.registerLazySingleton(() => ApplicationUseCase(locator<ApplicationRepository>()));
  locator.registerLazySingleton(() => ClipUseCase(locator<ClipRepository>()));

  // PROVIDERS
  // Provider는 상태를 가지므로, 매번 새로운 인스턴스를 생성하는 factory로 등록
  locator.registerFactory(() => AuthProvider());
  locator.registerFactory(() => CampaignFormProvider());
  locator.registerFactory(() => RecruitListProvider());
  locator.registerFactory(() => ShowhostListProvider());
}
