import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProposedOfferHardshipDetailsWithPaymentStageData {
  int proposedOfferHardshipDetailsWithPaymentStageId;
  String uniquekey;
  int buildingId;
  int projectId;
  String type;
  String stage;
  double stagePercentage;
  double amount;
  String unitSqFtLumsum;
  double carpetAreaSqFt;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ProposedOfferHardshipDetailsWithPaymentStageData({
    required this.proposedOfferHardshipDetailsWithPaymentStageId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.type,
    required this.stage,
    required this.stagePercentage,
    required this.amount,
    required this.unitSqFtLumsum,
    required this.carpetAreaSqFt,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ProposedOfferHardshipDetailsWithPaymentStageData.fromJson(
    Map<String, dynamic> json,
  ) => ProposedOfferHardshipDetailsWithPaymentStageData(
    proposedOfferHardshipDetailsWithPaymentStageId: parseValue<int>(
      json,
      "ProposedOfferHardshipDetailsWithPaymentStageId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    buildingId: parseValue<int>(json, "BuildingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    type: parseValue<String>(json, "Type"),
    stage: parseValue<String>(json, "Stage"),
    stagePercentage: parseValue<double>(json, "StagePercentage"),
    amount: parseValue<double>(json, "Amount"),
    unitSqFtLumsum: parseValue<String>(json, "UnitSqFtLumsum"),
    carpetAreaSqFt: parseValue<double>(json, "CarpetAreaSqFt"),
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
    "ProposedOfferHardshipDetailsWithPaymentStageId":
        proposedOfferHardshipDetailsWithPaymentStageId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "Type": type,
    "Stage": stage,
    "StagePercentage": stagePercentage,
    "Amount": amount,
    "UnitSqFtLumsum": unitSqFtLumsum,
    "CarpetAreaSqFt": carpetAreaSqFt,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class HardshipOfferDetailsModel {
  int proposedOfferHardshipDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  double corpusOfferedToResidentialAmount;
  double corpusOfferedToCommercialAmount;
  List<ProposedOfferHardshipDetailsWithPaymentStageData>
  proposedOfferHardshipDetailsWithPaymentStageData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  String remark;

  HardshipOfferDetailsModel({
    required this.proposedOfferHardshipDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.corpusOfferedToResidentialAmount,
    required this.corpusOfferedToCommercialAmount,
    required this.proposedOfferHardshipDetailsWithPaymentStageData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.remark,
  });

  factory HardshipOfferDetailsModel.fromJson(Map<String, dynamic> json) =>
      HardshipOfferDetailsModel(
        proposedOfferHardshipDetailsId: parseValue<int>(
          json,
          "ProposedOfferHardshipDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        corpusOfferedToResidentialAmount: parseValue<double>(
          json,
          "HardshipOfferedToResidentialAmount",
        ),
        corpusOfferedToCommercialAmount: parseValue<double>(
          json,
          "HardshipOfferedToCommercialAmount",
        ),
        proposedOfferHardshipDetailsWithPaymentStageData:
            (json["ProposedOfferHardshipDetailsWithPaymentStageData"]
                    as List<dynamic>?)
                ?.map(
                  (item) =>
                      ProposedOfferHardshipDetailsWithPaymentStageData.fromJson(
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
        remark: parseValue<String>(json, "Remark"),
      );

  Map<String, dynamic> toJson() => {
    "ProposedOfferHardshipDetailsId": proposedOfferHardshipDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "HardshipOfferedToResidentialAmount": corpusOfferedToResidentialAmount,
    "HardshipOfferedToCommercialAmount": corpusOfferedToCommercialAmount,
    "ProposedOfferHardshipDetailsWithPaymentStageData":
        proposedOfferHardshipDetailsWithPaymentStageData
            .map((item) => item.toJson())
            .toList(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "Remark": remark,
  };
}
