import 'package:flutter/material.dart';
import 'package:livee/domain/usecases/news_use_case.dart';
import 'package:livee/presentation/common/vm/form_view_model_base.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/service_locator.dart';

/// '뉴스 등록/수정' 폼의 상태와 로직을 관리
class NewsFormViewModel extends FormViewModelBase {
  final NewsUseCase _newsUseCase = locator<NewsUseCase>();
  final ImageHandlerProvider _imageHandlerProvider = locator<ImageHandlerProvider>();

  // --- 상태 변수 ---

  // 컨트롤러
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String? imageUrl;

  // 생성자에서 부모 클래스의 생성자를 호출
  NewsFormViewModel({required super.context, String? newsId}) : super(id: newsId);

  /// 기존 뉴스 데이터를 불러와 폼에 채우는 메소드
  @override
  Future<void> loadDataForEdit() async {
    final news = await _newsUseCase.getNewsById(id!);
    titleController.text = news.title;
    contentController.text = news.content;
    imageUrl = news.imageUrl;
  }

  /// 이미지를 선택하고 Cloudinary에 업로드하는 메소드
  Future<void> pickAndUploadImage() async {
    final imageBytes = await _imageHandlerProvider.pickImage();
    if (imageBytes == null) return;

    try {
      final url = await _imageHandlerProvider.uploadImage(imageBytes);
      imageUrl = url;
    } catch (e) {
      // 에러 처리는 부모 클래스의 submit()에서 담당하므로 여기서는 rethrow
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // 기존 submitNews의 내용을 부모 클래스의 추상 메소드인 onSave에 구현
  @override
  Future<void> onSave() async {
    final payload = {
      'title': titleController.text,
      'content': contentController.text,
      'imageUrl': imageUrl,
    };

    if (isEditing) {
      await _newsUseCase.updateNews(id!, payload);
    } else {
      await _newsUseCase.createNews(payload);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
