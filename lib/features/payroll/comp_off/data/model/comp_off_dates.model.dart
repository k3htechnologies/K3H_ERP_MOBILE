

class CompOffDatesModel {
  DateTime attendanceDate;

  CompOffDatesModel({
    required this.attendanceDate,
  });

  factory CompOffDatesModel.fromJson(Map<String, dynamic> json) => CompOffDatesModel(
    attendanceDate: DateTime.parse(json["AttendanceDate"]),
  );

  Map<String, dynamic> toJson() => {
    "AttendanceDate": attendanceDate.toIso8601String(),
  };
}
