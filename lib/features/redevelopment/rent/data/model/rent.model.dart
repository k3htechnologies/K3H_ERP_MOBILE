import 'package:k3h_erp_app/utils/common_function.dart';

class RentModel {
  final int tenantApplicantChargesId;
  final int tenantId;
  final int tenantApplicantId;
  final int buildingId;
  final int projectId;
  final String applicantType;
  final String applicantName;
  final String flatNumber;
  final double flatCarpetAreaSqFt;
  final String flatType;
  final String flatConfiguration;
  final String tenure;
  final String stage;
  final double proposedOfferAmount;
  final double amount;
  final String unit;
  final DateTime date;
  final int createdById;
  final String createdBy;
  final DateTime? createdDate;
  final int modifiedById;
  final String modifiedBy;
  final DateTime? modifiedDate;

  RentModel({
    required this.tenantApplicantChargesId,
    required this.tenantId,
    required this.tenantApplicantId,
    required this.buildingId,
    required this.projectId,
    required this.applicantType,
    required this.applicantName,
    required this.flatNumber,
    required this.flatCarpetAreaSqFt,
    required this.flatType,
    required this.flatConfiguration,
    required this.tenure,
    required this.stage,
    required this.proposedOfferAmount,
    required this.amount,
    required this.unit,
    required this.date,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory RentModel.fromJson(Map<String, dynamic> json) => RentModel(
    tenantApplicantChargesId: parseValue<int>(json, "TenantApplicantChargesId"),
    tenantId: parseValue<int>(json, "TenantId"),
    tenantApplicantId: parseValue<int>(json, "TenantApplicantId"),
    buildingId: parseValue<int>(json, "BuildingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    applicantType: parseValue<String>(json, "ApplicantType"),
    applicantName: parseValue<String>(json, "ApplicantName"),
    flatNumber: parseValue<String>(json, "FlatNumber"),
    flatCarpetAreaSqFt: parseValue<double>(json, "FlatCarpetAreaSqFt"),
    flatType: parseValue<String>(json, "FlatType"),
    flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
    tenure: parseValue<String>(json, "Tenure"),
    stage: parseValue<String>(json, "Stage"),
    proposedOfferAmount: parseValue<double>(json, "ProposedOfferAmount"),
    amount: parseValue<double>(json, "Amount"),
    unit: parseValue<String>(json, "Unit"),
    date: parseValue<DateTime>(json, "Date"),
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
    "TenantApplicantChargesId": tenantApplicantChargesId,
    "TenantId": tenantId,
    "TenantApplicantId": tenantApplicantId,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "ApplicantType": applicantType,
    "ApplicantName": applicantName,
    "FlatNumber": flatNumber,
    "FlatCarpetAreaSqFt": flatCarpetAreaSqFt,
    "FlatType": flatType,
    "FlatConfiguration": flatConfiguration,
    "Tenure": tenure,
    "Stage": stage,
    "ProposedOfferAmount": proposedOfferAmount,
    "Amount": amount,
    "Unit": unit,
    "Date": date.toIso8601String(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
