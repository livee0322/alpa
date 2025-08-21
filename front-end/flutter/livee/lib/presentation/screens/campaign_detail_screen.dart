import 'package:flutter/material.dart';

class CampaignDetailScreen extends StatelessWidget {
  final String campaignId;

  const CampaignDetailScreen({
    super.key,
    required this.campaignId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캠페인 상세'),
      ),
      body: Center(
        child: Text('캠페인 ID: $campaignId'),
      ),
    );
  }
}
