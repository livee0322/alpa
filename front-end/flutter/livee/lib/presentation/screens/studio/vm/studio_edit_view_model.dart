import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/models/portfolio_image.dart';

/// '스튜디오 등록' 페이지의 상태와 로직을 관리하는 ViewModel
class StudioEditViewModel with ChangeNotifier {
  // --- 이미지 관련 상태 변수 ---
  PortfolioImage? mainThumbnailSource;
  PortfolioImage? backgroundImageSource;
  final List<PortfolioImage> subThumbnailSources = [];

  // --- 텍스트 입력 필드 컨트롤러 ---
  final brandNameController = TextEditingController();
  final oneLineIntroController = TextEditingController();
  final detailedIntroController = TextEditingController();
  final usageInfoController = TextEditingController();
  final priceInfoController = TextEditingController();

  // TODO: 연락처, 주소, 스케줄 관련 컨트롤러 및 상태 변수 추가

  // --- 메소드 ---
  void setMainThumbnail(PortfolioImage source) {
    mainThumbnailSource = source;
    notifyListeners();
  }

  void setBackgroundImage(PortfolioImage source) {
    backgroundImageSource = source;
    notifyListeners();
  }

  void addSubThumbnail(PortfolioImage source) {
    if (subThumbnailSources.length < 5) {
      subThumbnailSources.add(source);
      notifyListeners();
    }
  }

  void removeSubThumbnail(int index) {
    subThumbnailSources.removeAt(index);
    notifyListeners();
  }

  @override
  void dispose() {
    brandNameController.dispose();
    oneLineIntroController.dispose();
    detailedIntroController.dispose();
    usageInfoController.dispose();
    priceInfoController.dispose();
    super.dispose();
  }
}
