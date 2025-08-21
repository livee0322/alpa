import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';

class ProductSection extends StatelessWidget {
  // 부모 위젯(MainScreen)으로부터 Future 데이터를 전달받음
  final Future<List<Campaign>> productsFuture;

  const ProductSection({
    super.key,
    required this.productsFuture,
  });
  @override
  Widget build(BuildContext context) {
    // FutureBuilder를 사용하여 비동기 데이터를 UI로 변환
    return FutureBuilder<List<Campaign>>(
      future: productsFuture,
      builder: (context, snapshot) {
        // 로딩 중일 때
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // 에러 발생 시
        if (snapshot.hasError) {
          return const Center(child: Text('상품 로딩 실패'));
        }
        // 데이터가 없거나 비어있을 때
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('등록된 상품 캠페인이 없습니다'));
        }

        // 데이터가 있을 때 2열 그리드 뷰로 표시
        final items = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true, // SingleChildScrollView 안에서 사용하기 위함
          physics: const NeverScrollableScrollPhysics(), // 부모 스크롤과 충돌 방지
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2열
            crossAxisSpacing: 12, // 아이템 간 가로 간격
            mainAxisSpacing: 12, // 아이템 간 세로 간격
            childAspectRatio: 0.72, // 아이템의 가로세로 비율
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final campaign = items[index];
            final price = campaign.products?.first.price;

            // 웹 버전의 .lv-g-card 스타일을 참고한 카드 위젯
            return InkWell(
              onTap: () =>
                  GoRouter.of(context).push('/campaign/${campaign.id}'),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias, // 이미지 radius 적용
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품 이미지
                    AspectRatio(
                      aspectRatio: 1, // 1:1 비율
                      child: Image.network(
                        campaign.coverImageUrl ??
                            'https://picsum.photos/seed/${campaign.id}/300/300',
                        fit: BoxFit.cover,
                        // 이미지 로딩 중 에러 발생 시 대체 이미지 표시
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.error)),
                      ),
                    ),
                    // 상품 정보
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign.brand ?? '브랜드 미정',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9AA3AF),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Flexible(
                              child: Text(
                                campaign.title ?? '상품명 미정',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(), // 남은 공간을 채워 가격을 하단에 고정
                            Text(
                              price != null ? '${price.toInt()}원' : '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
