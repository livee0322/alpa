import 'package:flutter/material.dart';
import 'package:livee/presentation/common/common_image_picker.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/presentation/screens/news/vm/news_form_view_model.dart';
import 'package:livee/presentation/common/buttons/primary_action_button.dart';
import 'package:livee/presentation/common/custom_text_form_field.dart';
import 'package:livee/presentation/common/loading_overlay.dart';
import 'package:livee/presentation/screens/portfolio/models/portfolio_image.dart';
import 'package:provider/provider.dart';

class NewsFormScreen extends StatelessWidget {
  final String? newsId;
  const NewsFormScreen({super.key, this.newsId});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => NewsFormViewModel(context: context, newsId: newsId),
        child: Consumer2<NewsFormViewModel, ImageHandlerProvider>(
          builder: (context, viewModel, imageHandler, child) => Scaffold(
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
                          onPressed: viewModel.submit,
                          isFullWidth: false,
                          isLoading: viewModel.isLoading,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// 이미지 업로더 UI를 구성하는 위젯
  Widget _buildImageUploader(NewsFormViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '대표 이미지',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        CommonImagePicker(
          aspectRatio: 16 / 9,
          imageSource: PortfolioImage(networkUrl: viewModel.imageUrl),
          placeholder: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                SizedBox(height: 8),
                Text('박스를 클릭하여 이미지를 등록해주세요.'),
              ],
            ),
          ),
          onTap: viewModel.pickAndUploadImage,
        ),
      ],
    );
  }
}
