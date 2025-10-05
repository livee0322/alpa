import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/clips/vm/add_clip_view_model.dart';
import 'package:livee/presentation/common/buttons/primary_action_button.dart';
import 'package:livee/presentation/common/custom_text_form_field.dart';
import 'package:livee/presentation/common/custom_toast.dart';
import 'package:provider/provider.dart';

// 숏클립 추가 바텀시트를 화면에 표시
Future<bool?> showAddClipBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => AddClipViewModel(),
      child: const AddClipBottomSheet(),
    ),
  );
}

/// 숏클립을 추가하는 UI를 담당하는 바텀시트 위젯
class AddClipBottomSheet extends StatelessWidget {
  const AddClipBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddClipViewModel>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              CustomTextFormField(
                controller: viewModel.urlController,
                label: '링크(URL)',
                hintText: 'YouTube / Instagram / TikTok 링크를 붙여넣기',
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: viewModel.titleController,
                label: '제목 (선택)',
                hintText: '입력하지 않으면 자동 스크래핑됩니다.',
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: viewModel.descriptionController,
                label: '설명 (선택)',
              ),
              const SizedBox(height: 24),
              PrimaryActionButton(
                text: '저장',
                isLoading: viewModel.isSaving,
                // [수정] 버튼 활성화 조건을 ViewModel의 isSubmitButtonEnabled 상태와 연결합니다.
                // 로딩 중일 때도 비활성화 처리합니다.
                onPressed: viewModel.isSubmitButtonEnabled && !viewModel.isSaving
                    ? () async {
                        // [수정] submitClip 메소드의 반환값(에러 메시지 또는 null)을 확인합니다.
                        final errorMessage = await viewModel.submitClip();
                        if (context.mounted) {
                          if (errorMessage == null) {
                            // 성공(null) 시: 성공 토스트와 함께 창을 닫습니다.
                            Navigator.pop(context, true);
                            showCustomToast(context, '숏클립이 추가되었습니다.', type: ToastType.success);
                          } else {
                            // 실패(에러 메시지) 시: 받은 메시지로 에러 토스트를 표시합니다.
                            showCustomToast(context, errorMessage, type: ToastType.error);
                          }
                        }
                      }
                    : null, // 조건이 맞지 않으면 버튼을 비활성화합니다.
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 바텀시트의 헤더 UI
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('숏클립 추가', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
