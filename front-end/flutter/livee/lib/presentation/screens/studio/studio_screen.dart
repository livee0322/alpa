import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/studio.dart';
import 'package:livee/presentation/screens/studio/vm/studio_view_model.dart';
import 'package:livee/presentation/screens/studio/widgets/booking_bottom_sheet.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/buttons/secondary_action_button.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:universal_html/html.dart' as html;

/// '스튜디오 상세' 및 '예약'
class StudioScreen extends StatelessWidget {
  final String studioId;
  const StudioScreen({super.key, required this.studioId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudioViewModel(studioId: studioId),
      child: Consumer<StudioViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.footerColor,
            appBar: _buildAppBar(context, viewModel.studio),
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: _buildBody(context, viewModel),
            ),
            bottomNavigationBar: _buildBottomActionBar(context),
          );
        },
      ),
    );
  }

  // AppBar UI
  AppBar _buildAppBar(BuildContext context, Studio? studio) {
    return AppBar(
      backgroundColor: AppColors.white,
      leading: IconButton(
        icon: const Icon(RemixIcons.arrow_left_line),
        onPressed: () => html.window.history.go(-1),
      ),
      title: Text(
        studio?.brandName ?? '스튜디오',
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(RemixIcons.settings_3_line),
          onPressed: () => GoRouter.of(context).go('/studio-edit'),
        ),
      ],
    );
  }

  // 화면 본문 UI
  Widget _buildBody(BuildContext context, StudioViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }
    if (viewModel.studio == null) {
      return const SizedBox.shrink(); // 로딩 중이거나 데이터가 없을 때
    }

    final studio = viewModel.studio!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildImageGallery(studio),
          const SizedBox(height: 16),
          _buildStudioInfoSection(studio), // 스튜디오 정보 섹션
          const SizedBox(height: 16),
          _buildGuidanceSection(studio), // 안내 섹션
          const SizedBox(height: 16),
          _buildScheduleCard(), // 스케줄 캘린더 카드
        ],
      ),
    );
  }

  // 이미지 갤러리 UI
  Widget _buildImageGallery(Studio studio) {
    // TODO: _selectedMainImage 상태 관리 로직 추가 필요
    final mainImage = studio.mainThumbnailUrl ??
        'https://picsum.photos/seed/studio_main/800/600';
    final galleryImages = studio.galleryUrls;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(mainImage,
              fit: BoxFit.cover, height: 250, width: double.infinity),
        ),
        const SizedBox(height: 8),
        if (galleryImages.isNotEmpty)
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: galleryImages.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final imageUrl = galleryImages[index];
                return GestureDetector(
                  onTap: () {
                    /* TODO: setState(() => _selectedMainImage = imageUrl) */
                  },
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.transparent, width: 2),
                      image: DecorationImage(
                          image: NetworkImage(imageUrl), fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // 스튜디오 정보 섹션
  Widget _buildStudioInfoSection(Studio studio) {
    return StandardContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('스튜디오 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInfoRow('브랜드명', studio.brandName),
          _buildInfoRow('한 줄 소개', studio.oneLineIntro),
          _buildInfoRow('상세 소개', studio.detailedIntro, maxLines: 5),
          const Divider(height: 24),
          _buildInfoRow('전화', studio.contact.phone),
          _buildInfoRow('이메일', studio.contact.email),
          _buildInfoRow('카카오', studio.contact.kakao),
          const Divider(height: 24),
          _buildInfoRow('주소', studio.location.address),
          _buildInfoRow('지도', studio.location.mapUrl),
        ],
      ),
    );
  }

  // 안내 섹션
  Widget _buildGuidanceSection(Studio studio) {
    return StandardContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('안내',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInfoRow('이용 안내', studio.usageInfo, maxLines: 5),
          const Divider(height: 24),
          _buildInfoRow('금액 안내', studio.priceInfo, maxLines: 5),
        ],
      ),
    );
  }

  // 정보 행(Row)을 만드는 공통 위젯
  Widget _buildInfoRow(String title, String? content, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80, // 제목 너비 고정
            child: Text(title, style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Text(content?.isNotEmpty == true ? content! : '-',
                  maxLines: maxLines)),
        ],
      ),
    );
  }

  // 스케줄 캘린더 카드
  Widget _buildScheduleCard() {
    // TODO: API 데이터와 연동 필요
    return StandardContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('스케줄',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TableCalendar(
            locale: 'ko_KR',
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
          ),
          const SizedBox(height: 8),
          const Text('● 초록: 예약 가능, 회색: 휴무, 빨강: 마감',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // 하단 고정 액션 바
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child: SecondaryActionButton(
                  text: '문의하기',
                  icon: RemixIcons.chat_3_line,
                  onPressed: () {})),
          const SizedBox(width: 8),
          Expanded(
            child: PrimaryActionButton(
              icon: RemixIcons.calendar_check_line,
              text: '예약/결제',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const BookingBottomSheet(),
              ),
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
