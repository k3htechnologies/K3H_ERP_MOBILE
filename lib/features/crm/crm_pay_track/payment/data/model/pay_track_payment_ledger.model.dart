import 'package:k3h_erp_app/utils/common_function.dart';

class PayTrackPaymentLedgerModel {
  int bookingId;
  int projectId;
  String paymentFor;
  double totalAmount;
  double receivedAmount;
  int uploadedPaymentLedgerCount;
  int approvalPendingPaymentLedgerCount;

  PayTrackPaymentLedgerModel({
    required this.bookingId,
    required this.projectId,
    required this.paymentFor,
    required this.totalAmount,
    required this.receivedAmount,
    required this.uploadedPaymentLedgerCount,
    required this.approvalPendingPaymentLedgerCount,
  });

  factory PayTrackPaymentLedgerModel.fromJson(Map<String, dynamic> json) =>
      PayTrackPaymentLedgerModel(
        bookingId: parseValue<int>(json, "BookingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        paymentFor: parseValue<String>(json, "PaymentFor"),
        totalAmount: parseValue<double>(json, "TotalAmount"),
        receivedAmount: parseValue<double>(json, "ReceivedAmount"),
        uploadedPaymentLedgerCount: parseValue<int>(
          json,
          "UploadedPaymentLedgerCount",
        ),
        approvalPendingPaymentLedgerCount: parseValue<int>(
          json,
          "ApprovalPendingPaymentLedgerCount",
        ),
      );

  Map<String, dynamic> toJson() => {
    "BookingId": bookingId,
    "ProjectId": projectId,
    "PaymentFor": paymentFor,
    "TotalAmount": totalAmount,
    "ReceivedAmount": receivedAmount,
    "UploadedPaymentLedgerCount": uploadedPaymentLedgerCount,
    "ApprovalPendingPaymentLedgerCount": approvalPendingPaymentLedgerCount,
  };
}
