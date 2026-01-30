import 'package:k3h_erp_app/utils/common_function.dart';

class AttendanceRegularizationModel {
  final int attendanceRegularizationId;
  final DateTime attendanceDate;
  final DateTime? punchIn;
  final DateTime? punchOut;
  final String reason;

  AttendanceRegularizationModel({
    required this.attendanceRegularizationId,
    required this.attendanceDate,
    required this.punchIn,
    required this.punchOut,
    required this.reason,
  });

  /// FROM JSON
  factory AttendanceRegularizationModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRegularizationModel(
      attendanceRegularizationId: parseValue<int>(
        json,
        'AttendanceRegularizationId',
      ),
      attendanceDate: parseValue<DateTime>(json, 'AttendanceDate'),
      punchIn: parseValue<DateTime>(json, 'PunchIn'),
      punchOut: DateTime.parse(json['PunchOut']),
      reason: parseValue<String>(json, 'Reason'),
    );
  }

  /// TO JSON
  Map<String, dynamic> toJson() {
    return {
      'AttendanceRegularizationId': attendanceRegularizationId,
      'AttendanceDate': attendanceDate.toIso8601String(),
      'PunchIn': punchIn?.toIso8601String(),
      'PunchOut': punchOut?.toIso8601String(),
      'Reason': reason,
    };
  }
}
