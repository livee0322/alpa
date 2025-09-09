import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/vm/portfolio_edit_view_model.dart';
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
import 'package:provider/provider.dart';

class PortfolioEditScreen extends StatelessWidget {
  final String? portfolioId;

  const PortfolioEditScreen({
    super.key,
    this.portfolioId,
  });

  @override
  Widget build(BuildContext context) {
    // ViewModel을 생성하고 UI에 제공
    return ChangeNotifierProvider(
      create: (_) => PortfolioEditViewModel(context, portfolioId: portfolioId),
      child: Consumer<PortfolioEditViewModel>(
        builder: (context, viewModel, child) => Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('미리보기'),
                      PortfolioPreviewSection(
                        mainThumbnailSource: viewModel.mainThumbnailSource,
                        backgroundImageSource: viewModel.backgroundImageSource,
                        nicknameController: viewModel.nicknameController,
                        onPickMainThumbnail: () => viewModel.pickImage(
                          onImageSelected: (source) => viewModel.mainThumbnailSource = source,
                        ),
                        onPickBackgroundImage: () => viewModel.pickImage(
                          onImageSelected: (source) => viewModel.backgroundImageSource = source,
                        ),
                      ),
                      const SizedBox(height: 96),
                      _buildSectionHeader('서브 썸네일 (선택, 최대 5)'),
                      PortfolioSubThumbnailSection(
                        sources: viewModel.subThumbnailSources,
                        onAddImage: () => viewModel.pickImage(
                          onImageSelected: (source) => viewModel.subThumbnailSources.add(source),
                        ),
                        onRemoveImage: (index) => viewModel.subThumbnailSources.removeAt(index),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionHeader('기본 정보'),
                      PortfolioBasicInfoSection(
                        nicknameController: viewModel.nicknameController,
                        oneLineIntroController: viewModel.oneLineIntroController,
                        detailedIntroController: viewModel.detailedIntroController,
                      ),
                      const SizedBox(height: 32),
                      PortfolioExperienceSection(
                        experienceYearsController: viewModel.experienceYearsController,
                        ageController: viewModel.ageController,
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        controller: viewModel.mainLinkController,
                        label: '대표 링크',
                        hintText: 'https://...',
                      ),
                      const SizedBox(height: 32),
                      PortfolioScopeSection(
                        publicScope: viewModel.publicScope,
                        isReceivingOffers: viewModel.isReceivingOffers,
                        onScopeChanged: viewModel.setPublicScope,
                        onOfferChanged: viewModel.setIsReceivingOffers,
                      ),
                      const SizedBox(height: 32),
                      _buildSectionHeader('최근 라이브 링크'),
                      PortfolioRecentLiveSection(
                        controllers: viewModel.recentLiveControllers,
                        onAdd: viewModel.addRecentLiveLink,
                        onRemove: viewModel.removeRecentLiveLink,
                      ),
                      const SizedBox(height: 32),
                      _buildSectionHeader('태그'),
                      PortfolioTagsSection(
                        tagController: viewModel.tagController,
                        tags: viewModel.tags,
                        onAddTag: viewModel.addTag,
                        onRemoveTag: viewModel.removeTag,
                      ),
                      const SizedBox(height: 40),
                      _buildActionButtons(viewModel),
                    ],
                  ),
                ),
              ),
              if (viewModel.isLoading)
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
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionButtons(PortfolioEditViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 48,
          child: TextButton(
            onPressed: viewModel.isLoading ? null : () => viewModel.savePortfolio('draft'),
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
            isLoading: viewModel.isLoading,
            onPressed: () => viewModel.savePortfolio('published'),
          ),
        ),
      ],
    );
  }
}
