import 'package:k3h_erp_app/utils/common_function.dart';

class DashboardModel {
  final int employeeId;
  final String uniquekey;
  final String fullName;
  final int attendanceId;
  final DateTime attendanceDate;
  final DateTime? punchIn;
  final DateTime? punchOut;
  final String punchInAddress;
  final String punchOutAddress;
  final String workingHours;
  final String attendanceStatus;
  final int createdById;
  final String createdBy;
  final DateTime createdDate;
  final int modifiedById;
  final String modifiedBy;
  final DateTime modifiedDate;

  DashboardModel({
    required this.employeeId,
    required this.uniquekey,
    required this.fullName,
    required this.attendanceId,
    required this.attendanceDate,
    this.punchIn,
    this.punchOut,
    required this.punchInAddress,
    required this.punchOutAddress,
    required this.workingHours,
    required this.attendanceStatus,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    employeeId: parseValue<int>(json, "EmployeeId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    fullName: parseValue<String>(json, "FullName"),
    attendanceId: parseValue<int>(json, "AttendanceId"),
    attendanceDate: parseValue<DateTime>(json, "AttendanceDate"),
    punchIn: parseApiDate(json["PunchIn"]),
    punchOut: parseApiDate(json["PunchOut"]),
    punchInAddress: parseValue<String>(json, "PunchInAddress"),
    punchOutAddress: parseValue<String>(json, "PunchOutAddress"),
    workingHours: parseValue<String>(json, "WorkingHours"),
    attendanceStatus: parseValue<String>(json, "AttendanceStatus"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate: parseValue<DateTime>(json, "ModifiedDate"),
  );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "Uniquekey": uniquekey,
    "FullName": fullName,
    "AttendanceId": attendanceId,
    "AttendanceDate": attendanceDate,
    "PunchIn": punchIn,
    "PunchOut": punchOut,
    "PunchInAddress": punchInAddress,
    "PunchOutAddress": punchOutAddress,
    "WorkingHours": workingHours,
    "AttendanceStatus": attendanceStatus,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
