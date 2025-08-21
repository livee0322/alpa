import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/recruit_list_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<RecruitListProvider>(context, listen: false)
            .fetchRecruits());
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
            child: ElevatedButton(
              onPressed: () => provider.applyFilter(entry.key),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? const Color(0xFF6C63FF) : Colors.white,
                foregroundColor: isSelected ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.grey[300]!,
                  ),
                ),
              ),
              child: Text(entry.value),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 필터링된 공고 목록을 ListView로 빌드하는 위젯
  Widget _buildRecruitList(RecruitListProvider provider) {
    // MainScreen의 RecruitSection 카드 UI를 재사용/참고하여 구현
    // 여기서는 간단하게 ListTile로 대체합니다. (추후 카드 위젯으로 교체 가능)
    return ListView.builder(
      itemCount: provider.filteredRecruits.length,
      itemBuilder: (context, index) {
        final campaign = provider.filteredRecruits[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: campaign.coverImageUrl != null
                ? Image.network(
                    campaign.coverImageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[200],
                  ),
            title: Text(
              campaign.title ?? '제목 없음',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(campaign.brand ?? '브랜드 미정'),
            onTap: () {
              // TODO: 상세 페이지로 이동
            },
          ),
        );
      },
    );
  }
}
