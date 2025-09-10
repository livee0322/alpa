import 'package:flutter/widgets.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/usecases/application_use_case.dart';
import 'package:livee/service_locator.dart';

/// 지원자 목록 화면의 상태와 로직을 관리하는 ViewModel
class ApplicantListViewModel with ChangeNotifier {
  final ApplicationUseCase _applicationUseCase = locator<ApplicationUseCase>();
  final String campaignId;

  ApplicantListViewModel({required this.campaignId}) {
    fetchApplicants();
  }

  bool _isLoading = true;
  List<Portfolio> _applicants = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Portfolio> get applicants => _applicants;
  String? get errorMessage => _errorMessage;

  Future<void> fetchApplicants() async {
    _isLoading = true;
    notifyListeners();
    try {
      _applicants = await _applicationUseCase.getApplicantsForCampaign(campaignId);
    } catch (e) {
      _errorMessage = '지원자 목록을 불러오는 데 실패했습니다.';
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
