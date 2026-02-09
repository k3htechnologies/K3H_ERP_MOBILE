import 'package:k3h_erp_app/utils/common_function.dart';

class LitigationClosureModel {
  int litigationClosureId;
  String uniquekey;
  DateTime closureDate;
  String closureAttachementUrl;
  String remark;
  String conclusion;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  LitigationClosureModel({
    required this.litigationClosureId,
    required this.uniquekey,
    required this.closureDate,
    required this.closureAttachementUrl,
    required this.remark,
    required this.conclusion,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory LitigationClosureModel.fromJson(Map<String, dynamic> json) =>
      LitigationClosureModel(
        litigationClosureId: parseValue<int>(json, "LitigationClosureId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        closureDate: parseValue<DateTime>(json, "ClosureDate"),
        closureAttachementUrl: parseValue<String>(
          json,
          "ClosureAttachementURL",
        ),
        remark: parseValue<String>(json, "Remark"),
        conclusion: parseValue<String>(json, "Conclusion"),
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
    "LitigationClosureId": litigationClosureId,
    "Uniquekey": uniquekey,
    "ClosureDate": closureDate.toIso8601String(),
    "ClosureAttachementURL": closureAttachementUrl,
    "Remark": remark,
    "Conclusion": conclusion,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };

  LitigationClosureModel copyWith({
    int? litigationClosureId,
    String? uniquekey,
    DateTime? closureDate,
    String? closureAttachementUrl,
    String? remark,
    String? conclusion,
    int? createdById,
    String? createdBy,
    DateTime? createdDate,
    int? modifiedById,
    String? modifiedBy,
    DateTime? modifiedDate,
  }) {
    return LitigationClosureModel(
      litigationClosureId: litigationClosureId ?? this.litigationClosureId,
      uniquekey: uniquekey ?? this.uniquekey,
      closureDate: closureDate ?? this.closureDate,
      closureAttachementUrl:
          closureAttachementUrl ?? this.closureAttachementUrl,
      remark: remark ?? this.remark,
      conclusion: conclusion ?? this.conclusion,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      modifiedById: modifiedById ?? this.modifiedById,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }
}
