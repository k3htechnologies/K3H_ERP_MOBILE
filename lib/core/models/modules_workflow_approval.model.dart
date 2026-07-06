import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ModulesWorkflowApprovalModel {
  String moduleName;
  int modulesMasterId;
  int subModulesMasterId;
  int subSubModulesMasterId;
  String subSubModuleName;
  List<ModulesApprovalEmployeeDataModel> employeeData;

  ModulesWorkflowApprovalModel({
    required this.moduleName,
    required this.modulesMasterId,
    required this.subModulesMasterId,
    required this.subSubModulesMasterId,
    required this.subSubModuleName,
    required this.employeeData,
  });

  factory ModulesWorkflowApprovalModel.fromJson(Map<String, dynamic> json) =>
      ModulesWorkflowApprovalModel(
        moduleName: parseValue<String>(json, "ModuleName"),
        modulesMasterId: parseValue<int>(json, "ModulesMasterId"),
        subModulesMasterId: parseValue<int>(json, "SubModulesMasterId"),
        subSubModulesMasterId: parseValue<int>(json, "SubSubModulesMasterId"),
        subSubModuleName: parseValue<String>(json, "SubSubModuleName"),
        employeeData: List<ModulesApprovalEmployeeDataModel>.from(
          json["EmployeeData"].map(
            (x) => ModulesApprovalEmployeeDataModel.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
    "ModuleName": moduleName,
    "ModulesMasterId": modulesMasterId,
    "SubModulesMasterId": subModulesMasterId,
    "SubSubModulesMasterId": subSubModulesMasterId,
    "SubSubModuleName": subSubModuleName,
    "EmployeeData": List<dynamic>.from(employeeData.map((x) => x.toJson())),
  };
}

class ModulesApprovalEmployeeDataModel {
  int employeeId;
  String employeeCode;
  String fullName;
  String? emailId;
  String? officeEmailId;
  String? personalMobileNumber;
  String? department;
  String designation;
  String? branch;
  String? approvalStatus;
  String? remarks;
  DateTime? date;

  ModulesApprovalEmployeeDataModel({
    required this.employeeId,
    required this.employeeCode,
    required this.fullName,
    this.emailId,
    this.officeEmailId,
    this.personalMobileNumber,
    this.department,
    required this.designation,
    this.branch,
    this.approvalStatus,
    this.remarks,
    this.date,
  });

  factory ModulesApprovalEmployeeDataModel.fromJson(
    Map<String, dynamic> json,
  ) => ModulesApprovalEmployeeDataModel(
    employeeId: parseValue<int>(json, "EmployeeId"),
    employeeCode: parseValue<String>(json, "EmployeeCode"),
    fullName: parseValue<String>(json, "FullName"),
    emailId: parseValue<String>(json, "EmailId"),
    officeEmailId: parseValue<String>(json, "OfficeEmailId"),
    personalMobileNumber: parseValue<String>(json, "PersonalMobileNumber"),
    department: parseValue<String>(json, "Department"),
    designation: parseValue<String>(json, "Designation"),
    branch: parseValue<String>(json, "Branch"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    remarks: parseValue<String>(json, "Remarks"),
    date: json["Date"] == null ? null : parseValue<DateTime>(json, "Date"),
  );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "EmployeeCode": employeeCode,
    "FullName": fullName,
    "EmailId": emailId,
    "OfficeEmailId": officeEmailId,
    "PersonalMobileNumber": personalMobileNumber,
    "Department": department,
    "Designation": designation,
    "Branch": branch,
    "ApprovalStatus": approvalStatus,
    "Remarks": remarks,
    "Date": date?.toIso8601String(),
  };
}
