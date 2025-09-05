import 'dart:typed_data';

// 로컬 파일과 네트워크 URL을 구분하기 위한 헬퍼 클래스
class PortfolioImage {
  final Uint8List? localBytes;
  final String? networkUrl;

  PortfolioImage({this.localBytes, this.networkUrl});
}
