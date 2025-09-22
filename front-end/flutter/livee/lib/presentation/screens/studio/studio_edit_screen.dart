// [파일] lib/presentation/screens/studio/studio_edit_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/studio/widgets/custom_time_picker.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:remixicon/remixicon.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:universal_html/html.dart' as html;

/// '스튜디오' 정보를 등록하고 관리하는 페이지
class StudioEditScreen extends StatefulWidget {
  const StudioEditScreen({super.key});

  @override
  State<StudioEditScreen> createState() => _StudioEditScreenState();
}

class _StudioEditScreenState extends State<StudioEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(RemixIcons.arrow_left_line),
          onPressed: () => html.window.history.go(-1),
        ),
        centerTitle: true, // 가운데 정렬
        title: const Text(
          'BYHEN・관리자',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildDescriptionSection(),
            const SizedBox(height: 16),
            _buildContactSection(),
            const SizedBox(height: 16),
            _buildGallerySection(),
            const SizedBox(height: 16),
            _buildScheduleSection(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: PrimaryActionButton(
                text: '저장',
                onPressed: () => html.window.history.go(-1),
                isFullWidth: false, // 버튼이 전체 너비를 차지하지 않도록 설정
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 각 섹션을 구성하는 헬퍼 메소드들
  Widget _buildBasicInfoSection() {
    return StandardContentCard(
      child: Column(
        children: [
          CustomTextFormField(controller: TextEditingController(), label: '브랜드명 *', hintText: '예) BYHEN'),
          const SizedBox(height: 16),
          CustomTextFormField(
            controller: TextEditingController(),
            label: '슬러그 *',
            hintText: '예) byhen',
          ),
          const SizedBox(height: 16),
          // TODO: 이미지 삽입 위젯 공통화
          const Text('메인 썸네일 *'),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.image), label: const Text('이미지 삽입')),
          const SizedBox(height: 16),
          const Text('서브 썸네일(최대 5장)'),
          OutlinedButton(onPressed: () {}, child: const Text('추가')),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return StandardContentCard(
      child: Column(
        children: [
          CustomTextFormField(controller: TextEditingController(), label: '한 줄 소개', hintText: '예) 성수동 다목적 촬영 스튜디오'),
          const SizedBox(height: 16),
          CustomTextFormField(controller: TextEditingController(), label: '상세 소개', hintText: '스튜디오 상세 설명', maxLines: 5),
          const SizedBox(height: 16),
          CustomTextFormField(
              controller: TextEditingController(), label: '이용 안내', hintText: '예약/환불/주의사항 등', maxLines: 5),
          const SizedBox(height: 16),
          CustomTextFormField(
              controller: TextEditingController(), label: '금액 안내', hintText: '패키지/옵션/부가세 등', maxLines: 5),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return StandardContentCard(
      child: Column(
        children: [
          CustomTextFormField(controller: TextEditingController(), label: '전화', hintText: '02-000-0000'),
          const SizedBox(height: 16),
          CustomTextFormField(controller: TextEditingController(), label: '이메일', hintText: 'hello@brand.com'),
          const SizedBox(height: 16),
          CustomTextFormField(controller: TextEditingController(), label: '카카오', hintText: 'https://pf.kakao.com/...'),
          const SizedBox(height: 16),
          CustomTextFormField(controller: TextEditingController(), label: '주소', hintText: '예) 서울 성수동 ...'),
          const SizedBox(height: 16),
          CustomTextFormField(controller: TextEditingController(), label: '지도 링크', hintText: '네이버/카카오 지도 URL'),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return StandardContentCard(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('갤러리 추가'),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return StandardContentCard(
      child: Column(
        children: [
          // 시작/마감 시간 설정 버튼
          Row(
            children: [
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.schedule), label: const Text('시작시간')),
              const SizedBox(width: 8),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.schedule), label: const Text('마감시간')),
            ],
          ),
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          ),
          const SizedBox(height: 16),
          // 휴무/초기화 버튼
          Row(
            children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () {}, icon: const Icon(Icons.toggle_off_outlined), label: const Text('휴무 토글'))),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.refresh), label: const Text('초기화'))),
            ],
          ),
          const SizedBox(height: 16),
          // 시간 설정 안내
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: const Text('시간 설정\n달력에서 날짜를 선택하면 1시간 단위 버튼이 생성됩니다.\n・검은색: 예약 가능 / 회색: 마감 / 휴무일은 전체 비활성화'),
          ),
          const SizedBox(height: 16),
          // 시간 설정 입력 필드
          _buildTimeSettingRow('시작 시간 설정'),
          const SizedBox(height: 16),
          _buildTimeSettingRow('마감 시간 설정'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTimeSettingRow(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title),
            IconButton(onPressed: () {}, icon: const Icon(Icons.close, size: 16)),
          ],
        ),
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(hintText: '-- : --', suffixIcon: Icon(Icons.schedule)),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const CustomTimePicker(),
            );
          },
        ),
      ],
    );
  }
}
