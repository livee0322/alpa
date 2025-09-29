import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/models/proposal.dart';
import 'package:livee/domain/repositories/proposal_repository.dart';

/// '제안하기' 관련 비즈니스 로직을 처리하는 유스케이스
class ProposalUseCase {
  final ProposalRepository _repository;

  ProposalUseCase(this._repository);

  /// 새로운 제안을 생성하는 로직
  Future<void> createProposal(Map<String, dynamic> data) {
    return _repository.createProposal(data);
  }

  // 보낸 제안 목록을 조회하는 로직
  Future<PaginatedResponse<Proposal>> getSentProposals({
    String? status,
    int page = 1,
  }) {
    return _repository.getSentProposals(status: status, page: page);
  }
}
