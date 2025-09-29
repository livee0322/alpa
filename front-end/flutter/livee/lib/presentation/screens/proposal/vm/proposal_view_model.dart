import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livee/domain/models/portfolio.dart';

/// '제안 보내기' 바텀시트의 상태와 비즈니스 로직을 관리
class ProposalViewModel with ChangeNotifier {
  /// 제안을 받을 대상의 포트폴리오 정보
  final Portfolio portfolio;

  /// 생성자: 제안 대상의 정보를 필수로 받기
  ProposalViewModel({required this.portfolio});

  // --- 상태 변수 ---

  /// 로딩 상태 (API 통신 시 사용)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Form 입력을 위한 컨트롤러
  final formKey = GlobalKey<FormState>();
  final brandNameController = TextEditingController();
  final feeController = TextEditingController();
  final shootingTimeController = TextEditingController();
  final locationController = TextEditingController();
  final contentController = TextEditingController();

  /// 출연료 협의 가능 여부
  bool _isFeeNegotiable = false;
  bool get isFeeNegotiable => _isFeeNegotiable;

  /// 촬영일과 답장 기한
  DateTime? _shootingDate;
  DateTime? get shootingDate => _shootingDate;
  DateTime? _replyDeadline;
  DateTime? get replyDeadline => _replyDeadline;

  // --- 상태 변경 메소드 ---

  /// 로딩 상태를 변경하고 UI에 알립니다. (내부 사용)
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// '협의' 체크박스 상태를 변경하고 UI에 알리기
  void toggleFeeNegotiable(bool? value) {
    _isFeeNegotiable = value ?? false;
    // '협의'가 체크되면 출연료 입력 필드를 비우기
    if (_isFeeNegotiable) {
      feeController.clear();
    }
    notifyListeners();
  }

  /// 날짜 선택(DatePicker)을 처리하는 함수
  /// isShootingDate 값에 따라 촬영일 또는 답장 기한 상태를 업데이트
  Future<void> selectDate(BuildContext context, {required bool isShootingDate}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // 오늘부터 선택 가능
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (isShootingDate) {
        _shootingDate = pickedDate;
      } else {
        _replyDeadline = pickedDate;
      }
      notifyListeners(); // 날짜가 선택되면 UI를 갱신
    }
  }

  // --- 주요 로직 ---

  /// '보내기' 버튼을 눌렀을 때 실행될 제안 제출 로직
  Future<void> submitProposal() async {
    // 1. Form 유효성 검사
    if (!formKey.currentState!.validate()) {
      return;
    }

    _setLoading(true);
    try {
      // 2. 입력된 데이터를 Map 형태로 가공
      final proposalData = {
        'targetPortfolioId': portfolio.id,
        'brandName': brandNameController.text,
        'fee': int.tryParse(feeController.text),
        'isFeeNegotiable': _isFeeNegotiable,
        'shootingDate': _shootingDate?.toIso8601String(),
        'shootingTime': shootingTimeController.text,
        'location': locationController.text,
        'replyDeadline': _replyDeadline?.toIso8601String(),
        'content': contentController.text,
      };

      // 3. TODO: 4단계에서 UseCase를 통해 서버 API를 호출
      print('서버로 전송될 데이터: $proposalData');
      await Future.delayed(const Duration(seconds: 1)); // 임시 비동기 처리

      // 4. 성공 처리 (예: 바텀시트 닫기, 성공 토스트 메시지)
    } catch (e) {
      // 5. 실패 처리 (예: 에러 토스트 메시지)
    } finally {
      _setLoading(false);
    }
  }

  /// 날짜를 'YYYY-MM-DD' 형식의 문자열로 변환하는 헬퍼 함수
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  void dispose() {
    // ViewModel이 소멸될 때 컨트롤러들을 정리하여 메모리 누수를 방지
    brandNameController.dispose();
    feeController.dispose();
    shootingTimeController.dispose();
    locationController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
