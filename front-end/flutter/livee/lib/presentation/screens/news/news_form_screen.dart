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
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 전체 좌측 정렬
                    children: [
                      // [추가] 페이지 상단에 제목을 추가합니다.
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
                      _buildImageUploader(viewModel), // 이미지 업로더 위젯 호출
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: viewModel.contentController,
                        label: '내용',
                        isRequired: true,
                        maxLines: 15,
                      ),
                      const SizedBox(height: 24),
                      // [추가] 저장 버튼을 내용 섹션 아래, 오른쪽 정렬로 배치합니다.
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
        // [수정] InkWell로 감싸서 터치 이벤트를 감지하도록 합니다.
        InkWell(
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
            // [수정] 이미지가 없을 때만 안내 텍스트와 아이콘을 표시합니다.
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
        // [삭제] 기존의 '이미지 선택 및 업로드' 버튼은 제거합니다.
      ],
    );
  }
}
