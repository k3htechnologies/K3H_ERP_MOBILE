import 'package:k3h_erp_app/utils/functions/common_function.dart';

class AttendanceRegularizationModel {
  final int attendanceRegularizationId;
  final DateTime attendanceDate;
  final DateTime? punchIn;
  final DateTime? punchOut;
  final String reason;
  final int createdById;
  final String createdBy;
  final DateTime? createdDate;
  final int modifiedById;
  final String modifiedBy;
  final DateTime? modifiedDate;

  AttendanceRegularizationModel({
    required this.attendanceRegularizationId,
    required this.attendanceDate,
    required this.punchIn,
    required this.punchOut,
    required this.reason,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
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
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate:
          json["CreatedDate"] == null
              ? null
              : parseValue<DateTime>(json, "CreatedDate"),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate:
          json["ModifiedDate"] == null
              ? null
              : parseValue<DateTime>(json, "ModifiedDate"),
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
      "CreatedById": createdById,
      "CreatedBy": createdBy,
      "CreatedDate": createdDate?.toIso8601String(),
      "ModifiedById": modifiedById,
      "ModifiedBy": modifiedBy,
      "ModifiedDate": modifiedDate?.toIso8601String(),
    };
  }
}
