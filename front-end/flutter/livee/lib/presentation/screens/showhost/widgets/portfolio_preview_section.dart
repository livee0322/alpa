import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/models/portfolio_image.dart';

class PortfolioPreviewSection extends StatelessWidget {
  final PortfolioImage? mainThumbnailSource;
  final PortfolioImage? backgroundImageSource;
  final TextEditingController nicknameController;
  final VoidCallback onPickMainThumbnail;
  final VoidCallback onPickBackgroundImage;

  const PortfolioPreviewSection({
    super.key,
    required this.mainThumbnailSource,
    required this.backgroundImageSource,
    required this.nicknameController,
    required this.onPickMainThumbnail,
    required this.onPickBackgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          // 배경 이미지 영역
          SizedBox(
            height: 200,
            width: double.infinity,
            child: InkWell(
              onTap: onPickBackgroundImage,
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  // 이미지가 없을 때의 배경색 변경
                  color: const Color(0xFFE3F2FD),
                  child: backgroundImageSource == null
                      ? _buildPlaceholder(Icons.add_photo_alternate_outlined)
                      : (backgroundImageSource!.localBytes != null
                          ? Image.memory(
                              backgroundImageSource!.localBytes!,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              backgroundImageSource!.networkUrl!,
                              fit: BoxFit.cover,
                            )),
                ),
              ),
            ),
          ),
          // 메인 썸네일 및 닉네임 영역
          Positioned(
            left: 16,
            top: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: onPickMainThumbnail,
                  borderRadius: BorderRadius.circular(40),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFF7F8FA),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      backgroundImage: mainThumbnailSource?.networkUrl != null
                          ? NetworkImage(mainThumbnailSource!.networkUrl!)
                          : (mainThumbnailSource?.localBytes != null
                              ? MemoryImage(mainThumbnailSource!.localBytes!)
                              : null) as ImageProvider?,
                      child: mainThumbnailSource == null
                          ? _buildPlaceholder(
                              Icons.add_a_photo_outlined,
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 닉네임 텍스트 필드의 값을 실시간으로 보여줌
                Column(
                  children: [
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: nicknameController,
                      builder: (context, value, child) {
                        return Text(
                          value.text.isNotEmpty ? value.text : '닉네임',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon, {double size = 32}) {
    return Center(
      child: Icon(icon, size: size, color: Colors.grey.shade400),
    );
  }
}
