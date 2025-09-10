import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/campaign/vm/applicant_list_view_model.dart';
import 'package:provider/provider.dart';

class ApplicantListScreen extends StatelessWidget {
  final String campaignId;

  const ApplicantListScreen({
    super.key,
    required this.campaignId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApplicantListViewModel(campaignId: campaignId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('지원자 현황'),
        ),
        body: Consumer<ApplicantListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage!));
            }
            if (viewModel.applicants.isEmpty) {
              return const Center(
                child: Text(
                  '아직 지원자가 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: viewModel.applicants.length,
              itemBuilder: (context, index) {
                final applicant = viewModel.applicants[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          applicant.mainThumbnailUrl != null ? NetworkImage(applicant.mainThumbnailUrl!) : null,
                      child: applicant.mainThumbnailUrl == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(applicant.nickname ?? '이름 없음'),
                    subtitle: Text(applicant.oneLineIntro ?? '소개 없음'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: 지원자 상세 포트폴리오 보기
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
