import 'package:k3h_erp_app/utils/common_function.dart';

class PaymentScheduleSchemeModel {
  int paymentScheduleSchemeId;
  String uniquekey;
  int projectId;
  String paymentScheduleSchemeName;
  int orderBy;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  PaymentScheduleSchemeModel({
    required this.paymentScheduleSchemeId,
    required this.uniquekey,
    required this.projectId,
    required this.paymentScheduleSchemeName,
    required this.orderBy,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory PaymentScheduleSchemeModel.fromJson(Map<String, dynamic> json) =>
      PaymentScheduleSchemeModel(
        paymentScheduleSchemeId: parseValue<int>(
          json,
          "PaymentScheduleSchemeId",
        ),

        uniquekey: parseValue<String>(json, "Uniquekey"),

        projectId: parseValue<int>(json, "ProjectId"),

        paymentScheduleSchemeName: parseValue<String>(
          json,
          "PaymentScheduleSchemeName",
        ),

        orderBy: parseValue<int>(json, "OrderBy"),

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
    "PaymentScheduleSchemeId": paymentScheduleSchemeId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "PaymentScheduleSchemeName": paymentScheduleSchemeName,
    "OrderBy": orderBy,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
