import 'dart:async';

import 'package:flutter/material.dart';

/// 메인 화면에 표시될 자동 스크롤 배너 위젯
class BannerSliderSection extends StatefulWidget {
  const BannerSliderSection({super.key});

  @override
  State<BannerSliderSection> createState() => _BannerSliderSectionState();
}

class _BannerSliderSectionState extends State<BannerSliderSection> {
  // --- 상태 변수 ---
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // --- 목업 데이터: 배너에 표시될 이미지와 텍스트 ---
  final List<Map<String, String>> _bannerData = [
    {
      'imageUrl': 'assets/images/banner_01.jpg',
      'title': '',
      'subtitle': '',
    },
    {
      'imageUrl': 'assets/images/banner_02.jpg',
      'title': '',
      'subtitle': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    // 5초마다 배너가 자동으로 넘어가도록 타이머 설정
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      // [추가] 위젯이 화면에 없을 때는 애니메이션을 실행하지 않도록 방어 코드 추가
      if (!mounted) return;

      if (_currentPage < _bannerData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 위젯이 사라질 때 타이머 해제
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9, // 배너 비율
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. 배너 이미지를 보여주는 PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _bannerData.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final banner = _bannerData[index];
              return _buildBannerItem(banner['imageUrl']!, banner['title']!, banner['subtitle']!);
            },
          ),
          // 2. 현재 페이지를 나타내는 인디케이터(점)
          Positioned(
            bottom: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerData.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8.0,
                  width: _currentPage == index ? 24.0 : 8.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 배너 아이템 UI를 구성하는 메소드
  Widget _buildBannerItem(String imageUrl, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          // image: NetworkImage(imageUrl),
          image: AssetImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // 이미지 위에 어두운 오버레이를 추가하여 텍스트 가독성 확보
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10.0, color: Colors.black54)],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  shadows: [Shadow(blurRadius: 8.0, color: Colors.black54)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
