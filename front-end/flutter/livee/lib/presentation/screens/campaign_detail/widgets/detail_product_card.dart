import 'package:flutter/material.dart';
import 'package:livee/domain/models/product.dart';

// '상품 캠페인'의 개별 상품 정보를 표시하는 카드 위젯
class DetailProductCard extends StatelessWidget {
  final Product product;

  const DetailProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // 상품 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.thumbnail ??
                    'https://picsum.photos/seed/${product.title}/128/128',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[200],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 상품 제목 및 가격
            Expanded(
              child: Text(
                product.title ?? '상품명 미정',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${product.price?.toInt() ?? 0}원',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
