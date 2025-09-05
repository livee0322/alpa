import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';
import 'package:livee/service_locator.dart';

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

  // 레포지토리 인스턴스
  final PortfolioRepository _portfolioRepository =
      locator<PortfolioRepository>();

  @override
  void initState() {
    super.initState();
    // 초기 상태로 라이브 링크 입력 필드 하나를 추가
    _addRecentLiveLink();
    // 화면 로딩 시 기존 포트폴리오 데이터 불러오기
    _loadMyPortfolio();
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

  // --- [추가] 데이터 로딩 및 저장 로직 ---

  Future<void> _loadMyPortfolio() async {
    setState(() => _isLoading = true);
    try {
      final portfolio = await _portfolioRepository.getMyPortfolio();
      // 불러온 데이터로 컨트롤러 및 상태 변수 채우기
      setState(() {
        _nicknameController.text = portfolio.nickname ?? '';
        _oneLineIntroController.text = portfolio.oneLineIntro ?? '';
        _detailedIntroController.text = portfolio.detailedIntro ?? '';
        _experienceYearsController.text =
            portfolio.experienceYears?.toString() ?? '';
        _ageController.text = portfolio.age?.toString() ?? '';
        _mainLinkController.text = portfolio.mainLink ?? '';
        _publicScope = portfolio.publicScope ?? '전체공개';
        _isReceivingOffers = portfolio.isReceivingOffers ?? true;
        _mainThumbnailUrl = portfolio.mainThumbnailUrl;
        _backgroundImageUrl = portfolio.backgroundImageUrl;
        _subThumbnailUrls.addAll(portfolio.subThumbnailUrls ?? []);
        _tags.addAll(portfolio.tags ?? []);

        // 최근 라이브 링크 데이터 채우기
        _recentLiveControllers.clear();
        if (portfolio.recentLives != null &&
            portfolio.recentLives!.isNotEmpty) {
          for (var live in portfolio.recentLives!) {
            final controllers = RecentLiveControllers();
            controllers.titleController.text = live.title;
            controllers.urlController.text = live.url;
            controllers.dateController.text = live.date;
            _recentLiveControllers.add(controllers);
          }
        } else {
          _addRecentLiveLink(); // 데이터가 없으면 기본 입력창 하나 추가
        }
      });
    } catch (e) {
      // 데이터를 불러오지 못해도 에러를 띄우지 않고 빈 폼을 보여줌
      debugPrint("포트폴리오 로딩 실패: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePortfolio(String status) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 화면의 모든 데이터를 Map으로 취합
      final Map<String, dynamic> payload = {
        'nickname': _nicknameController.text,
        'oneLineIntro': _oneLineIntroController.text,
        'detailedIntro': _detailedIntroController.text,
        'experienceYears': int.tryParse(_experienceYearsController.text),
        'age': int.tryParse(_ageController.text),
        'mainLink': _mainLinkController.text,
        'publicScope': _publicScope,
        'isReceivingOffers': _isReceivingOffers,
        'mainThumbnailUrl': _mainThumbnailUrl,
        'backgroundImageUrl': _backgroundImageUrl,
        'subThumbnailUrls': _subThumbnailUrls,
        'tags': _tags,
        'recentLives': _recentLiveControllers
            .map((c) => {
                  'title': c.titleController.text,
                  'url': c.urlController.text,
                  'date': c.dateController.text,
                })
            .toList(),
        'status': status, // 'draft' 또는 'published'
      };

      await _portfolioRepository.saveMyPortfolio(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '포트폴리오가 성공적으로 ${status == 'draft' ? '저장' : '발행'}되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('포트폴리오 등록'),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('미리보기'),
              _buildImageSection(),
              const SizedBox(height: 32),
              _buildSectionHeader('기본 정보'),
              _buildBasicInfoSection(),
              const SizedBox(height: 32),
              _buildExperienceAndAgeSection(),
              const SizedBox(height: 24),
              _buildTextField(
                  controller: _mainLinkController,
                  label: '대표 링크',
                  hintText: 'https://...'),
              const SizedBox(height: 32),
              _buildScopeAndOfferSection(),
              const SizedBox(height: 32),
              _buildSectionHeader('최근 라이브 링크'),
              _buildRecentLiveSection(),
              const SizedBox(height: 32),
              _buildSectionHeader('태그'),
              _buildTagsSection(),
              const SizedBox(height: 40),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  // --- 각 섹션별 UI 빌드 메소드 ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildImageSection() {
    // 버튼에 적용할 공통 스타일 정의
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white, // 버튼 배경색
      foregroundColor: const Color(0xFF374151), // 아이콘 및 텍스트 색상
      elevation: 0, // 그림자 제거
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300), // 얇은 테두리
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    );
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.image_outlined, size: 18),
            label: const Text(
              '메인 썸네일',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () => _pickAndUploadImage(
                onImageUploaded: (url) => _mainThumbnailUrl = url),
            style: buttonStyle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.panorama_outlined, size: 18),
            label: const Text(
              '배경 이미지',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () => _pickAndUploadImage(
                onImageUploaded: (url) => _backgroundImageUrl = url),
            style: buttonStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
            controller: _nicknameController,
            label: '닉네임 *',
            hintText: '예: 라이브크리에이터',
            isRequired: true),
        const SizedBox(height: 16),
        _buildTextField(
            controller: _oneLineIntroController,
            label: '한 줄 소개 *',
            hintText: '예: 뷰티/일상 라이브 진행자',
            isRequired: true),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _detailedIntroController,
          label: '상세 소개 (자유)',
          hintText: '자유롭게 소개를 작성하세요.',
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildExperienceAndAgeSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTextField(
              controller: _experienceYearsController,
              label: '경력(년)',
              keyboardType: TextInputType.number),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
              controller: _ageController,
              label: '나이',
              keyboardType: TextInputType.number),
        ),
      ],
    );
  }

  Widget _buildScopeAndOfferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdown(
          label: '공개 범위',
          value: _publicScope,
          items: const ['전체공개', '링크 공개', '비공개'],
          onChanged: (value) {
            if (value != null) setState(() => _publicScope = value);
          },
          menuOffset: const Offset(0, 55),
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
        // ListView.builder를 사용하여 동적 필드 렌더링
        ..._recentLiveControllers.asMap().entries.map((entry) {
          int index = entry.key;
          RecentLiveControllers controller = entry.value;
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildTextField(
                    controller: controller.titleController,
                    label: '제목',
                    hintText: '예: OO몰 뷰티 라이브'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 2,
                        child: _buildTextField(
                            controller: controller.urlController,
                            label: '링크',
                            hintText: 'https://...')),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 1,
                        child: _buildTextField(
                            controller: controller.dateController,
                            label: '날짜',
                            hintText: '연도-월-일')),
                    if (_recentLiveControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _removeRecentLiveLink(index),
                        padding: const EdgeInsets.only(top: 8),
                        constraints: const BoxConstraints(),
                      )
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('추가'),
            onPressed: _addRecentLiveLink,
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            hintText: '엔터로 추가',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addTag,
            ),
          ),
          onSubmitted: (_) => _addTag(),
        ),
        if (_tags.isNotEmpty) const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _tags
              .map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    deleteIconColor: Colors.grey[600],
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(horizontal: 4),
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
        SizedBox(
          height: 48,
          child: TextButton(
            onPressed: _isLoading ? null : () => _savePortfolio('draft'),
            child: const Text('임시저장', style: TextStyle(fontSize: 16)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: PrimaryActionButton(
            text: '발행',
            isFullWidth: false,
            isLoading: _isLoading,
            onPressed: () => _savePortfolio('published'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? label,
    String? hintText,
    int maxLines = 1,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text.rich(
              TextSpan(
                text: label,
                children: isRequired
                    ? [
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        )
                      ]
                    : [],
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.white,
            // [수정] 테두리 스타일
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            alignLabelWithHint: maxLines > 1,
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return '필수 항목입니다.';
            }
            return null;
          },
        ),
      ],
    );
  }
}
