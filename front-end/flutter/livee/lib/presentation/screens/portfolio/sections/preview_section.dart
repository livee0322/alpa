import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/portfolio/models/portfolio_image.dart';
import 'package:livee/presentation/styles/app_colors.dart';

// 포트폴리오의 프로필/배경 이미지 및 닉네임 미리보기 섹션
class PreviewSection extends StatelessWidget {
  final PortfolioImage? mainThumbnailSource;
  final PortfolioImage? backgroundImageSource;
  final TextEditingController nicknameController;
  final VoidCallback onPickMainThumbnail;
  final VoidCallback onPickBackgroundImage;

  const PreviewSection({
    super.key,
    required this.mainThumbnailSource,
    required this.backgroundImageSource,
    required this.nicknameController,
    required this.onPickMainThumbnail,
    required this.onPickBackgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    // 현재 화면의 세로 길이를 가져오기
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // 배경 이미지의 높이를 화면 높이의 1/5로 계산
    final backgroundHeight = screenHeight / 4;
    return SizedBox(
      height: backgroundHeight, // 전체 위젯 높이 조정
      child: Stack(
        clipBehavior: Clip.none, // 자식 위젯이 부모를 벗어날 수 있도록 설정
        children: [
          // 1. 배경 이미지 영역
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: backgroundHeight,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(12),
                image: backgroundImageSource != null
                    ? DecorationImage(
                        // localBytes와 networkUrl을 모두 처리
                        image: (backgroundImageSource!.localBytes != null
                            ? MemoryImage(backgroundImageSource!.localBytes!)
                            : NetworkImage(backgroundImageSource!.networkUrl!)) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),

          // 2. 프로필 이미지 업로드 영역
          Positioned(
            bottom: 20,
            left: 24,
            child: SizedBox(
              width: screenWidth - 64,
              // color: Colors.red,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: onPickMainThumbnail,
                    borderRadius: BorderRadius.circular(999),
                    // [리팩토링] 아이콘을 원 안으로 넣기 위해 구조를 수정합니다.
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.disabled,
                        backgroundImage: mainThumbnailSource != null
                            ? (mainThumbnailSource!.localBytes != null
                                ? MemoryImage(mainThumbnailSource!.localBytes!)
                                : NetworkImage(mainThumbnailSource!.networkUrl!)) as ImageProvider
                            : null,
                        // [수정] CircleAvatar의 child를 사용하여 아이콘을 내부에 배치합니다.
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_photo_alternate, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  // 3. 닉네임 및 한 줄 소개 텍스트
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: nicknameController,
                    builder: (context, value, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value.text.isNotEmpty ? value.text : '닉네임',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '한 줄 소개', // 이 부분은 ViewModel의 oneLineIntroController와 연결할 수 있습니다.
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      );
                    },
                  ),

                  Spacer(),

                  // 4. 배경 이미지 업로드 버튼
                  InkWell(
                    onTap: onPickBackgroundImage,
                    borderRadius: BorderRadius.circular(999),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey[700],
                      child: const Icon(Icons.image_outlined, color: Colors.white, size: 24),
                    ),
                  ),

                  SizedBox(width: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
