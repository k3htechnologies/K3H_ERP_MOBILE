import 'package:k3h_erp_app/utils/functions/common_function.dart';

class AdditionalInformationDetailsModel {
  int proposedOfferAdditionalInformationId;
  String uniquekey;
  int buildingId;
  int projectId;
  String taxAndDutiesDetails;
  String taxRemark;
  String purchaseOfAdditonalAreaRemark;
  String additionalRemark;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  AdditionalInformationDetailsModel({
    required this.proposedOfferAdditionalInformationId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.taxAndDutiesDetails,
    required this.taxRemark,
    required this.purchaseOfAdditonalAreaRemark,
    required this.additionalRemark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory AdditionalInformationDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) => AdditionalInformationDetailsModel(
    proposedOfferAdditionalInformationId: parseValue<int>(
      json,
      "ProposedOfferAdditionalInformationId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    buildingId: parseValue<int>(json, "BuildingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    taxAndDutiesDetails: parseValue<String>(json, "TaxAndDutiesDetails"),
    taxRemark: parseValue<String>(json, "TaxRemark"),
    purchaseOfAdditonalAreaRemark: parseValue<String>(
      json,
      "PurchaseOfAdditonalAreaRemark",
    ),
    additionalRemark: parseValue<String>(json, "AdditionalRemark"),
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
    "ProposedOfferAdditionalInformationId":
        proposedOfferAdditionalInformationId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "TaxAndDutiesDetails": taxAndDutiesDetails,
    "TaxRemark": taxRemark,
    "PurchaseOfAdditonalAreaRemark": purchaseOfAdditonalAreaRemark,
    "AdditionalRemark": additionalRemark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
