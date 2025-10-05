import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/account/vm/profiles_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';

/// '프로필 설정' 화면
class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfilesViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(context, viewModel),
                  const SizedBox(height: 16),
                  _buildProfileSection(context, viewModel),
                  const SizedBox(height: 16),
                  _buildChannelSection(context, viewModel),
                  const SizedBox(height: 16),
                  _buildNotificationSettings(context, viewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // [추가] '내 프로필 설정' 헤더 UI
  Widget _buildHeader(BuildContext context, ProfilesViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '내 프로필 설정',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: viewModel.toggleEditMode,
          child: Text(
            viewModel.isEditing ? '저장' : '수정',
            style: const TextStyle(fontSize: 16, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  // [추가] 프로필 섹션 UI
  Widget _buildProfileSection(BuildContext context, ProfilesViewModel viewModel) {
    return StandardContentCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('프로필', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.disabled,
                  // TODO: ViewModel의 프로필 이미지 URL과 연결
                  child: Icon(Icons.person, size: 40, color: AppColors.textGrey),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: !viewModel.isEditing,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: viewModel.isEditing ? AppColors.buttonDark : AppColors.disabled,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: () {
                          // TODO: 이미지 선택 기능 연결
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomTextFormField(
            label: '이름',
            controller: viewModel.nameController,
            enabled: viewModel.isEditing,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            label: '이메일',
            controller: TextEditingController(text: 'user@email.com'), // TODO
            readOnly: true,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            label: '전화번호',
            controller: viewModel.phoneController,
            enabled: viewModel.isEditing,
          ),
        ],
      ),
    );
  }

  // [추가] 채널 섹션 UI
  Widget _buildChannelSection(BuildContext context, ProfilesViewModel viewModel) {
    return StandardContentCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.chat_bubble,
            iconColor: Colors.yellow.shade700,
            title: '카카오톡 채널 알림',
            subtitle: '휴대폰 인증 · 채널 연결 필요',
            value: viewModel.useKakaoAlert,
            onChanged: (value) {}, // TODO
            isEditing: viewModel.isEditing,
          ),
          const Divider(),
          _buildSwitchTile(
            icon: CupertinoIcons.bell_fill,
            iconColor: Colors.grey,
            title: '라이비 알림 (사이트 내)',
            subtitle: '브라우저 권한 필요',
            value: viewModel.useSiteAlert,
            onChanged: (value) {}, // TODO
            isEditing: viewModel.isEditing,
          ),
        ],
      ),
    );
  }

  // [추가] 알림 설정 전체 섹션 UI
  Widget _buildNotificationSettings(BuildContext context, ProfilesViewModel viewModel) {
    return StandardContentCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('알림 설정', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 80, child: Text('카카오톡', textAlign: TextAlign.center)),
              SizedBox(width: 80, child: Text('라이비', textAlign: TextAlign.center)),
            ],
          ),
          const Divider(),
          _buildNotificationCategory(
            title: '공고/계약',
            items: [
              _buildNotificationRow(
                  '신규 공고 등록', viewModel.newCampaignKakao, viewModel.newCampaignLivee, viewModel, (v) {}, (v) {}),
              _buildNotificationRow(
                  '제안 도착', viewModel.proposalKakao, viewModel.proposalLivee, viewModel, (v) {}, (v) {}),
              _buildNotificationRow('지원 결과(합격/불합격)', viewModel.applicationResultKakao, viewModel.applicationResultLivee,
                  viewModel, (v) {}, (v) {}),
              _buildNotificationRow('계약 확정/결제 완료', viewModel.contractConfirmationKakao,
                  viewModel.contractConfirmationLivee, viewModel, (v) {}, (v) {}),
              _buildNotificationRow(
                  '계약 취소/변경', viewModel.contractChangeKakao, viewModel.contractChangeLivee, viewModel, (v) {}, (v) {}),
            ],
          ),
          _buildNotificationCategory(
            title: '일정/촬영',
            items: [
              _buildNotificationRow('촬영일 1일 전 리마인드', viewModel.reminderBeforeDayKakao, viewModel.reminderBeforeDayLivee,
                  viewModel, (v) {}, (v) {}),
              _buildNotificationRow('촬영 시작 1시간 전 푸시', viewModel.reminderBeforeHourKakao,
                  viewModel.reminderBeforeHourLivee, viewModel, (v) {}, (v) {}),
              _buildNotificationRow('촬영 일정 변경/취소', viewModel.scheduleChangeKakao, viewModel.scheduleChangeLivee,
                  viewModel, (v) {}, (v) {}),
            ],
          ),
          _buildNotificationCategory(
            title: '메시지/소통',
            items: [
              _buildNotificationRow(
                  '새 메시지 도착', viewModel.newMessageKakao, viewModel.newMessageLivee, viewModel, (v) {}, (v) {}),
            ],
          ),
          _buildNotificationCategory(
            title: '운영자 공지/공지사항',
            items: [
              _buildNotificationRow(
                  '운영자 공지/공지사항', viewModel.adminNoticeKakao, viewModel.adminNoticeLivee, viewModel, (v) {}, (v) {}),
            ],
          ),
          _buildNotificationCategory(
            title: '정산/금전',
            items: [
              _buildNotificationRow('정산 완료 알림', viewModel.paymentCompleteKakao, viewModel.paymentCompleteLivee,
                  viewModel, (v) {}, (v) {}),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets for UI ---

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isEditing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: isEditing ? onChanged : null,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNotificationCategory({required String title, required List<Widget> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _buildNotificationRow(String title, bool kakaoValue, bool liveeValue, ProfilesViewModel viewModel,
      Function(bool) onKakaoChanged, Function(bool) onLiveeChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: TextStyle(color: Colors.grey.shade600))),
          SizedBox(
            width: 80,
            child: Center(
              child: Switch(
                value: kakaoValue,
                onChanged: viewModel.isEditing ? onKakaoChanged : null,
                activeColor: AppColors.primary,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Center(
              child: Switch(
                value: liveeValue,
                onChanged: viewModel.isEditing ? onLiveeChanged : null,
                activeColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
