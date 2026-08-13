import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BankGuaranteeDetailsModel {
  int proposedOfferBankGuaranteeDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  double bankGuaranteeAmount;
  String accountHolderName;
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
    required this.bankGuaranteeAmount,
    required this.accountHolderName,
    required this.remark,
    required this.proposedOfferBankGuaranteeDetailsWithPaymentStageData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BankGuaranteeDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) => BankGuaranteeDetailsModel(
    proposedOfferBankGuaranteeDetailsId: parseValue<int>(
      json,
      "ProposedOfferBankGuaranteeDetailsId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    buildingId: parseValue<int>(json, "BuildingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    bankGuaranteeAmount: parseValue<double>(json, "BankGuaranteeAmount"),
    accountHolderName: parseValue<String>(json, "AccountHolderName"),
    remark: parseValue<String>(json, "Remark"),
    proposedOfferBankGuaranteeDetailsWithPaymentStageData:
        (json["ProposedOfferBankGuaranteeDetailsWithPaymentStageData"]
                as List<dynamic>?)
            ?.map(
              (item) =>
                  ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
            )
            .toList() ??
        [],
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
    "BankGuaranteeAmount": bankGuaranteeAmount,
    "AccountHolderName": accountHolderName,
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
  String stage;
  double amount;
  bool isRelease;
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
    required this.stage,
    required this.amount,
    required this.isRelease,
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
    stage: parseValue<String>(json, "Stage"),
    amount: parseValue<double>(json, "Amount"),
    isRelease: parseValue<bool>(json, "IsRelease"),
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
    "Stage": stage,
    "Amount": amount,
    "IsRelease": isRelease,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
  Map<String, dynamic> bankGuaranteePaymentStageJSONPayload() => {
    "ProposedOfferBankGuaranteeDetailsWithPaymentStageId":
        proposedOfferBankGuaranteeDetailsWithPaymentStageId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "Stage": stage,
    "Amount": amount,
    "IsRelease": isRelease,
  };
}
