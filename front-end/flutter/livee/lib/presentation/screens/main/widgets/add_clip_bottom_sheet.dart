import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/clips/vm/short_clips_view_model.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:provider/provider.dart';

// 숏클립 추가 바텀시트를 화면에 표시
Future<bool?> showAddClipBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<ShortClipsViewModel>(),
      child: const AddClipBottomSheet(),
    ),
  );
}

/// 숏클립을 추가하는 UI를 담당하는 바텀시트 위젯
class AddClipBottomSheet extends StatelessWidget {
  const AddClipBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ShortClipsViewModel>();
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
            _buildTitleField(viewModel),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: viewModel.descriptionController,
              label: '설명 (선택)',
            ),
            const SizedBox(height: 24),
            PrimaryActionButton(
              text: '저장',
              isLoading: viewModel.isSaving,
              onPressed: () async {
                final success = await viewModel.submitClip();
                if (context.mounted) {
                  if (success) {
                    Navigator.pop(context, true); // 성공 시 true 반환
                    showCustomToast(context, '숏클립이 추가되었습니다.',
                        type: ToastType.success);
                  } else {
                    showCustomToast(context, '저장에 실패했습니다. URL을 확인해주세요.',
                        type: ToastType.error);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 바텀시트의 헤더 UI
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('+ 숏클립 추가',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // 제목 입력 필드와 정보 가져오기 버튼 UI
  Widget _buildTitleField(ShortClipsViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomTextFormField(
              controller: viewModel.titleController, label: '제목 (선택)'),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 28.0), // 라벨 높이에 맞춰 패딩 추가
          child: OutlinedButton.icon(
            icon: Icon(Icons.public, size: 18),
            label: const Text('알 수 없음'),
            onPressed: viewModel.isScraping ? null : viewModel.scrapeUrl,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
