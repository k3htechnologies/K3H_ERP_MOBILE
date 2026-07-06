import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BuildingKeyContactDetailsModel {
  int buildingKeyContactDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  String contactType;
  String contactName;
  String mobileNumber;
  String emailId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BuildingKeyContactDetailsModel({
    required this.buildingKeyContactDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.contactType,
    required this.contactName,
    required this.mobileNumber,
    required this.emailId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BuildingKeyContactDetailsModel.fromJson(Map<String, dynamic> json) =>
      BuildingKeyContactDetailsModel(
        buildingKeyContactDetailsId: parseValue<int>(
          json,
          "BuildingKeyContactDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        contactType: parseValue<String>(json, "ContactType"),
        contactName: parseValue<String>(json, "ContactName"),
        mobileNumber: parseValue<String>(json, "MobileNumber"),
        emailId: parseValue<String>(json, "EmailId"),
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
    "BuildingKeyContactDetailsId": buildingKeyContactDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "ContactType": contactType,
    "ContactName": contactName,
    "MobileNumber": mobileNumber,
    "EmailId": emailId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}