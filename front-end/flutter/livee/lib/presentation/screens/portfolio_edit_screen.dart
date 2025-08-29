import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/custom_cropper_dialog.dart';

// 쇼호스트가 자신의 포트폴리오를 등록/수정하는 화면
class PortfolioEditScreen extends StatefulWidget {
  const PortfolioEditScreen({super.key});

  @override
  State<PortfolioEditScreen> createState() => _PortfolioEditScreenState();
}

class _PortfolioEditScreenState extends State<PortfolioEditScreen> {
  // 폼과 텍스트 필드 컨트롤러
  final _formKey = GlobalKey<FormState>();
  final _introductionController = TextEditingController();
  final _careerController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();

  // 이미지 상태 관리
  String? _profileImageUrl;
  String? _backgroundImageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _introductionController.dispose();
    _careerController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  /// --- [수정] 이미지 선택 -> 크롭 다이얼로그 -> 업로드 로직 ---
  Future<void> _pickCropAndUploadImage({
    required double aspectRatio,
    required Function(String) onImageUploaded,
  }) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // 1. 커스텀 크롭 다이얼로그를 띄우고, 잘린 이미지 데이터(Uint8List)를 받음
    if (!mounted) return;
    final Uint8List? croppedBytes = await showDialog(
      context: context,
      builder: (context) => CustomCropperDialog(
        imageFile: pickedFile,
        aspectRatio: aspectRatio,
      ),
    );

    if (croppedBytes == null) return;

    // 2. 잘린 이미지를 서버에 업로드
    setState(() => _isLoading = true);
    try {
      final newUrl = await CloudinaryUploader().uploadImage(croppedBytes);
      setState(() {
        onImageUploaded(newUrl);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드 실패: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 포트폴리오 관리'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 이미지 선택 영역
              _buildImageSection(),
              // 텍스트 입력 폼 영역
              _buildFormSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  // 이미지 선택 영역 (배경, 프로필) 위젯
  Widget _buildImageSection() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 배경 이미지
        InkWell(
          onTap: _isLoading
              ? null
              : () => _pickCropAndUploadImage(
                    aspectRatio: 16 / 9,
                    onImageUploaded: (url) => _backgroundImageUrl = url,
                  ),
          child: Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: _backgroundImageUrl != null
                ? Image.network(_backgroundImageUrl!, fit: BoxFit.cover)
                : const Center(child: Text('배경 이미지 선택 (16:9)')),
          ),
        ),
        // 프로필 이미지
        Positioned(
          top: 150,
          child: InkWell(
            onTap: _isLoading
                ? null
                : () => _pickCropAndUploadImage(
                      aspectRatio: 1.0, // 1:1 비율
                      onImageUploaded: (url) => _profileImageUrl = url,
                    ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 47,
                backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                child: _profileImageUrl == null ? const Icon(Icons.person, size: 50) : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 텍스트 입력 폼 영역 위젯
  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _introductionController,
            label: '한 줄 자기소개',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _careerController,
            label: '주요 경력',
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _instagramController,
            label: '인스타그램 링크',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _youtubeController,
            label: '유튜브/영상 링크',
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              //
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : const Text('저장하기'),
          ),
        ],
      ),
    );
  }

  /// 공통 텍스트 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: maxLines,
    );
  }
}
