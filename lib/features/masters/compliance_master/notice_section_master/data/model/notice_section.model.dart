import 'package:k3h_erp_app/utils/functions/common_function.dart';

class NoticeSectionModel {
  int noticeSectionMasterId;
  String uniquekey;
  String governmentCompliance;
  String noticeSection;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  NoticeSectionModel({
    required this.noticeSectionMasterId,
    required this.uniquekey,
    required this.governmentCompliance,
    required this.noticeSection,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory NoticeSectionModel.fromJson(Map<String, dynamic> json) =>
      NoticeSectionModel(
        noticeSectionMasterId: parseValue<int>(json, "NoticeSectionMasterId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        governmentCompliance: parseValue<String>(json, "GovernmentCompliance"),
        noticeSection: parseValue<String>(json, "NoticeSection"),
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
    "NoticeSectionMasterId": noticeSectionMasterId,
    "Uniquekey": uniquekey,
    "GovernmentCompliance": governmentCompliance,
    "NoticeSection": noticeSection,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
