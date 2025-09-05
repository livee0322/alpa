import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/models/portfolio_image.dart';

class PortfolioSubThumbnailSection extends StatelessWidget {
  final List<PortfolioImage> sources;
  final VoidCallback onAddImage;
  final Function(int) onRemoveImage;

  const PortfolioSubThumbnailSection({
    super.key,
    required this.sources,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sources.length + (sources.length < 5 ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        if (index == sources.length && sources.length < 5) {
          return InkWell(
            onTap: onAddImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
            ),
          );
        }

        final imageSource = sources[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageSource.localBytes != null)
                Image.memory(imageSource.localBytes!, fit: BoxFit.cover)
              else if (imageSource.networkUrl != null)
                Image.network(imageSource.networkUrl!, fit: BoxFit.cover),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => onRemoveImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
