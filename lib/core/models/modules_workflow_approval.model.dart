import 'package:k3h_erp_app/utils/common_function.dart';

class ModulesWorkflowApprovalModel {
  String moduleName;
  int modulesMasterId;
  int subModulesMasterId;
  int subSubModulesMasterId;
  String subSubModuleName;
  List<dynamic> employeeData;

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
        employeeData: List<dynamic>.from(json["EmployeeData"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "ModuleName": moduleName,
    "ModulesMasterId": modulesMasterId,
    "SubModulesMasterId": subModulesMasterId,
    "SubSubModulesMasterId": subSubModulesMasterId,
    "SubSubModuleName": subSubModuleName,
    "EmployeeData": List<dynamic>.from(employeeData.map((x) => x)),
  };
}