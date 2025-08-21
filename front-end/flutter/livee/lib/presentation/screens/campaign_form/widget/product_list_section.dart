import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';

// 등록된 상품 목록을 보여주는 위젯
class ProductListSection extends StatelessWidget {
  final CampaignFormProvider provider;

  const ProductListSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: provider.products.isEmpty
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '아직 등록된 상품이 없습니다.',
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: product.thumbnail != null &&
                            product.thumbnail!.isNotEmpty
                        ? Image.network(
                            product.thumbnail!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey[200],
                          ),
                    title: Text(product.title ?? '제목 없음'),
                    subtitle: Text('${product.price?.toInt() ?? 0}원'),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => provider.removeProduct(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
