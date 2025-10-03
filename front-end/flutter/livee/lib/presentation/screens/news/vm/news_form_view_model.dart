import 'package:flutter/material.dart';
import 'package:livee/data/core/api_error_parser.dart';
import 'package:livee/domain/usecases/news_use_case.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:livee/service_locator.dart';
import 'package:universal_html/html.dart' as html;

/// '뉴스 등록/수정' 폼의 상태와 로직을 관리
class NewsFormViewModel with ChangeNotifier {
  final NewsUseCase _newsUseCase = locator<NewsUseCase>();
  final ImageHandlerProvider _imageHandlerProvider =
      locator<ImageHandlerProvider>();
  final String? newsId;
  final BuildContext context;

  NewsFormViewModel(this.context, {this.newsId}) {
    if (isEditing) {
      loadNewsForEdit();
    }
  }

  // --- 상태 변수 ---
  final formKey = GlobalKey<FormState>();
  bool get isEditing => newsId != null;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 컨트롤러
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String? imageUrl;

  /// 기존 뉴스 데이터를 불러와 폼에 채우는 메소드
  Future<void> loadNewsForEdit() async {
    _setLoading(true);
    try {
      final news = await _newsUseCase.getNewsById(newsId!);
      titleController.text = news.title;
      contentController.text = news.content;
      imageUrl = news.imageUrl;
    } catch (e) {
      showCustomToast(context, '뉴스 정보를 불러오는 데 실패했습니다.', type: ToastType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// 이미지를 선택하고 Cloudinary에 업로드하는 메소드
  Future<void> pickAndUploadImage() async {
    // 1. ImageHandlerProvider를 통해 이미지 선택
    final imageBytes = await _imageHandlerProvider.pickImage(context: context);
    if (imageBytes == null) return;

    // 2. ImageHandlerProvider를 통해 이미지 업로드
    try {
      final url = await _imageHandlerProvider.uploadImage(imageBytes);
      imageUrl = url;
    } catch (e) {
      showCustomToast(context, '이미지 업로드 실패: $e', type: ToastType.error);
    } finally {
      // ImageHandlerProvider가 로딩 상태를 관리하므로 별도의 setLoading이 필요 없을 수 있으나,
      // UI 동기화를 위해 notifyListeners()를 호출해줍니다.
      notifyListeners();
    }
  }

  /// 폼 데이터를 서버에 전송하는 메소드
  Future<void> submitNews() async {
    if (!formKey.currentState!.validate()) return;
    _setLoading(true);

    final payload = {
      'title': titleController.text,
      'content': contentController.text,
      'imageUrl': imageUrl,
    };

    try {
      if (isEditing) {
        await _newsUseCase.updateNews(newsId!, payload);
      } else {
        await _newsUseCase.createNews(payload);
      }
      showCustomToast(context, '뉴스가 성공적으로 저장되었습니다.', type: ToastType.success);
      html.window.history.go(-1); // 이전 페이지로 이동
    } catch (e) {
      showCustomToast(context, '저장 실패: ${parseApiError(e)}',
          type: ToastType.error);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
