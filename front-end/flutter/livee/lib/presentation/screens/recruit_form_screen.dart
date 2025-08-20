import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class RecruitFormScreen extends StatefulWidget {
  final String? recruitId;

  const RecruitFormScreen({
    super.key,
    this.recruitId,
  });

  @override
  State<RecruitFormScreen> createState() => _RecruitFormScreenState();
}

class _RecruitFormScreenState extends State<RecruitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _payController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;
  bool _payNegotiable = false;

  @override
  void initState() {
    super.initState();
    if (widget.recruitId != null) {
      _loadRecruitData();
    }
  }

  // 기존 데이터 불러오기
  Future<void> _loadRecruitData() async {
    setState(() => _isLoading = true);
    try {
      final campaign = await Provider.of<CampaignUseCase>(context, listen: false).getCampaignById(widget.recruitId!);
      final recruit = campaign.recruit;
      if (recruit != null) {
        _titleController.text = recruit.title ?? '';
        _dateController.text = recruit.date ?? '';
        _timeController.text = recruit.timeStart ?? '';
        _locationController.text = recruit.location ?? '';
        _payController.text = recruit.pay ?? '';
        _payNegotiable = recruit.payNegotiable ?? false;
        _categoryController.text = recruit.category ?? '';
        _descController.text = recruit.description ?? '';
        _imageUrlController.text = campaign.coverImageUrl ?? '';
      }
    } catch (e) {
      debugPrint('Error loading recruit data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 이미지 업로드 위젯
  Widget _buildImageUploader() {
    return Column(
      children: [
        if (_imageUrlController.text.isNotEmpty)
          Image.network(_imageUrlController.text)
        else
          Container(
            height: 150,
            color: Colors.grey[200],
            child: const Center(child: Text('썸네일 미리보기')),
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.single.bytes != null) {
                    setState(() => _isLoading = true);
                    try {
                      final url = await CloudinaryUploader().uploadImage(result.files.single.bytes!);
                      _imageUrlController.text = url;
                    } catch (e) {
                      // TODO: 에러 처리
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  }
                },
          child: _isLoading ? const CircularProgressIndicator() : const Text('파일 선택'),
        ),
      ],
    );
  }

  // 폼 필드 위젯
  Widget _buildTextField(TextEditingController controller, String label, String hint,
      {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return '$label을(를) 입력해주세요.';
        }
        return null;
      },
      maxLines: maxLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recruitId == null ? '공고 등록' : '공고 수정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImageUploader(),
              const SizedBox(height: 16),
              _buildTextField(_titleController, '제목', '예) 잘 먹는 쇼호스트 찾습니다', required: true),
              _buildTextField(_brandController, '브랜드', '예) ALPA'),
              _buildTextField(_dateController, '촬영일', '', required: true),
              _buildTextField(_timeController, '촬영시간', '예) 14:00'),
              _buildTextField(_locationController, '촬영 장소', '예) 서울 강남구 ○○스튜디오'),
              _buildTextField(_payController, '출연료', '예) 30만원'),
              CheckboxListTile(
                title: const Text('협의 가능'),
                value: _payNegotiable,
                onChanged: (bool? newValue) {
                  setState(() {
                    _payNegotiable = newValue ?? false;
                  });
                },
              ),
              _buildTextField(_categoryController, '상품군', '예) 뷰티/패션/가전'),
              _buildTextField(_descController, '요구사항/우대사항', '방송 내용, 요구 스킬, 우대사항 등을 상세히 적어주세요.', maxLines: 7),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          // TODO: 폼 데이터 전송 로직 구현
                        }
                      },
                child:
                    _isLoading ? const CircularProgressIndicator() : Text(widget.recruitId == null ? '등록하기' : '수정 완료'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }
}
