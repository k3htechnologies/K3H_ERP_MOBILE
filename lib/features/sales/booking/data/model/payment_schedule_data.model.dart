import 'package:k3h_erp_app/utils/common_function.dart';

class BookingPaymentScheduleData {
  int bookingPaymentScheduleId;
  String type;
  String name;
  DateTime? date;
  double paymentSchedulePercentage;
  double paymentCummulativePercentage;
  double paymentScheduleAmount;
  double paymentScheduleGSTAmount;
  double paymentScheduleTDSAmount;
  int ranking;
  BookingPaymentScheduleData({
    required this.bookingPaymentScheduleId,
    required this.type,
    required this.name,
    this.date,
    required this.paymentSchedulePercentage,
    required this.paymentCummulativePercentage,
    required this.paymentScheduleAmount,
    required this.paymentScheduleGSTAmount,
    required this.paymentScheduleTDSAmount,
    required this.ranking,
  });

  factory BookingPaymentScheduleData.fromJson(
    Map<String, dynamic> json,
  ) => BookingPaymentScheduleData(
    bookingPaymentScheduleId: parseValue<int>(json, "BookingPaymentScheduleId"),
    type: parseValue<String>(json, "Type"),
    name: parseValue<String>(json, "Name"),
    date: json["Date"] == null ? null : parseValue<DateTime>(json, "Date"),
    paymentSchedulePercentage: parseValue<double>(
      json,
      "PaymentSchedulePercentage",
    ),
    paymentCummulativePercentage: parseValue<double>(
      json,
      "PaymentScheduleCumulative",
    ),
    paymentScheduleAmount: parseValue<double>(json, "PaymentScheduleAmount"),
    paymentScheduleGSTAmount: parseValue<double>(
      json,
      "PaymentScheduleGSTAmount",
    ),
    paymentScheduleTDSAmount: parseValue<double>(
      json,
      "PaymentScheduleTDSAmount",
    ),
    ranking: parseValue<int>(json, "Rank"),
  );

  Map<String, dynamic> toJson() => {
    "BookingPaymentScheduleId": bookingPaymentScheduleId,
    "Type": type,
    "Name": name,
    "Date": date?.toIso8601String(),
    "PaymentSchedulePercentage": paymentSchedulePercentage,
    "PaymentScheduleCumulative": paymentCummulativePercentage,
    "PaymentScheduleAmount": paymentScheduleAmount,
    "PaymentScheduleGSTAmount": paymentScheduleGSTAmount,
    "PaymentScheduleTDSAmount": paymentScheduleTDSAmount,
    "Rank": ranking,
  };
  BookingPaymentScheduleData copyWith({
    int? bookingPaymentScheduleId,
    String? type,
    String? name,
    DateTime? date,
    double? paymentSchedulePercentage,
    double? paymentCummulativePercentage,
    double? paymentScheduleAmount,
    double? paymentScheduleGSTAmount,
    double? paymentScheduleTDSAmount,
    int? ranking,
  }) {
    return BookingPaymentScheduleData(
      bookingPaymentScheduleId:
          bookingPaymentScheduleId ?? this.bookingPaymentScheduleId,
      type: type ?? this.type,
      name: name ?? this.name,
      date: date ?? this.date,
      paymentSchedulePercentage:
          paymentSchedulePercentage ?? this.paymentSchedulePercentage,
      paymentCummulativePercentage:
          paymentCummulativePercentage ?? this.paymentCummulativePercentage,
      paymentScheduleAmount:
          paymentScheduleAmount ?? this.paymentScheduleAmount,
      paymentScheduleGSTAmount:
          paymentScheduleGSTAmount ?? this.paymentScheduleGSTAmount,
      paymentScheduleTDSAmount:
          paymentScheduleTDSAmount ?? this.paymentScheduleTDSAmount,
      ranking: ranking ?? this.ranking,
    );
  }
}
