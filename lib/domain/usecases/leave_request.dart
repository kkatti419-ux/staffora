import 'package:staffora/data/models/api_models/user/leave_request.dart';

class LeaveData {
  static List<LeaveRequest> leaveRequests = [];

  static void addLeave(LeaveRequest request) {
    leaveRequests.add(request);
  }

  static void updateStatus(String id, String newStatus) {
    final index = leaveRequests.indexWhere((e) => e.id == id);
    if (index != -1) {
      leaveRequests[index].status = newStatus;
    }
  }
}
