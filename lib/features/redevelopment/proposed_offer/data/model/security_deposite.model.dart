import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProposedOfferSecurityDepositDetailsWithPaymentStageData {
  int proposedOfferSecurityDepositDetailsWithPaymentStageId;
  String uniquekey;
  int buildingId;
  int projectId;
  String type;
  String stage;
  double amount;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ProposedOfferSecurityDepositDetailsWithPaymentStageData({
    required this.proposedOfferSecurityDepositDetailsWithPaymentStageId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.type,
    required this.stage,
    required this.amount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ProposedOfferSecurityDepositDetailsWithPaymentStageData.fromJson(Map<String, dynamic> json) =>
      ProposedOfferSecurityDepositDetailsWithPaymentStageData(
        proposedOfferSecurityDepositDetailsWithPaymentStageId: parseValue<int>(
          json,
          "ProposedOfferSecurityDepositDetailsWithPaymentStageId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        type: parseValue<String>(json, "Type"),
        stage: parseValue<String>(json, "Stage"),
        amount: parseValue<double>(json, "Amount"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate: json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "ProposedOfferSecurityDepositDetailsWithPaymentStageId": proposedOfferSecurityDepositDetailsWithPaymentStageId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "Type": type,
    "Stage": stage,
    "Amount": amount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}


class SecurityDepositModel {
  int proposedOfferSecurityDepositDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  double securityDepositToSocietyAmount;
  List<ProposedOfferSecurityDepositDetailsWithPaymentStageData> proposedOfferSecurityDepositDetailsWithPaymentStageData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  SecurityDepositModel({
    required this.proposedOfferSecurityDepositDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.securityDepositToSocietyAmount,
    required this.proposedOfferSecurityDepositDetailsWithPaymentStageData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory SecurityDepositModel.fromJson(Map<String, dynamic> json) =>
      SecurityDepositModel(
        proposedOfferSecurityDepositDetailsId: parseValue<int>(
          json,
          "ProposedOfferSecurityDepositDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        securityDepositToSocietyAmount: parseValue<double>(json, "SecurityDepositToSocietyAmount"),
        proposedOfferSecurityDepositDetailsWithPaymentStageData: (json["ProposedOfferSecurityDepositDetailsWithPaymentStageData"] as List<dynamic>)
            .map((item) => ProposedOfferSecurityDepositDetailsWithPaymentStageData.fromJson(item as Map<String, dynamic>))
            .toList(),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate: json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "ProposedOfferSecurityDepositDetailsId": proposedOfferSecurityDepositDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "SecurityDepositToSocietyAmount": securityDepositToSocietyAmount,
    "ProposedOfferSecurityDepositDetailsWithPaymentStageData": proposedOfferSecurityDepositDetailsWithPaymentStageData.map((item) => item.toJson()).toList(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}