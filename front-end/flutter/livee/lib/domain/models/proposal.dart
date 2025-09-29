/// '제안' 정보의 구조를 정의하는 데이터 모델
class Proposal {
  final String id;
  final Recipient recipient;
  final String? content;
  final String status;
  final DateTime sentAt;
  final int? fee;
  final bool isFeeNegotiable;
  final String? schedule;
  final DateTime? replyDeadline;

  Proposal({
    required this.id,
    required this.recipient,
    this.content,
    required this.status,
    required this.sentAt,
    this.fee,
    required this.isFeeNegotiable,
    this.schedule,
    this.replyDeadline,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'] as String,
      recipient: Recipient.fromJson(json['recipient']),
      content: json['content'] as String?,
      status: json['status'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      fee: json['fee'] as int?,
      isFeeNegotiable: json['isFeeNegotiable'] as bool,
      schedule: json['schedule'] as String?,
      replyDeadline: json['replyDeadline'] != null
          ? DateTime.parse(json['replyDeadline'] as String)
          : null,
    );
  }
}

/// 제안 받는 사람의 정보를 담는 보조 모델
class Recipient {
  final String name;
  final String portfolioId;

  Recipient({required this.name, required this.portfolioId});

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      name: json['name'] as String,
      portfolioId: json['portfolioId'] as String,
    );
  }
}
