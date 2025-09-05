import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/models/portfolio_image.dart';

class PortfolioPreviewSection extends StatelessWidget {
  final PortfolioImage? mainThumbnailSource;
  final PortfolioImage? backgroundImageSource;
  final VoidCallback onPickMainThumbnail;
  final VoidCallback onPickBackgroundImage;

  const PortfolioPreviewSection({
    super.key,
    required this.mainThumbnailSource,
    required this.backgroundImageSource,
    required this.onPickMainThumbnail,
    required this.onPickBackgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF374151),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    );

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildImagePreview(
                    source: mainThumbnailSource,
                    placeholderIcon: Icons.person_outline,
                    height: 120,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: const Text('메인 썸네일'),
                      onPressed: onPickMainThumbnail,
                      style: buttonStyle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _buildImagePreview(
                    source: backgroundImageSource,
                    placeholderIcon: Icons.landscape_outlined,
                    height: 120,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.panorama_outlined, size: 18),
                      label: const Text('배경 이미지'),
                      onPressed: onPickBackgroundImage,
                      style: buttonStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview({
    required PortfolioImage? source,
    required IconData placeholderIcon,
    required double height,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(12) : null,
      ),
      child: ClipRRect(
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(11)
            : BorderRadius.circular(height / 2),
        child: source == null
            ? Icon(placeholderIcon, color: Colors.grey, size: 48)
            : (source.localBytes != null
                ? Image.memory(source.localBytes!, fit: BoxFit.cover)
                : Image.network(source.networkUrl!, fit: BoxFit.cover)),
      ),
    );
  }
}
