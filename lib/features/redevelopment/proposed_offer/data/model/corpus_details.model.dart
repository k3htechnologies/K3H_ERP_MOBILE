import 'package:k3h_erp_app/utils/common_function.dart';

class ProposedOfferCorpusDetailsWithPaymentStageData {
  int proposedOfferCorpusDetailsWithPaymentStageId;
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

  ProposedOfferCorpusDetailsWithPaymentStageData({
    required this.proposedOfferCorpusDetailsWithPaymentStageId,
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

  factory ProposedOfferCorpusDetailsWithPaymentStageData.fromJson(
    Map<String, dynamic> json,
  ) => ProposedOfferCorpusDetailsWithPaymentStageData(
    proposedOfferCorpusDetailsWithPaymentStageId: parseValue<int>(
      json,
      "ProposedOfferCorpusDetailsWithPaymentStageId",
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
            : parseValue<DateTime>(json, "ModifiedDate"),
  );

  Map<String, dynamic> toJson() => {
    "ProposedOfferCorpusDetailsWithPaymentStageId":
        proposedOfferCorpusDetailsWithPaymentStageId,
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

class CorpusDetailsModel {
  int proposedOfferCorpusDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  double corpusOfferedToResidentialAmount;
  double corpusOfferedToCommercialAmount;
  List<ProposedOfferCorpusDetailsWithPaymentStageData>
  proposedOfferCorpusDetailsWithPaymentStageData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  CorpusDetailsModel({
    required this.proposedOfferCorpusDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.corpusOfferedToResidentialAmount,
    required this.corpusOfferedToCommercialAmount,
    required this.proposedOfferCorpusDetailsWithPaymentStageData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory CorpusDetailsModel.fromJson(Map<String, dynamic> json) =>
      CorpusDetailsModel(
        proposedOfferCorpusDetailsId: parseValue<int>(
          json,
          "ProposedOfferCorpusDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        corpusOfferedToResidentialAmount: parseValue<double>(
          json,
          "CorpusOfferedToResidentialAmount",
        ),
        corpusOfferedToCommercialAmount: parseValue<double>(
          json,
          "CorpusOfferedToCommercialAmount",
        ),
        proposedOfferCorpusDetailsWithPaymentStageData:
            (json["ProposedOfferCorpusDetailsWithPaymentStageData"]
                    as List<dynamic>?)
                ?.map(
                  (item) =>
                      ProposedOfferCorpusDetailsWithPaymentStageData.fromJson(
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
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "ProposedOfferCorpusDetailsId": proposedOfferCorpusDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "CorpusOfferedToResidentialAmount": corpusOfferedToResidentialAmount,
    "CorpusOfferedToCommercialAmount": corpusOfferedToCommercialAmount,
    "ProposedOfferCorpusDetailsWithPaymentStageData":
        proposedOfferCorpusDetailsWithPaymentStageData
            .map((item) => item.toJson())
            .toList(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
