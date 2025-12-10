class LeaveRequest {
  final String id;
  final String userId;
  final String userName;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String? attachment;
  String status; // pending / approved / rejected
  final DateTime appliedOn;

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    this.attachment,
    this.status = "pending",
    required this.appliedOn,
  });
}
