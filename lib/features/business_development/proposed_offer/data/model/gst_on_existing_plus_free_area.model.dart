import 'package:k3h_erp_app/utils/functions/common_function.dart';

class GstOnExistingPlusFreeAreaModel {
  int proposedOfferGSTonExistingPlusFreeAreaId;
  String uniquekey;
  int buildingId;
  int projectId;
  double gstOnAreaByMemberPercent;
  double gstOnAreaByDeveloperPercent;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  String remark;

  GstOnExistingPlusFreeAreaModel({
    required this.proposedOfferGSTonExistingPlusFreeAreaId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.gstOnAreaByMemberPercent,
    required this.gstOnAreaByDeveloperPercent,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
    required this.remark,
  });

  factory GstOnExistingPlusFreeAreaModel.fromJson(Map<String, dynamic> json) =>
      GstOnExistingPlusFreeAreaModel(
        proposedOfferGSTonExistingPlusFreeAreaId: parseValue<int>(
          json,
          "ProposedOfferGSTonExistingPlusFreeAreaId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        gstOnAreaByMemberPercent: parseValue<double>(
          json,
          "GSTOnAreaByMemberPercent",
        ),
        gstOnAreaByDeveloperPercent: parseValue<double>(
          json,
          "GSTOnAreaByDeveloperPercent",
        ),
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
    "ProposedOfferGSTonExistingPlusFreeAreaId":
        proposedOfferGSTonExistingPlusFreeAreaId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "GSTOnAreaByMemberPercent": gstOnAreaByMemberPercent,
    "GSTOnAreaByDeveloperPercent": gstOnAreaByDeveloperPercent,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "Remark": remark,
  };
}
