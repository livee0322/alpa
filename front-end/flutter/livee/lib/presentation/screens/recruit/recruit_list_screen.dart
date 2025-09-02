import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/recruit_list_provider.dart';
import 'package:livee/presentation/widgets/buttons/secondary_chip_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/recruit_list_card.dart';
import 'package:provider/provider.dart';

class RecruitListScreen extends StatefulWidget {
  const RecruitListScreen({super.key});

  @override
  State<RecruitListScreen> createState() => _RecruitListScreenState();
}

class _RecruitListScreenState extends State<RecruitListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드될 때 공고 데이터를 불러오기
    WidgetsBinding.instance
        .addPostFrameCallback((_) => Provider.of<RecruitListProvider>(context, listen: false).fetchRecruits());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공고 모아보기'),
      ),
      body: Consumer<RecruitListProvider>(
        builder: (context, provider, child) => Column(
          children: [
            // 필터 탭 영역
            _buildFilterTabs(provider),
            // 공고 목록 영역
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.filteredRecruits.isEmpty
                      ? const Center(child: Text('조건에 맞는 공고가 아직 없어요.'))
                      : _buildRecruitList(provider),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  // 필터 탭 UI를 빌드하는 위젯
  Widget _buildFilterTabs(RecruitListProvider provider) {
    // 웹 버전의 필터 목록
    final filters = {
      'deadline': '⏳ 마감일 임박',
      'mukbang': '🍜 먹방 전용',
      'beauty': '💄 뷰티',
      'pay': '💸 출연료 미쳤다',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.entries.map((entry) {
          final isSelected = provider.activeFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SecondaryChipButton(
              text: entry.value,
              isSelected: isSelected,
              onPressed: () => provider.applyFilter(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 필터링된 공고 목록을 ListView로 빌드하는 위젯
  Widget _buildRecruitList(RecruitListProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2열 그리드
        crossAxisSpacing: 14, // 가로 간격
        mainAxisSpacing: 14, // 세로 간격
        childAspectRatio: 0.65, // 카드 비율 (가로/세로)
      ),
      itemCount: provider.filteredRecruits.length,
      itemBuilder: (context, index) {
        final campaign = provider.filteredRecruits[index];
        // ListTile 대신 새로 만든 RecruitListCard 위젯을 사용
        return RecruitListCard(campaign: campaign);
      },
    );
  }
}
