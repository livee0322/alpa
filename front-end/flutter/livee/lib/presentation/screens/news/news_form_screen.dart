import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/news/vm/news_form_view_model.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class NewsFormScreen extends StatelessWidget {
  final String? newsId;
  const NewsFormScreen({super.key, this.newsId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsFormViewModel(context, newsId: newsId),
      child: Consumer<NewsFormViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.isEditing ? '뉴스 수정' : '뉴스 작성'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: PrimaryActionButton(
                    text: '저장',
                    onPressed: viewModel.submitNews,
                    isFullWidth: false,
                    isLoading: viewModel.isLoading,
                  ),
                )
              ],
            ),
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    children: [
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

  Widget _buildImageUploader(NewsFormViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('대표 이미지', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            image: viewModel.imageUrl != null
                ? DecorationImage(image: NetworkImage(viewModel.imageUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: viewModel.imageUrl == null ? const Center(child: Text('이미지를 등록해주세요.')) : null,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: viewModel.pickAndUploadImage,
            icon: const Icon(Icons.image),
            label: const Text('이미지 선택 및 업로드'),
          ),
        ),
      ],
    );
  }
}
