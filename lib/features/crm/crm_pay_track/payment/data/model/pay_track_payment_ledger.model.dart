import 'package:k3h_erp_app/utils/common_function.dart';

class PayTrackPaymentLedgerModel {
  int payTrackPaymentLedgerId;
  String uniquekey;
  int bookingId;
  int projectId;
  int bookingOtherChargesId;
  String chargeName;
  String paymentFor;
  String paymentMode;
  String paymentReceivedFrom;
  int bankListMasterId;
  String bankName;
  String amountType;
  String paymentType;
  double receivedAmount;
  String transactionChequeDemandDraftNumber;
  String transactionChequeDemandDraftUrl;
  DateTime? transactionChequeDemandDraftDate;
  String approvalStatus;
  bool isApproval;
  String paymentReceiptUrl;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  PayTrackPaymentLedgerModel({
    required this.payTrackPaymentLedgerId,
    required this.uniquekey,
    required this.bookingId,
    required this.projectId,
    required this.bookingOtherChargesId,
    required this.chargeName,
    required this.paymentFor,
    required this.paymentMode,
    required this.paymentReceivedFrom,
    required this.bankListMasterId,
    required this.bankName,
    required this.amountType,
    required this.paymentType,
    required this.receivedAmount,
    required this.transactionChequeDemandDraftNumber,
    required this.transactionChequeDemandDraftUrl,
    required this.transactionChequeDemandDraftDate,
    required this.approvalStatus,
    required this.isApproval,
    required this.paymentReceiptUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory PayTrackPaymentLedgerModel.fromJson(
    Map<String, dynamic> json,
  ) => PayTrackPaymentLedgerModel(
    payTrackPaymentLedgerId: parseValue<int>(json, "PayTrackPaymentLedgerId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    bookingId: parseValue<int>(json, "BookingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    bookingOtherChargesId: parseValue<int>(json, "BookingOtherChargesId"),
    chargeName: parseValue<String>(json, "ChargeName"),
    paymentFor: parseValue<String>(json, "PaymentFor"),
    paymentMode: parseValue<String>(json, "PaymentMode"),
    paymentReceivedFrom: parseValue<String>(json, "PaymentReceivedFrom"),
    bankListMasterId: parseValue<int>(json, "BankListMasterId"),
    bankName: parseValue<String>(json, "BankName"),
    amountType: parseValue<String>(json, "AmountType"),
    paymentType: parseValue<String>(json, "PaymentType"),
    receivedAmount: parseValue<double>(json, "ReceivedAmount"),
    transactionChequeDemandDraftNumber: parseValue<String>(
      json,
      "TransactionChequeDemandDraftNumber",
    ),
    transactionChequeDemandDraftUrl: parseValue<String>(
      json,
      "TransactionChequeDemandDraftURL",
    ),
    transactionChequeDemandDraftDate:
        json["TransactionChequeDemandDraftDate"] == null
            ? null
            : parseValue<DateTime>(json, "TransactionChequeDemandDraftDate"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    paymentReceiptUrl: parseValue<String>(json, "PaymentReceiptURL"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: DateTime.parse(json["CreatedDate"]),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
  );

  Map<String, dynamic> toJson() => {
    "PayTrackPaymentLedgerId": payTrackPaymentLedgerId,
    "Uniquekey": uniquekey,
    "BookingId": bookingId,
    "ProjectId": projectId,
    "BookingOtherChargesId": bookingOtherChargesId,
    "ChargeName": chargeName,
    "PaymentFor": paymentFor,
    "PaymentMode": paymentMode,
    "PaymentReceivedFrom": paymentReceivedFrom,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "AmountType": amountType,
    "PaymentType": paymentType,
    "ReceivedAmount": receivedAmount,
    "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
    "TransactionChequeDemandDraftURL": transactionChequeDemandDraftUrl,
    "TransactionChequeDemandDraftDate":
        transactionChequeDemandDraftDate?.toIso8601String(),
    "ApprovalStatus": approvalStatus,
    "IsApproval": isApproval,
    "PaymentReceiptURL": paymentReceiptUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
