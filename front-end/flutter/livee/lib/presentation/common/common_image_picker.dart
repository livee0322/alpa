import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/portfolio/models/portfolio_image.dart';
import 'package:livee/presentation/styles/app_colors.dart';

/// 이미지 선택 및 미리보기 UI를 담당하는 공통 위젯
class CommonImagePicker extends StatelessWidget {
  /// 이미지를 선택하는 동작을 실행할 콜백 함수
  final VoidCallback onTap;

  /// 표시할 이미지 소스 (네트워크 URL 또는 로컬 바이트 데이터)
  final PortfolioImage? imageSource;

  /// 이미지의 가로세로 비율
  final double aspectRatio;

  /// 이미지가 없을 때 표시될 placeholder 위젯
  final Widget placeholder;

  const CommonImagePicker({
    super.key,
    required this.onTap,
    this.imageSource,
    this.aspectRatio = 1.0,
    this.placeholder = const Center(
      child: Icon(Icons.add_a_photo_outlined, color: AppColors.textGrey),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: _buildImagePreview(),
          ),
        ),
      ),
    );
  }

  /// imageSource의 상태에 따라 적절한 이미지 위젯 또는 placeholder를 반환
  Widget _buildImagePreview() {
    // 1. 로컬에서 새로 선택한 이미지가 있으면 보여줌
    if (imageSource?.localBytes != null) {
      return Image.memory(imageSource!.localBytes!, fit: BoxFit.cover);
    }
    // 2. 기존에 업로드된 네트워크 이미지가 있으면 보여줌
    if (imageSource?.networkUrl != null && imageSource!.networkUrl!.isNotEmpty) {
      return Image.network(imageSource!.networkUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) {
        return placeholder;
      });
    }
    // 3. 아무 이미지도 없으면 placeholder를 보여줌
    return placeholder;
  }
}
