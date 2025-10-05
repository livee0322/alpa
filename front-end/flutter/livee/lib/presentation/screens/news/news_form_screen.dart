import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/presentation/screens/news/vm/news_form_view_model.dart';
import 'package:livee/presentation/common/buttons/primary_action_button.dart';
import 'package:livee/presentation/common/custom_text_form_field.dart';
import 'package:livee/presentation/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class NewsFormScreen extends StatelessWidget {
  final String? newsId;
  const NewsFormScreen({super.key, this.newsId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsFormViewModel(context, newsId: newsId),
      child: Consumer2<NewsFormViewModel, ImageHandlerProvider>(
        builder: (context, viewModel, imageHandler, child) {
          return Scaffold(
            // [수정] LoadingOverlay가 두 Provider의 로딩 상태를 모두 감지
            body: LoadingOverlay(
              isLoading: viewModel.isLoading || imageHandler.isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          viewModel.isEditing ? '뉴스 수정 페이지' : '뉴스 등록 페이지',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CustomTextFormField(
                        controller: viewModel.titleController,
                        label: '제목',
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildImageUploader(viewModel),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: viewModel.contentController,
                        label: '내용',
                        isRequired: true,
                        maxLines: 15,
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PrimaryActionButton(
                          text: '저장',
                          onPressed: viewModel.submitNews,
                          isFullWidth: false,
                          isLoading: viewModel.isLoading,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 이미지 업로더 UI를 구성하는 위젯
  Widget _buildImageUploader(NewsFormViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('대표 이미지', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          // [수정] ViewModel의 pickAndUploadImage 메서드를 호출하는 것은 동일합니다.
          // 내부 로직이 ImageHandlerProvider를 사용하도록 변경되었을 뿐입니다.
          onTap: viewModel.pickAndUploadImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: viewModel.imageUrl != null
                  ? DecorationImage(image: NetworkImage(viewModel.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: viewModel.imageUrl == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('박스를 클릭하여 이미지를 등록해주세요.'),
                      ],
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
