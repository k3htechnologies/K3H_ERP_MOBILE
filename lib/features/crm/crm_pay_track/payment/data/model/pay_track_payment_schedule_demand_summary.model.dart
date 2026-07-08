import 'package:k3h_erp_app/utils/common_function.dart';

class PayTrackPaymentScheduleDemandSummaryModel {
  int payTrackPaymentScheduleDemandSummaryId;
  String uniquekey;
  String systemGeneratedCode;
  int bookingPaymentScheduleId;
  int bookingId;
  int projectId;
  String paymentScheduleDemandType;
  String paymentScheduleDemandSummaryUrl;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime modifiedDate;

  PayTrackPaymentScheduleDemandSummaryModel({
    required this.payTrackPaymentScheduleDemandSummaryId,
    required this.uniquekey,
    required this.systemGeneratedCode,
    required this.bookingPaymentScheduleId,
    required this.bookingId,
    required this.projectId,
    required this.paymentScheduleDemandType,
    required this.paymentScheduleDemandSummaryUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory PayTrackPaymentScheduleDemandSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) => PayTrackPaymentScheduleDemandSummaryModel(
    payTrackPaymentScheduleDemandSummaryId: parseValue<int>(
      json,
      "PayTrackPaymentScheduleDemandSummaryId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    bookingPaymentScheduleId: parseValue<int>(json, "BookingPaymentScheduleId"),
    bookingId: parseValue<int>(json, "BookingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    paymentScheduleDemandType: parseValue<String>(
      json,
      "PaymentScheduleDemandType",
    ),
    paymentScheduleDemandSummaryUrl: parseValue<String>(
      json,
      "PaymentScheduleDemandSummaryURL",
    ),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate:
        json["CreatedDate"] != null
            ? DateTime.parse(json["CreatedDate"])
            : DateTime.now(),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] != null
            ? DateTime.parse(json["ModifiedDate"])
            : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    "PayTrackPaymentScheduleDemandSummaryId":
        payTrackPaymentScheduleDemandSummaryId,
    "Uniquekey": uniquekey,
    "SystemGeneratedCode": systemGeneratedCode,
    "BookingPaymentScheduleId": bookingPaymentScheduleId,
    "BookingId": bookingId,
    "ProjectId": projectId,
    "PaymentScheduleDemandType": paymentScheduleDemandType,
    "PaymentScheduleDemandSummaryURL": paymentScheduleDemandSummaryUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate.toIso8601String(),
  };
}
