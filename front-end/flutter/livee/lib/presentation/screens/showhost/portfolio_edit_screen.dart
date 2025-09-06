import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/presentation/screens/showhost/models/portfolio_image.dart';
import 'package:livee/presentation/screens/showhost/widgets/portfolio_basic_info_section.dart';
import 'package:livee/presentation/screens/showhost/widgets/portfolio_experience_section.dart';
import 'package:livee/presentation/screens/showhost/widgets/portfolio_preview_section.dart';
import 'package:livee/presentation/screens/showhost/widgets/portfolio_recent_live_section.dart';
import 'package:livee/presentation/screens/showhost/widgets/portfolio_scope_section.dart';
import 'package:livee/presentation/screens/showhost/widgets/portfolio_sub_thumbnail_section.dart';
import 'package:livee/presentation/screens/showhost/widgets/portfolio_tags_section.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';
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
        GoRouter.of(context).pop();
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // _buildSectionHeader('미리보기'),
                  PortfolioPreviewSection(
                    mainThumbnailSource: _mainThumbnailSource,
                    backgroundImageSource: _backgroundImageSource,
                    nicknameController: _nicknameController,
                    onPickMainThumbnail: () => _pickImage(
                      onImageSelected: (source) =>
                          setState(() => _mainThumbnailSource = source),
                    ),
                    onPickBackgroundImage: () => _pickImage(
                      onImageSelected: (source) =>
                          setState(() => _backgroundImageSource = source),
                    ),
                  ),
                  const SizedBox(height: 96),
                  _buildSectionHeader('서브 썸네일 (선택, 최대 5)'),
                  PortfolioSubThumbnailSection(
                    sources: _subThumbnailSources,
                    onAddImage: () => _pickImage(
                      onImageSelected: (source) => setState(
                        () => _subThumbnailSources.add(source),
                      ),
                    ),
                    onRemoveImage: (index) => setState(
                      () => _subThumbnailSources.removeAt(index),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('기본 정보'),
                  PortfolioBasicInfoSection(
                    nicknameController: _nicknameController,
                    oneLineIntroController: _oneLineIntroController,
                    detailedIntroController: _detailedIntroController,
                  ),
                  const SizedBox(height: 32),
                  PortfolioExperienceSection(
                    experienceYearsController: _experienceYearsController,
                    ageController: _ageController,
                  ),
                  const SizedBox(height: 24),
                  CustomTextFormField(
                    controller: _mainLinkController,
                    label: '대표 링크',
                    hintText: 'https://...',
                  ),
                  const SizedBox(height: 32),
                  PortfolioScopeSection(
                    publicScope: _publicScope,
                    isReceivingOffers: _isReceivingOffers,
                    onScopeChanged: (value) {
                      if (value != null) setState(() => _publicScope = value);
                    },
                    onOfferChanged: (value) => setState(
                      () => _isReceivingOffers = value ?? true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('최근 라이브 링크'),
                  PortfolioRecentLiveSection(
                    controllers: _recentLiveControllers,
                    onAdd: _addRecentLiveLink,
                    onRemove: _removeRecentLiveLink,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('태그'),
                  PortfolioTagsSection(
                    tagController: _tagController,
                    tags: _tags,
                    onAddTag: _addTag,
                    onRemoveTag: _removeTag,
                  ),
                  const SizedBox(height: 40),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
          // _isLoading이 true일 때 로딩 오버레이 표시
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 48,
          child: TextButton(
            onPressed: _isLoading ? null : () => _savePortfolio('draft'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text('임시저장', style: TextStyle(fontSize: 16)),
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
}
