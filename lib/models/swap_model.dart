class Swap {
  final String id;
  final String requesterId;
  final String receiverId;
  final String requesterBookId;
  final String receiverBookId;
  final String status;
  final DateTime createdAt;
  final List<String> participants;

  Swap({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.requesterBookId,
    required this.receiverBookId,
    required this.status,
    required this.createdAt,
    required this.participants,
  });

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'receiverId': receiverId,
      'requesterBookId': requesterBookId,
      'receiverBookId': receiverBookId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'participants': participants,
    };
  }

  factory Swap.fromMap(Map<String, dynamic> map, String id) {
    return Swap(
      id: id,
      requesterId: map['requesterId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      requesterBookId: map['requesterBookId'] ?? '',
      receiverBookId: map['receiverBookId'] ?? '',
      status: map['status'] ?? 'Pending',
      createdAt: DateTime.parse(map['createdAt']),
      participants: List<String>.from(map['participants'] ?? []),
    );
  }
}
