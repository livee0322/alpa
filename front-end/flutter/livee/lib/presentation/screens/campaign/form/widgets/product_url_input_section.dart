import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';

// 상품 URL을 입력하고 불러오기 기능을 담당하는 위젯
class ProductUrlInputSection extends StatelessWidget {
  final CampaignFormProvider provider;

  const ProductUrlInputSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '상품 등록',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: provider.productUrlController,
                decoration: const InputDecoration(
                  hintText: '네이버/쿠팡 등 상품 URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // '불러오기' 버튼
            SizedBox(
              height: 60, // TextFormField 높이에 맞춤
              child: ElevatedButton(
                onPressed:
                    provider.isLoading ? null : () => _addProduct(context),
                child: const Text('불러오기'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 상품 URL로 상품 정보를 불러오는 메소드
  Future<void> _addProduct(BuildContext context) async {
    final url = provider.productUrlController.text;
    if (url.trim().isEmpty) return;

    provider.setLoading(true);
    try {
      await provider.addProductFromUrl(url);
      provider.productUrlController.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('상품을 추가했습니다.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('상품 불러오기 실패: $e')));
      }
    } finally {
      provider.setLoading(false);
    }
  }
}
