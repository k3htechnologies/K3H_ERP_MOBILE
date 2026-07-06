import 'package:k3h_erp_app/utils/functions/common_function.dart';

class FlatAlterationRequestsModel {
  int flatAlterationRequestId;
  String uniqueKey;
  int bookingId;
  int projectId;
  String flatAlterationRemark;
  bool isApproval;
  String approvalStatus;
  String versionNumber;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  FlatAlterationRequestsModel({
    required this.flatAlterationRequestId,
    required this.uniqueKey,
    required this.bookingId,
    required this.projectId,
    required this.flatAlterationRemark,
    required this.isApproval,
    required this.approvalStatus,
    required this.versionNumber,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory FlatAlterationRequestsModel.fromJson(Map<String, dynamic> json) =>
      FlatAlterationRequestsModel(
        flatAlterationRequestId: parseValue<int>(
          json,
          "FlatAlterationRequestId",
        ),
        uniqueKey: parseValue<String>(json, "UniqueKey"),
        bookingId: parseValue<int>(json, "BookingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        flatAlterationRemark: parseValue<String>(json, "FlatAlterationRemark"),
        isApproval: parseValue<bool>(json, "IsApproval"),
        approvalStatus: parseValue<String>(json, "ApprovalStatus"),
        versionNumber: parseValue<String>(json, "VersionNumber"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate:
            json["CreatedDate"] == null
                ? null
                : parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "FlatAlterationRequestId": flatAlterationRequestId,
    "UniqueKey": uniqueKey,
    "BookingId": bookingId,
    "ProjectId": projectId,
    "FlatAlterationRemark": flatAlterationRemark,
    "IsApproval": isApproval,
    "ApprovalStatus": approvalStatus,
    "VersionNumber": versionNumber,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
