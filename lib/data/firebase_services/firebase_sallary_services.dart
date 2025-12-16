import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSallaryServices {
  Stream<QuerySnapshot> myPayrollStream(String employeeId) {
    return FirebaseFirestore.instance
        .collection('payroll')
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> allPayrollStream() {
    return FirebaseFirestore.instance
        .collection('payroll')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> generatePayroll({
    required String employeeId,
    required Map<String, num> earnings,
    required Map<String, num> deductions,
  }) async {
    final gross = earnings.values.reduce((a, b) => a + b);
    final totalDeductions = deductions.values.reduce((a, b) => a + b);

    await FirebaseFirestore.instance.collection('payroll').add({
      'employeeId': employeeId,
      'earnings': earnings,
      'deductions': deductions,
      'gross': gross,
      'totalDeductions': totalDeductions,
      'netPay': gross - totalDeductions,
      'status': 'processed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
