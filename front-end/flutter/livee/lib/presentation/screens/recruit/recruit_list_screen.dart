import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/recruit_list_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';
import 'package:livee/presentation/widgets/new_recruit_card.dart';
import 'package:provider/provider.dart';

class RecruitListScreen extends StatefulWidget {
  const RecruitListScreen({super.key});

  @override
  State<RecruitListScreen> createState() => _RecruitListScreenState();
}

class _RecruitListScreenState extends State<RecruitListScreen> {
  // 검색창 입력을 관리할 컨트롤러
  final _searchController = TextEditingController();

  // 정렬 옵션을 관리하기 위한 맵(Map)
  // key: API에 보낼 값, value: UI에 표시할 텍스트
  final Map<String, String> _sortOptions = {
    'latest': '최신 등록순',
    'deadline': '마감 임박순',
  };

  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드될 때 공고 데이터를 불러오기
    WidgetsBinding.instance
        .addPostFrameCallback((_) => Provider.of<RecruitListProvider>(context, listen: false).fetchRecruits());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // provider 변수를 build 메소드 상단에서 선언하여 여러 곳에서 사용
    final provider = Provider.of<RecruitListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('모집 공고'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 검색창
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '제목·내용·브랜드로 검색',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => provider.search(_searchController.text),
                    ),
                  ),
                  onSubmitted: (value) => provider.search(value),
                ),
                const SizedBox(height: 8),
                // 정렬 드롭다운
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('총 ${provider.totalRecruits}건'),
                    SizedBox(
                      width: 140, // 드롭다운 너비 지정
                      child: CustomDropdown(
                        menuOffset: Offset(0, 42),
                        // 현재 선택된 정렬 key에 해당하는 표시 텍스트를 value로 전달
                        value: _sortOptions[provider.sortBy] ?? '정렬 기준',
                        // 표시할 텍스트 목록을 items로 전달
                        items: _sortOptions.values.toList(),
                        onChanged: (String? selectedValue) {
                          // 선택된 표시 텍스트(selectedValue)를 통해 key를 찾아서 API 요청
                          final sortKey = _sortOptions.entries
                              .firstWhere(
                                (entry) => entry.value == selectedValue,
                              )
                              .key;
                          provider.setSortBy(sortKey);
                        },
                        fontSize: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        fontWeight: FontWeight.w900,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.filteredRecruits.isEmpty
                    ? const Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('표시할 공고가 없습니다.'),
                          Text('검색어나 필터를 조정해보세요.'),
                        ],
                      ))
                    : _buildRecruitList(provider),
          ),
          // 페이지네이션 기능 연결
          if (provider.totalPages > 1) _buildPaginationControls(provider),
        ],
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  Widget _buildRecruitList(RecruitListProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.filteredRecruits.length,
      itemBuilder: (context, index) {
        final campaign = provider.filteredRecruits[index];
        return NewRecruitCard(campaign: campaign);
      },
    );
  }

  // 페이지네이션 컨트롤 위젯 기능 완성
  Widget _buildPaginationControls(RecruitListProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: provider.currentPage > 1 ? () => provider.goToPage(1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.currentPage > 1 ? () => provider.goToPage(provider.currentPage - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${provider.currentPage} / ${provider.totalPages}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                provider.currentPage < provider.totalPages ? () => provider.goToPage(provider.currentPage + 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: provider.currentPage < provider.totalPages ? () => provider.goToPage(provider.totalPages) : null,
          ),
        ],
      ),
    );
  }
}
