import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';

// 최근 라이브 링크 입력을 관리하기 위한 컨트롤러 그룹
class RecentLiveControllers {
  final TextEditingController titleController;
  final TextEditingController urlController;
  final TextEditingController dateController;

  RecentLiveControllers()
      : titleController = TextEditingController(),
        urlController = TextEditingController(),
        dateController = TextEditingController();

  void dispose() {
    titleController.dispose();
    urlController.dispose();
    dateController.dispose();
  }
}

// 쇼호스트가 자신의 포트폴리오를 등록/수정하는 화면
class PortfolioEditScreen extends StatefulWidget {
  const PortfolioEditScreen({super.key});

  @override
  State<PortfolioEditScreen> createState() => _PortfolioEditScreenState();
}

class _PortfolioEditScreenState extends State<PortfolioEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 이미지 URL
  String? _mainThumbnailUrl;
  String? _backgroundImageUrl;
  final List<String> _subThumbnailUrls = [];

  // 기본 정보
  final _nicknameController = TextEditingController();
  final _oneLineIntroController = TextEditingController();
  final _detailedIntroController = TextEditingController();

  // 경력 및 나이
  final _experienceYearsController = TextEditingController();
  final _ageController = TextEditingController();

  // 대표 링크
  final _mainLinkController = TextEditingController();

  // 공개 범위 및 제안 받기
  String _publicScope = '전체공개';
  bool _isReceivingOffers = true;

  // 최근 라이브 링크 (동적 리스트)
  final List<RecentLiveControllers> _recentLiveControllers = [];

  // 태그
  final _tagController = TextEditingController();
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    // 초기 상태로 라이브 링크 입력 필드 하나를 추가
    _addRecentLiveLink();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _oneLineIntroController.dispose();
    _detailedIntroController.dispose();
    _experienceYearsController.dispose();
    _ageController.dispose();
    _mainLinkController.dispose();
    _tagController.dispose();
    for (var controller in _recentLiveControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- 동적 필드 관리 메소드 ---
  void _addRecentLiveLink() {
    setState(() {
      _recentLiveControllers.add(RecentLiveControllers());
    });
  }

  void _removeRecentLiveLink(int index) {
    setState(() {
      _recentLiveControllers[index].dispose();
      _recentLiveControllers.removeAt(index);
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  // 이미지 선택 및 업로드 로직 (기존 코드 재사용)
  Future<void> _pickAndUploadImage({
    required Function(String) onImageUploaded,
  }) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    if (!mounted) return;

    // TODO: 크롭 다이얼로그 연동 (현재는 직접 업로드)
    setState(() => _isLoading = true);
    try {
      final bytes = await pickedFile.readAsBytes();
      final newUrl = await CloudinaryUploader().uploadImage(bytes);
      setState(() {
        onImageUploaded(newUrl);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포트폴리오 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildExperienceAndAgeSection(),
              const SizedBox(height: 24),
              _buildTextField(controller: _mainLinkController, label: '대표 링크'),
              const SizedBox(height: 24),
              _buildScopeAndOfferSection(),
              const SizedBox(height: 24),
              _buildRecentLiveSection(),
              const SizedBox(height: 24),
              _buildTagsSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  // --- 각 섹션별 UI 빌드 메소드 ---

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('미리보기',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.image_outlined),
              label: const Text('메인 썸네일'),
              onPressed: () => _pickAndUploadImage(
                  onImageUploaded: (url) => _mainThumbnailUrl = url),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.panorama_outlined),
              label: const Text('배경 이미지'),
              onPressed: () => _pickAndUploadImage(
                  onImageUploaded: (url) => _backgroundImageUrl = url),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('서브 썸네일 (선택, 최대 5)', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        // TODO: 서브 썸네일 GridView 구현
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Icon(Icons.add_photo_alternate_outlined)),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('기본 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTextField(
            controller: _nicknameController, label: '닉네임 *', isRequired: true),
        const SizedBox(height: 16),
        _buildTextField(
            controller: _oneLineIntroController,
            label: '한 줄 소개 *',
            isRequired: true),
        const SizedBox(height: 16),
        _buildTextField(
            controller: _detailedIntroController,
            label: '상세 소개 (자유)',
            maxLines: 5),
      ],
    );
  }

  Widget _buildExperienceAndAgeSection() {
    return Row(
      children: [
        Expanded(
            child: _buildTextField(
                controller: _experienceYearsController,
                label: '경력(년)',
                keyboardType: TextInputType.number)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildTextField(
                controller: _ageController,
                label: '나이',
                keyboardType: TextInputType.number)),
      ],
    );
  }

  Widget _buildScopeAndOfferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('공개 범위', style: TextStyle(fontSize: 16)),
        DropdownButtonFormField<String>(
          value: _publicScope,
          items: ['전체공개', '비공개']
              .map(
                  (label) => DropdownMenuItem(value: label, child: Text(label)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _publicScope = value);
          },
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        CheckboxListTile(
          title: const Text('제안 받기'),
          value: _isReceivingOffers,
          onChanged: (newValue) {
            setState(() => _isReceivingOffers = newValue ?? true);
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildRecentLiveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('최근 라이브 링크',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentLiveControllers.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildTextField(
                        controller:
                            _recentLiveControllers[index].titleController,
                        label: '제목'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                controller:
                                    _recentLiveControllers[index].urlController,
                                label: '링크')),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _buildTextField(
                                controller: _recentLiveControllers[index]
                                    .dateController,
                                label: '연도-월-일')),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _removeRecentLiveLink(index),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('추가'),
          onPressed: _addRecentLiveLink,
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('태그',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            hintText: '엔터로 추가',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addTag,
            ),
          ),
          onSubmitted: (_) => _addTag(),
        ),
        Wrap(
          spacing: 8.0,
          children: _tags
              .map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  // TODO: 임시저장 로직
                },
          child: const Text('임시저장'),
        ),
        const SizedBox(width: 8),
        PrimaryActionButton(
          text: '발행',
          isFullWidth: false,
          isLoading: _isLoading,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: 발행(저장) 로직
            }
          },
        ),
      ],
    );
  }

  /// 공통 텍스트 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label 항목은 필수입니다.';
        }
        return null;
      },
    );
  }
}
