import 'package:k3h_erp_app/utils/functions/common_function.dart';

class LitigationHearingModel {
  int litigationHearingId;
  String uniquekey;
  DateTime hearingDate;
  String hearingAttachementUrl;
  String remark;
  String fileName;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  LitigationHearingModel({
    required this.litigationHearingId,
    required this.uniquekey,
    required this.hearingDate,
    required this.hearingAttachementUrl,
    required this.fileName,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory LitigationHearingModel.fromJson(Map<String, dynamic> json) {
    return LitigationHearingModel(
      litigationHearingId: parseValue<int>(json, "LitigationHearingId"),
      uniquekey: parseValue<String>(json, "Uniquekey"),
      fileName: parseValue<String>(json, "FileName"),
      hearingDate: parseValue<DateTime>(json, "HearingDate"),
      hearingAttachementUrl: parseValue<String>(json, "HearingAttachementURL"),
      remark: parseValue<String>(json, "Remark"),
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
  }

  Map<String, dynamic> toJson() => {
    "LitigationHearingId": litigationHearingId,
    "Uniquekey": uniquekey,
    "HearingDate": hearingDate.toIso8601String(),
    "HearingAttachementURL": hearingAttachementUrl,
    "Remark": remark,
    "FileName": fileName,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
