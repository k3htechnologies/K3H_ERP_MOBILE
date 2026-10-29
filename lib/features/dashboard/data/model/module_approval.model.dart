import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ModuleApprovalModel {
  String moduleName;
  String projectName;
  String buildingNumber;
  String wing;
  String floor;
  String flat;
  String applicantName;
  String projectDocumentName;
  String projectDocumentCategory;
  String nameOfInstitutionBankNbfc;
  String modulePath;
  String systemGeneratedCode;
  String paymentFor;
  String fileName;
  String flatAlterationRemark;
  ModuleApprovalModel({
    required this.moduleName,
    required this.projectName,
    required this.buildingNumber,
    required this.wing,
    required this.floor,
    required this.flat,
    required this.applicantName,
    required this.projectDocumentName,
    required this.projectDocumentCategory,
    required this.nameOfInstitutionBankNbfc,
    required this.modulePath,
    required this.systemGeneratedCode,
    required this.paymentFor,
    required this.fileName,
    required this.flatAlterationRemark,
  });

  factory ModuleApprovalModel.fromJson(Map<String, dynamic> json) =>
      ModuleApprovalModel(
        moduleName: parseValue<String>(json, "ModuleName"),
        projectName: parseValue<String>(json, "ProjectName"),
        buildingNumber: parseValue<String>(json, "BuildingNumber"),
        wing: parseValue<String>(json, "Wing"),
        floor: parseValue<String>(json, "Floor"),
        flat: parseValue<String>(json, "Flat"),
        applicantName: parseValue<String>(json, "ApplicantName"),
        projectDocumentName: parseValue<String>(json, "ProjectDocumentName"),
        projectDocumentCategory: parseValue<String>(
          json,
          "ProjectDocumentCategory",
        ),
        nameOfInstitutionBankNbfc: parseValue<String>(
          json,
          "NameOfInstitutionBankNBFC",
        ),
        modulePath: parseValue<String>(json, "ModulePath"),
        systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
        paymentFor: parseValue<String>(json, "PaymentFor"),
        fileName: parseValue<String>(json, "FileName"),
        flatAlterationRemark: parseValue<String>(json, "FlatAlterationRemark"),
      );

  Map<String, dynamic> toJson() => {
    "ModuleName": moduleName,
    "ProjectName": projectName,
    "BuildingNumber": buildingNumber,
    "Wing": wing,
    "Floor": floor,
    "Flat": flat,
    "ApplicantName": applicantName,
    "ProjectDocumentName": projectDocumentName,
    "ProjectDocumentCategory": projectDocumentCategory,
    "NameOfInstitutionBankNBFC": nameOfInstitutionBankNbfc,
    "ModulePath": modulePath,
    "SystemGeneratedCode": systemGeneratedCode,
    "PaymentFor": paymentFor,
    "FileName": fileName,
    "FlatAlterationRemark": flatAlterationRemark,
  };
}
