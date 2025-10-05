import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:livee/data/core/api_error_parser.dart';
import 'package:livee/domain/usecases/model_use_case.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/presentation/screens/portfolio/models/portfolio_image.dart';
import 'package:livee/presentation/screens/portfolio/vm/profile_edit_view_model_base.dart';
import 'package:livee/presentation/common/custom_toast.dart';
import 'package:livee/service_locator.dart';
import 'package:universal_html/html.dart' as html;

// '모델 등록/수정' 화면의 상태와 로직을 관리하는 ViewModel
class ModelEditViewModel with ChangeNotifier implements ProfileEditViewModelBase {
  // --- 의존성 주입 및 초기화 ---
  final ImageHandlerProvider _imageHandlerProvider = locator<ImageHandlerProvider>();
  final ModelUseCase _modelUseCase = locator<ModelUseCase>();
  final BuildContext context;
  final String? modelId;

  ModelEditViewModel(this.context, {this.modelId}) {
    // TODO: 수정 모드일 경우 모델 데이터 로딩 로직 추가
  }

  // --- 상태 변수 ---
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  bool get isLoading => _isLoading;
  bool get isEditing => modelId != null;

  // 이미지 및 파일 관련
  @override
  PortfolioImage? mainThumbnailSource;
  @override
  PortfolioImage? backgroundImageSource;
  @override
  final List<PortfolioImage> subThumbnailSources = [];
  @override
  String? attachedFileUrl;
  @override
  String? attachedFileName;
  Uint8List? _tempAttachedFileBytes;

  // 컨트롤러
  @override
  final nicknameController = TextEditingController();
  @override
  final oneLineIntroController = TextEditingController();
  @override
  final detailedIntroController = TextEditingController();
  @override
  final experienceYearsController = TextEditingController();
  @override
  final ageController = TextEditingController();
  @override
  final regionController = TextEditingController();
  @override
  final detailedRegionController = TextEditingController();
  @override
  final heightController = TextEditingController();
  @override
  final weightController = TextEditingController();
  @override
  final topSizeController = TextEditingController();
  @override
  final bottomSizeController = TextEditingController();
  @override
  final shoeSizeController = TextEditingController();
  @override
  final websiteUrlController = TextEditingController();
  @override
  final instagramUrlController = TextEditingController();
  @override
  final youtubeUrlController = TextEditingController();
  @override
  final tiktokUrlController = TextEditingController();

  // 설정값
  String _publicScope = '전체공개';
  String? _gender;
  bool _isReceivingOffers = true;
  bool _isAgePublic = false;
  bool _isSizingPublic = false;
  bool _isExperiencePublic = false;
  bool _isRegionPublic = false;
  bool _isGenderPublic = false;
  bool _isHeightPublic = false;

  @override
  String get publicScope => _publicScope;
  @override
  String? get gender => _gender;
  @override
  bool get isReceivingOffers => _isReceivingOffers;
  @override
  bool get isAgePublic => _isAgePublic;
  @override
  bool get isSizingPublic => _isSizingPublic;
  @override
  bool get isExperiencePublic => _isExperiencePublic;
  @override
  bool get isRegionPublic => _isRegionPublic;
  @override
  bool get isGenderPublic => _isGenderPublic;
  @override
  bool get isHeightPublic => _isHeightPublic;

  // --- 상태 변경 메소드 ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void setPublicScope(String? value) {
    if (value != null) {
      _publicScope = value;
      notifyListeners();
    }
  }

  @override
  void setIsReceivingOffers(bool? value) {
    _isReceivingOffers = value ?? true;
    notifyListeners();
  }

  @override
  void setGender(String? value) {
    _gender = value == '선택 안함' ? null : value;
    notifyListeners();
  }

  @override
  void removeSubThumbnail(int index) {
    subThumbnailSources.removeAt(index);
    notifyListeners();
  }

  @override
  void setIsAgePublic(bool? value) {
    _isAgePublic = value ?? false;
    notifyListeners();
  }

  @override
  void setIsSizingPublic(bool? value) {
    _isSizingPublic = value ?? false;
    notifyListeners();
  }

  @override
  void setIsExperiencePublic(bool? value) {
    _isExperiencePublic = value ?? false;
    notifyListeners();
  }

  @override
  void setIsRegionPublic(bool? value) {
    _isRegionPublic = value ?? false;
    notifyListeners();
  }

  @override
  void setIsGenderPublic(bool? value) {
    _isGenderPublic = value ?? false;
    notifyListeners();
  }

  @override
  void setIsHeightPublic(bool? value) {
    _isHeightPublic = value ?? false;
    notifyListeners();
  }

  // --- 기능 함수 ---
  @override
  Future<void> pickFileForCache() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['hwp', 'doc', 'docx', 'ppt', 'pptx', 'pdf']);
    if (result != null && result.files.single.bytes != null) {
      _tempAttachedFileBytes = result.files.single.bytes;
      attachedFileName = result.files.single.name;
      attachedFileUrl = null;
      notifyListeners();
    }
  }

  @override
  void removeAttachedFile() {
    attachedFileUrl = null;
    attachedFileName = null;
    _tempAttachedFileBytes = null;
    notifyListeners();
  }

  /// 모델 데이터를 서버에 저장하는 핵심 로직
  Future<void> saveModel() async {
    if (!formKey.currentState!.validate()) return;
    _setLoading(true);

    try {
      String? finalAttachedFileUrl = attachedFileUrl;
      if (_tempAttachedFileBytes != null) {
        finalAttachedFileUrl =
            await _imageHandlerProvider.uploadImage(_tempAttachedFileBytes!, fileName: attachedFileName, type: 'raw');
      }
      String? finalMainThumbUrl = mainThumbnailSource?.networkUrl;
      if (mainThumbnailSource?.localBytes != null) {
        finalMainThumbUrl = await _imageHandlerProvider.uploadImage(mainThumbnailSource!.localBytes!);
      }
      String? finalBackgroundUrl = backgroundImageSource?.networkUrl;
      if (backgroundImageSource?.localBytes != null) {
        finalBackgroundUrl = await _imageHandlerProvider.uploadImage(backgroundImageSource!.localBytes!);
      }
      final List<String> finalSubUrls = [];
      for (final source in subThumbnailSources) {
        if (source.localBytes != null) {
          final newUrl = await _imageHandlerProvider.uploadImage(source.localBytes!);
          if (newUrl != null) finalSubUrls.add(newUrl);
        } else if (source.networkUrl != null) {
          finalSubUrls.add(source.networkUrl!);
        }
      }

      String? genderPayload;
      if (_gender == '남성') {
        genderPayload = 'male';
      } else if (_gender == '여성') {
        genderPayload = 'female';
      }

      final Map<String, dynamic> payload = {
        'nickname': nicknameController.text,
        'oneLineIntro': oneLineIntroController.text,
        'detailedIntro': detailedIntroController.text,
        'experienceYears': int.tryParse(experienceYearsController.text),
        'age': int.tryParse(ageController.text),
        'region': regionController.text,
        'detailedRegion': detailedRegionController.text,
        'gender': genderPayload,
        'height': int.tryParse(heightController.text),
        'weight': int.tryParse(weightController.text),
        'topSize': topSizeController.text,
        'bottomSize': bottomSizeController.text,
        'shoeSize': int.tryParse(shoeSizeController.text),
        'websiteUrl': websiteUrlController.text,
        'instagramUrl': instagramUrlController.text,
        'youtubeUrl': youtubeUrlController.text,
        'tiktokUrl': tiktokUrlController.text,
        'publicScope': _publicScope,
        'isReceivingOffers': _isReceivingOffers,
        'isAgePublic': _isAgePublic,
        'isSizingPublic': _isSizingPublic,
        'isExperiencePublic': _isExperiencePublic,
        'isRegionPublic': _isRegionPublic,
        'isGenderPublic': _isGenderPublic,
        'isHeightPublic': _isHeightPublic,
        'mainThumbnailUrl': finalMainThumbUrl,
        'backgroundImageUrl': finalBackgroundUrl,
        'subThumbnailUrls': finalSubUrls,
        'attachedFileUrl': finalAttachedFileUrl,
      };

      if (modelId == null) {
        await _modelUseCase.createModel(payload);
      } else {
        // await _modelUseCase.updateModel(modelId!, payload); // TODO: 추후 수정 기능 구현
      }

      showCustomToast(context, '모델 프로필이 성공적으로 저장되었습니다.', type: ToastType.success);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        html.window.history.go(-1);
      });
    } catch (e) {
      showCustomToast(context, '저장 실패: ${parseApiError(e)}', type: ToastType.error);
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    nicknameController.dispose();
    oneLineIntroController.dispose();
    detailedIntroController.dispose();
    experienceYearsController.dispose();
    ageController.dispose();
    regionController.dispose();
    detailedRegionController.dispose();
    heightController.dispose();
    weightController.dispose();
    topSizeController.dispose();
    bottomSizeController.dispose();
    shoeSizeController.dispose();
    websiteUrlController.dispose();
    instagramUrlController.dispose();
    youtubeUrlController.dispose();
    tiktokUrlController.dispose();
    super.dispose();
  }
}
