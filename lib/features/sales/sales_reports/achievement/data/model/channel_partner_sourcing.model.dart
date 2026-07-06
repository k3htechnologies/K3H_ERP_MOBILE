import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ChannelPartnerSourcingModel {
  final String projectName;
  final String systemGeneratedCode;
  final String name;
  final String firmsType;
  final String type;
  final String designation;
  final String reraNumber;
  final String gstNumber;
  final String speciality;
  final String officeAddress;
  final String ibmObm;
  final String sourcingRemark;
  final String support;
  final String createdBy;
  final DateTime createdDate;
  final String modifiedBy;
  final DateTime? modifiedDate;

  ChannelPartnerSourcingModel({
    required this.projectName,
    required this.systemGeneratedCode,
    required this.name,
    required this.firmsType,
    required this.type,
    required this.designation,
    required this.reraNumber,
    required this.gstNumber,
    required this.speciality,
    required this.officeAddress,
    required this.ibmObm,
    required this.sourcingRemark,
    required this.support,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedBy,
    this.modifiedDate,
  });

  factory ChannelPartnerSourcingModel.fromJson(Map<String, dynamic> json) =>
      ChannelPartnerSourcingModel(
        projectName: parseValue<String>(json, "ProjectName"),
        systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
        name: parseValue<String>(json, "Name"),
        firmsType: parseValue<String>(json, "FirmsType"),
        type: parseValue<String>(json, "Type"),
        designation: parseValue<String>(json, "Designation"),
        reraNumber: parseValue<String>(json, "RERANumber"),
        gstNumber: parseValue<String>(json, "GSTNumber"),
        speciality: parseValue<String>(json, "Speciality"),
        officeAddress: parseValue<String>(json, "OfficeAddress"),
        ibmObm: parseValue<String>(json, "IBM_OBM"),
        sourcingRemark: parseValue<String>(json, "SourcingRemark"),
        support: parseValue<String>(json, "Support"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "ProjectName": projectName,
    "SystemGeneratedCode": systemGeneratedCode,
    "Name": name,
    "FirmsType": firmsType,
    "Type": type,
    "Designation": designation,
    "RERANumber": reraNumber,
    "GSTNumber": gstNumber,
    "Speciality": speciality,
    "OfficeAddress": officeAddress,
    "IBM_OBM": ibmObm,
    "SourcingRemark": sourcingRemark,
    "Support": support,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
