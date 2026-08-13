import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProposedOfferShiftingDetailsWithPaymentStageData {
  int proposedOfferShiftingDetailsWithPaymentStageId;
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

  ProposedOfferShiftingDetailsWithPaymentStageData({
    required this.proposedOfferShiftingDetailsWithPaymentStageId,
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

  factory ProposedOfferShiftingDetailsWithPaymentStageData.fromJson(
    Map<String, dynamic> json,
  ) => ProposedOfferShiftingDetailsWithPaymentStageData(
    proposedOfferShiftingDetailsWithPaymentStageId: parseValue<int>(
      json,
      "ProposedOfferShiftingDetailsWithPaymentStageId",
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
    "ProposedOfferShiftingDetailsWithPaymentStageId":
        proposedOfferShiftingDetailsWithPaymentStageId,
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

class ShiftingDetailsModel {
  int proposedOfferShiftingDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  double shiftingOfferedToResidentialAmount;
  double shiftingOfferedToCommercialAmount;
  List<ProposedOfferShiftingDetailsWithPaymentStageData>
  proposedOfferShiftingDetailsWithPaymentStageData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  String remark;

  ShiftingDetailsModel({
    required this.proposedOfferShiftingDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.shiftingOfferedToResidentialAmount,
    required this.shiftingOfferedToCommercialAmount,
    required this.proposedOfferShiftingDetailsWithPaymentStageData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.remark,
  });

  factory ShiftingDetailsModel.fromJson(Map<String, dynamic> json) =>
      ShiftingDetailsModel(
        proposedOfferShiftingDetailsId: parseValue<int>(
          json,
          "ProposedOfferShiftingDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        shiftingOfferedToResidentialAmount: parseValue<double>(
          json,
          "ShiftingOfferedToResidentialAmount",
        ),
        shiftingOfferedToCommercialAmount: parseValue<double>(
          json,
          "ShiftingOfferedToCommercialAmount",
        ),
        proposedOfferShiftingDetailsWithPaymentStageData:
            (json["ProposedOfferShiftingDetailsWithPaymentStageData"]
                    as List<dynamic>?)
                ?.map(
                  (item) =>
                      ProposedOfferShiftingDetailsWithPaymentStageData.fromJson(
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
    "ProposedOfferShiftingDetailsId": proposedOfferShiftingDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "ShiftingOfferedToResidentialAmount": shiftingOfferedToResidentialAmount,
    "ShiftingOfferedToCommercialAmount": shiftingOfferedToCommercialAmount,
    "ProposedOfferShiftingDetailsWithPaymentStageData":
        proposedOfferShiftingDetailsWithPaymentStageData
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
