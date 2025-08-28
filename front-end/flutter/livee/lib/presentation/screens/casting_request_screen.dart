import 'package:flutter/material.dart';

/// 브랜드가 쇼호스트에게 섭외를 요청하는 폼 화면
class CastingRequestScreen extends StatefulWidget {
  final String showhostId;

  const CastingRequestScreen({
    super.key,
    required this.showhostId,
  });

  @override
  State<CastingRequestScreen> createState() => _CastingRequestScreenState();
}

class _CastingRequestScreenState extends State<CastingRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쇼호스트 섭외 요청'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '업체명',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.isEmpty ?? true) ? '업체명을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '상품/서비스',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.isEmpty ?? true) ? '상품/서비스를 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '희망 방송 날짜',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.isEmpty ?? true) ? '희망 방송 날짜를 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '전달 메시지',
                  hintText: '출연 조건, 촬영 장소 등 메모를 남겨주세요',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) => (value?.isEmpty ?? true) ? '메시지를 입력해주세요.' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: API 연동하여 섭외 요청 전송
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('섭외 요청이 전송되었습니다.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('섭외 요청하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
