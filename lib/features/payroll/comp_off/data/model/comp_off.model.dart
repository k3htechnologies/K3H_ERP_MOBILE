import 'package:k3h_erp_app/utils/common_function.dart';

class CompOffModel {
  int compOffId;
  String uniquekey;
  DateTime compOffDate;
  DateTime workingDate;
  String status;
  String reason;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  CompOffModel({
    required this.compOffId,
    required this.uniquekey,
    required this.compOffDate,
    required this.workingDate,
    required this.reason,
    required this.status,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory CompOffModel.fromJson(Map<String, dynamic> json) => CompOffModel(
    compOffId: parseValue<int>(json, "CompOffId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    compOffDate: parseValue<DateTime>(json, "CompOffDate"),
    workingDate: parseValue<DateTime>(json, "WorkingDate"),
    status: parseValue<String>(json, "Status"),
    reason: parseValue<String>(json, "Reason"),
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
    "CompOffId": compOffId,
    "Uniquekey": uniquekey,
    "CompOffDate": compOffDate.toIso8601String(),
    "WorkingDate": workingDate.toIso8601String(),
    "Status": status,
    "Reason": reason,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
