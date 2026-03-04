import 'package:k3h_erp_app/utils/common_function.dart';

class PaymentScheduleMasterModel {
  int paymentScheduleMasterId;
  String uniquekey;
  String name;
  double paymentSchedulePercentage;
  double paymentScheduleCummulativePercentage;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  int ranking;

  PaymentScheduleMasterModel({
    required this.paymentScheduleMasterId,
    required this.uniquekey,
    required this.name,
    required this.paymentSchedulePercentage,
    required this.paymentScheduleCummulativePercentage,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,

    this.ranking = 0,
  });

  factory PaymentScheduleMasterModel.fromJson(Map<String, dynamic> json) =>
      PaymentScheduleMasterModel(
        paymentScheduleMasterId: parseValue<int>(
          json,
          "PaymentScheduleMasterId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        name: parseValue<String>(json, "Name"),
        paymentSchedulePercentage: parseValue<double>(
          json,
          "PaymentSchedulePercentage",
        ),
        paymentScheduleCummulativePercentage: parseValue<double>(
          json,
          "PaymentScheduleCummulativePercentage",
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
      );

  Map<String, dynamic> toJson() => {
    "PaymentScheduleMasterId": paymentScheduleMasterId,
    "Uniquekey": uniquekey,
    "Name": name,
    "PaymentSchedulePercentage": paymentSchedulePercentage,
    "PaymentScheduleCummulativePercentage":
        paymentScheduleCummulativePercentage,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,

    "Ranking": ranking,
  };
}
