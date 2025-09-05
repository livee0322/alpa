// lib/presentation/screens/showhost/portfolio_edit_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';
import 'package:livee/service_locator.dart';

// 로컬 파일과 네트워크 URL을 구분하기 위한 헬퍼 클래스
class PortfolioImage {
  final Uint8List? localBytes;
  final String? networkUrl;

  PortfolioImage({this.localBytes, this.networkUrl});
}

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

class PortfolioEditScreen extends StatefulWidget {
  final String? portfolioId;

  const PortfolioEditScreen({
    super.key,
    this.portfolioId,
  });

  @override
  State<PortfolioEditScreen> createState() => _PortfolioEditScreenState();
}

class _PortfolioEditScreenState extends State<PortfolioEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- 상태 변수 ---
  PortfolioImage? _mainThumbnailSource;
  PortfolioImage? _backgroundImageSource;
  final List<PortfolioImage> _subThumbnailSources = [];

  final _nicknameController = TextEditingController();
  final _oneLineIntroController = TextEditingController();
  final _detailedIntroController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _ageController = TextEditingController();
  final _mainLinkController = TextEditingController();

  String _publicScope = '전체공개';
  bool _isReceivingOffers = true;

  final List<RecentLiveControllers> _recentLiveControllers = [];

  final _tagController = TextEditingController();
  final List<String> _tags = [];

  final PortfolioRepository _portfolioRepository =
      locator<PortfolioRepository>();

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickImage({
    required Function(PortfolioImage) onImageSelected,
  }) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    onImageSelected(PortfolioImage(localBytes: bytes));
  }

  Future<void> _loadMyPortfolio() async {
    if (widget.portfolioId == null) {
      _addRecentLiveLink();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final portfolio =
          await _portfolioRepository.getPortfolioById(widget.portfolioId!);
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

        if (portfolio.mainThumbnailUrl != null) {
          _mainThumbnailSource =
              PortfolioImage(networkUrl: portfolio.mainThumbnailUrl);
        }
        if (portfolio.backgroundImageUrl != null) {
          _backgroundImageSource =
              PortfolioImage(networkUrl: portfolio.backgroundImageUrl);
        }

        _subThumbnailSources.clear();
        _subThumbnailSources.addAll((portfolio.subThumbnailUrls ?? [])
            .map((url) => PortfolioImage(networkUrl: url)));

        _tags.clear();
        _tags.addAll(portfolio.tags ?? []);

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
          _addRecentLiveLink();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('포트폴리오 정보를 불러오는 데 실패했습니다: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePortfolio(String status) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final uploader = CloudinaryUploader();

      // --- 이미지 업로드 처리 ---
      String? finalMainThumbUrl = _mainThumbnailSource?.networkUrl;
      if (_mainThumbnailSource?.localBytes != null) {
        finalMainThumbUrl =
            await uploader.uploadImage(_mainThumbnailSource!.localBytes!);
      }

      String? finalBackgroundUrl = _backgroundImageSource?.networkUrl;
      if (_backgroundImageSource?.localBytes != null) {
        finalBackgroundUrl =
            await uploader.uploadImage(_backgroundImageSource!.localBytes!);
      }

      final List<String> finalSubUrls = [];
      for (final source in _subThumbnailSources) {
        if (source.localBytes != null) {
          final newUrl = await uploader.uploadImage(source.localBytes!);
          finalSubUrls.add(newUrl);
        } else if (source.networkUrl != null) {
          finalSubUrls.add(source.networkUrl!);
        }
      }

      final Map<String, dynamic> payload = {
        'nickname': _nicknameController.text,
        'oneLineIntro': _oneLineIntroController.text,
        'detailedIntro': _detailedIntroController.text,
        'experienceYears': int.tryParse(_experienceYearsController.text),
        'age': int.tryParse(_ageController.text),
        'mainLink': _mainLinkController.text,
        'publicScope': _publicScope,
        'isReceivingOffers': _isReceivingOffers,
        'mainThumbnailUrl': finalMainThumbUrl,
        'backgroundImageUrl': finalBackgroundUrl,
        'subThumbnailUrls': finalSubUrls,
        'tags': _tags,
        'recentLives': _recentLiveControllers
            .map((c) => {
                  'title': c.titleController.text,
                  'url': c.urlController.text,
                  'date': c.dateController.text,
                })
            .where((item) =>
                item['title']!.isNotEmpty ||
                item['url']!.isNotEmpty ||
                item['date']!.isNotEmpty)
            .toList(),
        'status': status,
      };

      if (widget.portfolioId == null) {
        await _portfolioRepository.createPortfolio(payload);
      } else {
        await _portfolioRepository.updatePortfolio(
            widget.portfolioId!, payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '포트폴리오가 성공적으로 ${status == 'draft' ? '저장' : '발행'}되었습니다.')),
        );
        GoRouter.of(context).go('/my-portfolios');
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
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('포트폴리오 등록'),
        centerTitle: false,
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        foregroundColor: Colors.black,
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
              const SizedBox(height: 24),
              _buildSectionHeader('서브 썸네일 (선택, 최대 5)'),
              _buildSubThumbnailSection(),
              const SizedBox(height: 32),
              _buildSectionHeader('기본 정보'),
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
                  maxLines: 5),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildImageSection() {
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

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.image_outlined, size: 18),
            label: const Text('메인 썸네일'),
            onPressed: () => _pickImage(onImageSelected: (source) {
              setState(() => _mainThumbnailSource = source);
            }),
            style: buttonStyle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.panorama_outlined, size: 18),
            label: const Text('배경 이미지'),
            onPressed: () => _pickImage(onImageSelected: (source) {
              setState(() => _backgroundImageSource = source);
            }),
            style: buttonStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildSubThumbnailSection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _subThumbnailSources.length +
          (_subThumbnailSources.length < 5 ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        if (index == _subThumbnailSources.length &&
            _subThumbnailSources.length < 5) {
          return InkWell(
            onTap: () => _pickImage(onImageSelected: (source) {
              setState(() {
                _subThumbnailSources.add(source);
              });
            }),
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

        final imageSource = _subThumbnailSources[index];
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
                  onTap: () {
                    setState(() {
                      _subThumbnailSources.removeAt(index);
                    });
                  },
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
        ),
        CheckboxListTile(
          title: const Text('제안 받기'),
          value: _isReceivingOffers,
          onChanged: (newValue) {
            setState(() => _isReceivingOffers = newValue ?? true);
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF6C63FF),
        ),
      ],
    );
  }

  Widget _buildRecentLiveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._recentLiveControllers.asMap().entries.map((entry) {
          int index = entry.key;
          RecentLiveControllers controller = entry.value;
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: const Color(0xFF374151),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _tagController,
          hintText: '엔터로 추가',
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addTag,
          ),
          onSubmitted: (_) => _addTag,
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
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.shade300)),
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
    Widget? suffixIcon,
    Function(String)? onSubmitted,
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
                            text: ' *', style: TextStyle(color: Colors.red))
                      ]
                    : [],
              ),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.white,
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
            suffixIcon: suffixIcon,
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          onFieldSubmitted: onSubmitted,
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
