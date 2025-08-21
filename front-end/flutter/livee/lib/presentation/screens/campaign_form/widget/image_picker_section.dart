import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';

// 대표 썸네일 이미지 선택 및 업로드를 담당하는 위젯
class ImagePickerSection extends StatelessWidget {
  final CampaignFormProvider provider;

  const ImagePickerSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 이미지 미리보기 영역
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: provider.imageUrlController.text.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    provider.imageUrlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text(
                        '이미지를 불러올 수 없습니다.',
                      ),
                    ),
                  ),
                )
              : const Center(child: Text('이미지 미리보기')),
        ),
        const SizedBox(height: 10),
        // 이미지 선택 및 업로드 버튼
        ElevatedButton(
          onPressed:
              provider.isLoading ? null : () => _pickAndUploadImage(context),
          child: provider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('이미지 선택 및 업로드'),
        ),
      ],
    );
  }

  // 이미지 선택 및 업로드 로직
  Future<void> _pickAndUploadImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      provider.setLoading(true);
      try {
        final url = await CloudinaryUploader().uploadImage(
            result.files.single.bytes!,
            fileName: result.files.single.name);
        provider.imageUrlController.text = url;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
        }
      } finally {
        provider.setLoading(false);
      }
    }
  }
}
