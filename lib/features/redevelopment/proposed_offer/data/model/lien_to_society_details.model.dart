import 'package:k3h_erp_app/utils/common_function.dart';

class ProposedOfferLienToSocietyDetailsWithPaymentStageData {
  int proposedOfferLienToSocietyDetailsWithPaymentStageId;
  String uniquekey;
  int buildingId;
  int projectId;
  String type;
  String stage;
  double carpetAreaSqFt;
  bool isRelease;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ProposedOfferLienToSocietyDetailsWithPaymentStageData({
    required this.proposedOfferLienToSocietyDetailsWithPaymentStageId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.type,
    required this.stage,
    required this.carpetAreaSqFt,
    required this.isRelease,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });
  factory ProposedOfferLienToSocietyDetailsWithPaymentStageData.fromJson(Map<String, dynamic> json) =>
      ProposedOfferLienToSocietyDetailsWithPaymentStageData(
        proposedOfferLienToSocietyDetailsWithPaymentStageId: parseValue<int>(
          json,
          "ProposedOfferLienToSocietyDetailsWithPaymentStageId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        type: parseValue<String>(json, "Type"),
        stage: parseValue<String>(json, "Stage"),
        carpetAreaSqFt: parseValue<double>(json, "CarpetAreaSqFt"),
        isRelease: parseValue<bool>(json, "IsRelease"),
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
    "ProposedOfferLienToSocietyDetailsWithPaymentStageId": proposedOfferLienToSocietyDetailsWithPaymentStageId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "Type": type,
    "Stage": stage,
    "CarpetAreaSqFt": carpetAreaSqFt,
    "IsRelease": isRelease,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class LienToSocietyDetailsModel {
  int proposedOfferLienToSocietyDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  double residentialAreaSqFt;
  double commercialAreaSqFt;
  int numberOfResidentialLienUnits;
  int numberOfCommercialLienUnits;
  List<ProposedOfferLienToSocietyDetailsWithPaymentStageData> proposedOfferLienToSocietyDetailsWithPaymentStageData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  LienToSocietyDetailsModel({
    required this.proposedOfferLienToSocietyDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.residentialAreaSqFt,
    required this.commercialAreaSqFt,
    required this.numberOfResidentialLienUnits,
    required this.numberOfCommercialLienUnits,
    required this.proposedOfferLienToSocietyDetailsWithPaymentStageData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory LienToSocietyDetailsModel.fromJson(Map<String, dynamic> json) =>
      LienToSocietyDetailsModel(
        proposedOfferLienToSocietyDetailsId: parseValue<int>(
          json,
          "ProposedOfferLienToSocietyDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        residentialAreaSqFt: parseValue<double>(
          json,
          "ResidentialAreaSqFt",
        ),
        commercialAreaSqFt: parseValue<double>(
          json,
          "CommercialAreaSqFt",
        ),
        numberOfResidentialLienUnits: parseValue<int>(
          json,
          "NumberOfResidentialLienUnits",
        ),
        numberOfCommercialLienUnits: parseValue<int>(
          json,
          "NumberOfCommercialLienUnits",
        ),
        proposedOfferLienToSocietyDetailsWithPaymentStageData: (json["ProposedOfferSecurityDepositDetailsWithPaymentStageData"] as List<dynamic>?)
            ?.map((item) => ProposedOfferLienToSocietyDetailsWithPaymentStageData.fromJson(item as Map<String, dynamic>))
            .toList() ?? [],
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
    "ProposedOfferLienToSocietyDetailsId": proposedOfferLienToSocietyDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "ResidentialAreaSqFt": residentialAreaSqFt,
    "CommercialAreaSqFt": commercialAreaSqFt,
    "NumberOfResidentialLienUnits": numberOfResidentialLienUnits,
    "NumberOfCommercialLienUnits": numberOfCommercialLienUnits,
    "ProposedOfferSecurityDepositDetailsWithPaymentStageData": proposedOfferLienToSocietyDetailsWithPaymentStageData.map((item) => item.toJson()).toList(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}