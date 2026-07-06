import 'package:k3h_erp_app/utils/functions/common_function.dart';

class IbmObmReportModel {
  final int employeeId;
  final String fullName;
  final String designationName;
  final List<IbmObmStageDataModel> ibmObmStagesData;

  IbmObmReportModel({
    required this.employeeId,
    required this.fullName,
    required this.designationName,
    required this.ibmObmStagesData,
  });

  factory IbmObmReportModel.fromJson(Map<String, dynamic> json) =>
      IbmObmReportModel(
        employeeId: parseValue<int>(json, "EmployeeId"),
        fullName: parseValue<String>(json, "FullName"),
        designationName: parseValue<String>(json, "DesignationName"),
        ibmObmStagesData:
            (json["IbmObmStagesData"] as List<dynamic>? ?? [])
                .map((e) => IbmObmStageDataModel.fromJson(e))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "FullName": fullName,
    "DesignationName": designationName,
    "IbmObmStagesData": ibmObmStagesData.map((e) => e.toJson()).toList(),
  };
}

class IbmObmStageDataModel {
  final int employeeId;
  final String fullName;
  final int monthNumber;
  final String monthName;
  final DateTime? date;
  final String stages;
  final int stagesCount;

  IbmObmStageDataModel({
    required this.employeeId,
    required this.fullName,
    required this.monthNumber,
    required this.monthName,
    this.date,
    required this.stages,
    required this.stagesCount,
  });

  factory IbmObmStageDataModel.fromJson(Map<String, dynamic> json) =>
      IbmObmStageDataModel(
        employeeId: parseValue<int>(json, "EmployeeId"),
        fullName: parseValue<String>(json, "FullName"),
        monthNumber: parseValue<int>(json, "MonthNumber"),
        monthName: parseValue<String>(json, "MonthName"),
        date: json["Date"] == null ? null : parseValue<DateTime>(json, "Date"),
        stages: parseValue<String>(json, "Stages"),
        stagesCount: parseValue<int>(json, "StagesCount"),
      );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "FullName": fullName,
    "MonthNumber": monthNumber,
    "MonthName": monthName,
    "Date": date?.toIso8601String(),
    "Stages": stages,
    "StagesCount": stagesCount,
  };
}
