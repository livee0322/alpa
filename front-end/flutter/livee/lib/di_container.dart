import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/repositories/auth_repository.dart';
import 'package:livee/domain/repositories/campaign_repository.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/domain/usecases/auth_use_case.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';
import 'package:livee/presentation/providers/recruit_list_provider.dart';
import 'package:livee/presentation/providers/showhost_list_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// 앱 전체에서 사용될 의존성(객체)들을 설정하고 제공하는 클래스
class DiContainer {
  /// 데이터 계층 (Repositories)
  static final AuthRepository _authRepository = AuthRepository();
  static final CampaignRepository _campaignRepository = CampaignRepository();
  static final PortfolioRepository _portfolioRepository = PortfolioRepository();

  /// 비즈니스 로직 계층 (UseCases)
  static final AuthUseCase _authUseCase = AuthUseCase(_authRepository);
  static final CampaignUseCase _campaignUseCase = CampaignUseCase(_campaignRepository);

  /// 프레젠테이션 계층 (Providers)
  static AuthProvider get authProvider => AuthProvider(_authUseCase);

  /// MultiProvider에 등록할 전체 Provider 목록을 반환
  static List<SingleChildWidget> get providers {
    return [
      ChangeNotifierProvider(
        create: (context) => authProvider,
      ),
      Provider.value(value: _campaignRepository),
      Provider.value(value: _campaignUseCase),
      ChangeNotifierProvider(
        create: (context) => CampaignFormProvider(
          _campaignUseCase,
          ApiClient(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => RecruitListProvider(_campaignUseCase),
      ),
      Provider.value(value: _portfolioRepository),
      ChangeNotifierProvider(
        create: (context) => ShowhostListProvider(_portfolioRepository),
      ),
    ];
  }
}
