import 'package:k3h_erp_app/utils/functions/common_function.dart';

class EnquiryFollowUpModel {
  EnquiryFollowUpModel({
    required this.enquiryFollowUpId,
    required this.uniquekey,
    required this.enquiryId,
    required this.status,
    required this.lostReason,
    required this.nextFollowUpDate,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  int enquiryFollowUpId;
  String uniquekey;
  int enquiryId;
  String status;
  String lostReason;
  DateTime? nextFollowUpDate;
  String remark;

  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  factory EnquiryFollowUpModel.fromJson(Map<String, dynamic> json) {
    return EnquiryFollowUpModel(
      enquiryFollowUpId: parseValue<int>(json, "EnquiryFollowUpId"),
      uniquekey: parseValue<String>(json, "Uniquekey"),
      enquiryId: parseValue<int>(json, "EnquiryId"),
      status: parseValue<String>(json, "Status"),
      lostReason: parseValue<String>(json, "LostReason"),
      nextFollowUpDate: parseValue<DateTime>(json, "NextFollowUpDate"),
      remark: parseValue<String>(json, "Remark"),
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate: parseValue<DateTime>(json, "CreatedDate"),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate:
          json["ModifiedDate"] != null
              ? DateTime.parse(json["ModifiedDate"])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "EnquiryFollowUpId": enquiryFollowUpId,
    "Uniquekey": uniquekey,
    "EnquiryId": enquiryId,
    "Status": status,
    "LostReason": lostReason,
    "NextFollowUpDate": nextFollowUpDate?.toIso8601String(),
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
