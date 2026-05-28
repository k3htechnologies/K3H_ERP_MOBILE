import 'package:k3h_erp_app/utils/common_function.dart';

class AttendanceModel {
  int employeeId;
  String fullName;
  int attendanceId;
  final String uniquekey;
  DateTime attendanceDate;
  DateTime? punchIn;
  DateTime? punchOut;
  String punchInAddress;
  String punchOutAddress;
  String workingHours;
  String attendanceStatus;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final String polyline;
  final double distance;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  AttendanceModel({
    required this.employeeId,
    required this.fullName,
    required this.uniquekey,
    required this.attendanceId,
    required this.attendanceDate,
    this.punchIn,
    this.punchOut,
    required this.punchInAddress,
    required this.punchOutAddress,
    required this.workingHours,
    required this.attendanceStatus,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.polyline,
    required this.distance,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        employeeId: parseValue<int>(json, "EmployeeId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        fullName: parseValue<String>(json, "FullName"),
        attendanceId: parseValue<int>(json, "AttendanceId"),
        attendanceDate: parseValue<DateTime>(json, "AttendanceDate"),
        punchIn: parseApiDate(json["PunchIn"]),
        punchOut: parseApiDate(json["PunchOut"]),
        punchInAddress: parseValue<String>(json, "PunchInAddress"),
        punchOutAddress: parseValue<String>(json, "PunchOutAddress"),
        workingHours: json["WorkingHours"],
        attendanceStatus: parseValue<String>(json, "AttendanceStatus"),
        startLatitude: parseValue<double>(json, "StartLatitude").toDouble(),
        startLongitude: parseValue<double>(json, "StartLongitude").toDouble(),
        endLatitude: parseValue<double>(json, "EndLatitude").toDouble(),
        endLongitude: parseValue<double>(json, "EndLongitude").toDouble(),
        polyline: parseValue<String>(json, "Polyline"),
        distance: parseValue<double>(json, "Distance"),
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

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "Uniquekey": uniquekey,
    "FullName": fullName,
    "AttendanceId": attendanceId,
    "AttendanceDate": attendanceDate.toIso8601String(),
    "PunchIn": punchIn?.toIso8601String(),
    "PunchOut": punchOut?.toIso8601String(),
    "PunchInAddress": punchInAddress,
    "PunchOutAddress": punchOutAddress,
    "WorkingHours": workingHours,
    "AttendanceStatus": attendanceStatus,
    "StartLatitude": startLatitude,
    "StartLongitude": startLongitude,
    "EndLatitude": endLatitude,
    "EndLongitude": endLongitude,
    "Polyline": polyline,
    "Distance": distance,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
