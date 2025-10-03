import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/dialog/cropper_overlay_painter.dart';
import 'package:livee/presentation/widgets/vm/custom_cropper_view_model.dart';
import 'package:provider/provider.dart';

/// 이미지를 자를 수 있는 커스텀 다이얼로그 위젯
class CustomCropperDialog extends StatelessWidget {
  final XFile imageFile;
  final double aspectRatio;

  const CustomCropperDialog({
    super.key,
    required this.imageFile,
    this.aspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CustomCropperViewModel(
        context: context,
        imageFile: imageFile,
        aspectRatio: aspectRatio,
      ),
      child: Consumer<CustomCropperViewModel>(
        builder: (context, viewModel, child) {
          final screenSize = MediaQuery.of(context).size;
          final cropSize = screenSize.width * 0.8;
          final cropHeight = cropSize / aspectRatio;

          return Dialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: screenSize.width,
                        height: screenSize.height * 0.6,
                        child: FutureBuilder<Uint8List>(
                          future: viewModel.imageBytes, // ViewModel의 데이터 사용
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return Stack(
                              children: [
                                InteractiveViewer(
                                  transformationController: viewModel
                                      .transformationController, // ViewModel의 컨트롤러 사용
                                  maxScale: 5.0,
                                  child: Center(
                                      child: Image.memory(snapshot.data!)),
                                ),
                                IgnorePointer(
                                  child: Center(
                                    child: CustomPaint(
                                      painter: CropperOverlayPainter(
                                        cropSize: Size(cropSize, cropHeight),
                                        isCircle: aspectRatio == 1.0,
                                      ),
                                      child: SizedBox(
                                          width: cropSize, height: cropHeight),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('취소'),
                          ),
                          ElevatedButton(
                            onPressed: viewModel.isCropping
                                ? null
                                : viewModel.cropAndPop, // ViewModel의 함수 및 상태 사용
                            child: viewModel.isCropping
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text('자르기'),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
