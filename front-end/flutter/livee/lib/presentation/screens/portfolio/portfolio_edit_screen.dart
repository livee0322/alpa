import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/presentation/screens/portfolio/models/portfolio_image.dart';
import 'package:livee/presentation/screens/portfolio/sections/basic_info_section.dart';
import 'package:livee/presentation/screens/portfolio/sections/link_settings_section.dart';
import 'package:livee/presentation/screens/portfolio/sections/preview_section.dart';
import 'package:livee/presentation/screens/portfolio/sections/recent_live_section.dart';
import 'package:livee/presentation/screens/portfolio/sections/selection_info_section.dart';
import 'package:livee/presentation/screens/portfolio/sections/sub_thumbnail_section.dart';
import 'package:livee/presentation/screens/portfolio/vm/portfolio_edit_view_model.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/section_title.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';

class PortfolioEditScreen extends StatelessWidget {
  final String? portfolioId;

  const PortfolioEditScreen({
    super.key,
    this.portfolioId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortfolioEditViewModel(context, portfolioId: portfolioId),
      child: Consumer<PortfolioEditViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            title: Text(viewModel.isEditing ? '포트폴리오 수정' : '포트폴리오 등록'),
            centerTitle: false,
            backgroundColor: const Color(0xFFF7F8FA),
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: _buildBody(context, viewModel),
        ),
      ),
    );
  }

  /// 화면의 본문(Body) UI를 구성하는 헬퍼 위젯
  Widget _buildBody(BuildContext context, PortfolioEditViewModel viewModel) {
    final imageHandler = Provider.of<ImageHandlerProvider>(context, listen: false);
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: viewModel.formKey,
            child: Column(
              children: [
                // PreviewSection과 SubThumbnailSection은 ViewModel 타입에 직접 의존하지 않으므로 수정 없이 사용 가능
                PreviewSection(
                  mainThumbnailSource: viewModel.mainThumbnailSource,
                  backgroundImageSource: viewModel.backgroundImageSource,
                  nicknameController: viewModel.nicknameController,
                  onPickMainThumbnail: () async {
                    final bytes = await imageHandler.pickImage();
                    if (bytes != null) {
                      viewModel.mainThumbnailSource = PortfolioImage(localBytes: bytes);
                    }
                  },
                  onPickBackgroundImage: () async {
                    final bytes = await imageHandler.pickImage();
                    if (bytes != null) {
                      viewModel.backgroundImageSource = PortfolioImage(localBytes: bytes);
                    }
                  },
                ),
                const SizedBox(height: 32),

                StandardContentCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: '갤러리 이미지(최대 5개)'),
                      SubThumbnailSection(
                        sources: viewModel.subThumbnailSources,
                        onAddImage: () async {
                          final bytes = await imageHandler.pickImage();
                          if (bytes != null) {
                            viewModel.subThumbnailSources.add(PortfolioImage(localBytes: bytes));
                          }
                        },
                        onRemoveImage: (index) => viewModel.removeSubThumbnail(index),
                      ),
                    ],
                  ),
                ),

                // [수정] 리팩토링된 공통 섹션 위젯들은 이제 viewModel 하나만 깔끔하게 전달받습니다.
                StandardContentCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: '기본 정보'),
                      BasicInfoSection(viewModel: viewModel),
                    ],
                  ),
                ),

                StandardContentCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: '선택 정보'),
                      SelectionInfoSection(viewModel: viewModel),
                    ],
                  ),
                ),

                // '최근 라이브 링크'는 포트폴리오에만 존재하는 고유한 섹션입니다.
                StandardContentCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: '최근 라이브 링크'),
                      RecentLiveSection(
                        controllers: viewModel.recentLiveControllers,
                        onAdd: viewModel.addRecentLiveLink,
                        onRemove: viewModel.removeRecentLiveLink,
                      ),
                    ],
                  ),
                ),

                StandardContentCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: '링크 & 공개 설정'),
                      LinkSettingsSection(viewModel: viewModel),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                _buildActionButtons(viewModel),
              ],
            ),
          ),
        ),
        if (viewModel.isLoading || context.watch<ImageHandlerProvider>().isLoading)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  /// 하단 액션 버튼 (임시저장, 발행)을 만드는 헬퍼 위젯
  Widget _buildActionButtons(PortfolioEditViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 48,
          child: PrimaryActionButton(
            text: '저장',
            isFullWidth: false,
            isLoading: viewModel.isLoading,
            onPressed: () => viewModel.savePortfolio(),
          ),
        ),
      ],
    );
  }
}
