import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BankGuaranteeDetailsModel {
  int proposedOfferBankGuaranteeDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  double bankGuaranteeOfferedToResidentialAmount;
  double bankGuaranteeOfferedToCommercialAmount;
  String remark;
  List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>
  proposedOfferBankGuaranteeDetailsWithPaymentStageData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BankGuaranteeDetailsModel({
    required this.proposedOfferBankGuaranteeDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.bankGuaranteeOfferedToResidentialAmount,
    required this.bankGuaranteeOfferedToCommercialAmount,
    required this.remark,
    required this.proposedOfferBankGuaranteeDetailsWithPaymentStageData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BankGuaranteeDetailsModel.fromJson(Map<String, dynamic> json) =>
      BankGuaranteeDetailsModel(
        proposedOfferBankGuaranteeDetailsId: parseValue<int>(
          json,
          "ProposedOfferBankGuaranteeDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        bankGuaranteeOfferedToResidentialAmount: parseValue<double>(
          json,
          "BankGuaranteeOfferedToResidentialAmount",
        ),
        bankGuaranteeOfferedToCommercialAmount: parseValue<double>(
          json,
          "BankGuaranteeOfferedToCommercialAmount",
        ),
        remark: parseValue<String>(json, "Remark"),
        proposedOfferBankGuaranteeDetailsWithPaymentStageData: parseValue<
          List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>
        >(json, "ProposedOfferBankGuaranteeDetailsWithPaymentStageData"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : DateTime.parse(json["ModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
    "ProposedOfferBankGuaranteeDetailsId": proposedOfferBankGuaranteeDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "BankGuaranteeOfferedToResidentialAmount":
        bankGuaranteeOfferedToResidentialAmount,
    "BankGuaranteeOfferedToCommercialAmount":
        bankGuaranteeOfferedToCommercialAmount,
    "Remark": remark,
    "ProposedOfferBankGuaranteeDetailsWithPaymentStageData":
        proposedOfferBankGuaranteeDetailsWithPaymentStageData,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel {
  int proposedOfferBankGuaranteeDetailsWithPaymentStageId;
  String uniquekey;
  int buildingId;
  int projectId;
  String type;
  String stage;
  double stagePercentage;
  double amount;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel({
    required this.proposedOfferBankGuaranteeDetailsWithPaymentStageId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.type,
    required this.stage,
    required this.stagePercentage,
    required this.amount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel.fromJson(
    Map<String, dynamic> json,
  ) => ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel(
    proposedOfferBankGuaranteeDetailsWithPaymentStageId: parseValue<int>(
      json,
      "ProposedOfferBankGuaranteeDetailsWithPaymentStageId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    buildingId: parseValue<int>(json, "BuildingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    type: parseValue<String>(json, "Type"),
    stage: parseValue<String>(json, "Stage"),
    stagePercentage: parseValue<double>(json, "StagePercentage"),
    amount: parseValue<double>(json, "Amount"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : DateTime.parse(json["ModifiedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "ProposedOfferBankGuaranteeDetailsWithPaymentStageId":
        proposedOfferBankGuaranteeDetailsWithPaymentStageId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "Type": type,
    "Stage": stage,
    "StagePercentage": stagePercentage,
    "Amount": amount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
