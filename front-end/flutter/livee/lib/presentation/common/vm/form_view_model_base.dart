import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/data/core/api_error_parser.dart';
import 'package:livee/presentation/common/custom_toast.dart';

/// 등록/수정 등 폼(Form)을 사용하는 모든 ViewModel이 상속받아야 할 추상 클래스
abstract class FormViewModelBase with ChangeNotifier {
  // --- 공통 상태 및 속성 ---
  final BuildContext context;
  final String? id; // 수정 모드일 경우 데이터의 고유 ID

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- Getter ---
  bool get isLoading => _isLoading;
  bool get isEditing => id != null;

  // --- 생성자 ---
  FormViewModelBase({required this.context, this.id}) {
    // 수정 모드일 경우, 생성과 동시에 데이터 로딩을 시작
    // 위젯이 빌드된 후 loadDataForEdit를 호출하여 안전하게 context를 사용
    if (isEditing) WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  // --- 추상 메소드 (하위 클래스가 반드시 구현해야 함) ---

  /// 서버에서 기존 데이터를 불러와 폼을 채우는 로직
  Future<void> loadDataForEdit();

  /// 입력된 데이터를 서버에 저장(생성/수정)하는 로직
  Future<void> onSave();

  // --- 공통 기능 메소드 ---

  /// 로딩 상태를 안전하게 변경하고 UI에 알림
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 수정 모드일 때 데이터를 불러오는 내부 메소드 (에러 처리 포함)
  Future<void> _loadData() async {
    _setLoading(true);
    try {
      await loadDataForEdit();
    } catch (e) {
      if (context.mounted) showCustomToast(context, '데이터를 불러오는 데 실패했습니다: ${parseApiError(e)}', type: ToastType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// '저장' 버튼을 눌렀을 때 실행되는 표준화된 프로세스
  Future<void> submit() async {
    // 1. 폼 유효성 검사
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      // 2. 각 ViewModel에 구현된 실제 저장 로직 호출
      await onSave();

      // 3. 성공 처리
      if (context.mounted) {
        showCustomToast(context, '성공적으로 저장되었습니다.', type: ToastType.success);
        // 이전 페이지로 이동
        context.pop();
      }
    } catch (e) {
      // 4. 실패 처리
      if (context.mounted) showCustomToast(context, '저장 실패: ${parseApiError(e)}', type: ToastType.error);
    } finally {
      // 5. 로딩 종료
      _setLoading(false);
    }
  }
}
