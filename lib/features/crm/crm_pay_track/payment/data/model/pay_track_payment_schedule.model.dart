import 'package:k3h_erp_app/utils/common_function.dart';

class PayTrackPaymentScheduleModel {
  String type;
  String name;
  DateTime? date;
  double paymentSchedulePercentage;
  double paymentScheduleAmount;
  double paymentScheduleReceivedAmount;
  double paymentScheduleGstAmount;
  double paymentScheduleReceivedGstAmount;
  double paymentScheduleTdsAmount;
  double paymentScheduleReceivedTdsAmount;

  PayTrackPaymentScheduleModel({
    required this.type,
    required this.name,
    this.date,
    required this.paymentSchedulePercentage,
    required this.paymentScheduleAmount,
    required this.paymentScheduleReceivedAmount,
    required this.paymentScheduleGstAmount,
    required this.paymentScheduleReceivedGstAmount,
    required this.paymentScheduleTdsAmount,
    required this.paymentScheduleReceivedTdsAmount,
  });

  factory PayTrackPaymentScheduleModel.fromJson(Map<String, dynamic> json) =>
      PayTrackPaymentScheduleModel(
        type: parseValue<String>(json, "Type"),
        name: parseValue<String>(json, "Name"),
        date: json["Date"] != null ? parseValue<DateTime>(json, "Date") : null,
        paymentSchedulePercentage: parseValue<double>(
          json,
          "PaymentSchedulePercentage",
        ),
        paymentScheduleAmount: parseValue<double>(
          json,
          "PaymentScheduleAmount",
        ),
        paymentScheduleReceivedAmount: parseValue<double>(
          json,
          "PaymentScheduleReceivedAmount",
        ),
        paymentScheduleGstAmount: parseValue<double>(
          json,
          "PaymentScheduleGSTAmount",
        ),
        paymentScheduleReceivedGstAmount: parseValue<double>(
          json,
          "PaymentScheduleReceivedGSTAmount",
        ),
        paymentScheduleTdsAmount: parseValue<double>(
          json,
          "PaymentScheduleTDSAmount",
        ),
        paymentScheduleReceivedTdsAmount: parseValue<double>(
          json,
          "PaymentScheduleReceivedTDSAmount",
        ),
      );

  Map<String, dynamic> toJson() => {
    "Type": type,
    "Name": name,
    "Date": date?.toIso8601String(),
    "PaymentSchedulePercentage": paymentSchedulePercentage,
    "PaymentScheduleAmount": paymentScheduleAmount,
    "PaymentScheduleReceivedAmount": paymentScheduleReceivedAmount,
    "PaymentScheduleGSTAmount": paymentScheduleGstAmount,
    "PaymentScheduleReceivedGSTAmount": paymentScheduleReceivedGstAmount,
    "PaymentScheduleTDSAmount": paymentScheduleTdsAmount,
    "PaymentScheduleReceivedTDSAmount": paymentScheduleReceivedTdsAmount,
  };
}
