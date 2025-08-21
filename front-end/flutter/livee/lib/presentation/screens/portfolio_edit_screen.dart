import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';

// 쇼호스트가 자신의 포트폴리오를 등록/수정하는 화면
class PortfolioEditScreen extends StatefulWidget {
  const PortfolioEditScreen({super.key});

  @override
  State<PortfolioEditScreen> createState() => _PortfolioEditScreenState();
}

class _PortfolioEditScreenState extends State<PortfolioEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // 각 필드를 위한 컨트롤러 선언
  final _introductionController = TextEditingController();
  final _careerController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();

  @override
  void dispose() {
    // 위젯이 제거될 때 컨트롤러 리소스를 해제하여 메모리 누수 방지
    _introductionController.dispose();
    _careerController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 포트폴리오 관리'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _introductionController,
                label: '한 줄 자기소개',
                hint: '시청자의 마음을 사로잡는 쇼호스트 OOO입니다.',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _careerController,
                label: '주요 경력',
                hint: '- 2024년 OOO 뷰티 라이브 진행\n- 2023년 OOO 푸드 라이브 진행',
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _instagramController,
                label: '인스타그램 링크',
                hint: 'https://instagram.com/livee_official',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _youtubeController,
                label: '유튜브/영상 링크',
                hint: '포트폴리오 영상을 확인할 수 있는 링크',
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: 폼 저장 로직 구현
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('포트폴리오가 저장되었습니다.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('저장하기'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  /// 공통 텍스트 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true, // 여러 줄일 때 라벨이 상단에 위치하도록
      ),
      maxLines: maxLines,
    );
  }
}
