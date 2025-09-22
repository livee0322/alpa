// [파일] lib/presentation/screens/studio/studio_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/studio/widgets/booking_bottom_sheet.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/buttons/secondary_action_button.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:remixicon/remixicon.dart';
import 'package:table_calendar/table_calendar.dart';

/// '스튜디오 상세' 및 '예약' UI를 표시하는 화면입니다. (데이터는 목업)
class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  // --- 상태 변수 ---
  String _selectedMainImage = 'https://picsum.photos/seed/studio_main/800/600';
  final List<String> _galleryImages = [
    'https://picsum.photos/seed/studio1/200/200',
    'https://picsum.photos/seed/studio2/200/200',
    'https://picsum.photos/seed/studio3/200/200',
    'https://picsum.photos/seed/studio4/200/200',
    'https://picsum.photos/seed/studio5/200/200',
  ];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(
        leading: const IconButton(icon: Icon(CupertinoIcons.back), onPressed: null),
        title: const Text('BYHEN'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.settings),
            onPressed: () => GoRouter.of(context).go('/studio-edit'),
          ),
        ],
      ),
      // --- Body (스크롤) ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildImageGallery(),
            const SizedBox(height: 16),
            _buildInfoCard('스튜디오 정보', '소개', '대전 스튜디오'),
            const SizedBox(height: 16),
            _buildInfoCard('연락처', '전화\n이메일\n카카오', '12345677\nhahha@jsjsis.com\n-'),
            const SizedBox(height: 16),
            _buildInfoCard('이용 안내', '금액 안내\n주소', '테스트입니다\n-'),
            const SizedBox(height: 16),
            _buildScheduleCard(), // 스케줄 캘린더 카드
          ],
        ),
      ),
      // --- 하단 고정 버튼 ---
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  /// [위젯] 이미지 갤러리 UI
  Widget _buildImageGallery() {
    return Column(
      children: [
        // 큰 대표 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(_selectedMainImage, fit: BoxFit.cover, height: 250, width: double.infinity),
        ),
        const SizedBox(height: 8),
        // 작은 썸네일 리스트
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _galleryImages.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final imageUrl = _galleryImages[index];
              final isSelected = _selectedMainImage == imageUrl; // 썸네일 선택 상태 확인 (임시)
              return GestureDetector(
                onTap: () => setState(() => _selectedMainImage = imageUrl),
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                    image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// [위젯] 정보 표시를 위한 공통 카드
  Widget _buildInfoCard(String title, String subtitle1, String content1) {
    return StandardContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle1, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 16),
              Expanded(child: Text(content1)),
            ],
          ),
        ],
      ),
    );
  }

  /// [위젯] 스케줄 캘린더 카드
  Widget _buildScheduleCard() {
    return StandardContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('스케줄', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TableCalendar(
            locale: 'ko_KR', // 한글 설정
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // '2주' 버튼 숨기기
              titleCentered: true,
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            // 날짜 밑에 이벤트 점 표시 (API 연동 시 사용)
            eventLoader: (day) {
              // 임시 데이터: 매주 월요일, 수요일, 금요일에 이벤트가 있다고 가정
              if (day.weekday == DateTime.monday ||
                  day.weekday == DateTime.wednesday ||
                  day.weekday == DateTime.friday) {
                return [const Text('●', style: TextStyle(color: Colors.green, fontSize: 8))];
              }
              return [];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 5,
                    child: (events.first as Text), // eventLoader에서 반환한 위젯
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '● 초록: 예약 가능, 회색: 휴무, 빨강: 마감',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// [위젯] 하단 고정 액션 바
  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SecondaryActionButton(
              text: '문의하기',
              icon: RemixIcons.chat_3_line,
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PrimaryActionButton(
              text: '예약/결제',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true, // 키보드가 올라올 때도 가려지지 않도록 설정
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
