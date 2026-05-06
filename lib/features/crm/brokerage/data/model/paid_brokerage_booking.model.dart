import 'package:k3h_erp_app/utils/common_function.dart';

class PaidBrokerageBookingModel {
  int paidBrokerageBookingId;
  String uniqueKey;
  String invoiceNumber;
  double invoiceAmount;
  int bookingId;
  int projectId;
  int brokerageInvoiceId;
  String paymentMode;
  int bankListMasterId;
  String bankName;
  String paymentType;
  double amountPaid;
  double tdsAmount;
  String accountNumber;
  String ifscCode;
  String transactionNumber;
  String transactionReceiptURL;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  PaidBrokerageBookingModel({
    required this.paidBrokerageBookingId,
    required this.uniqueKey,
    required this.invoiceNumber,
    required this.invoiceAmount,
    required this.bookingId,
    required this.projectId,
    required this.brokerageInvoiceId,
    required this.paymentMode,
    required this.bankListMasterId,
    required this.bankName,
    required this.paymentType,
    required this.amountPaid,
    required this.tdsAmount,
    required this.accountNumber,
    required this.ifscCode,
    required this.transactionNumber,
    required this.transactionReceiptURL,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
  });

  factory PaidBrokerageBookingModel.fromJson(Map<String, dynamic> json) =>
      PaidBrokerageBookingModel(
        paidBrokerageBookingId: parseValue<int>(json, "PaidBrokerageBookingId"),
        uniqueKey: parseValue<String>(json, "Uniquekey"),
        invoiceNumber: parseValue<String>(json, "InvoiceNumber"),
        invoiceAmount: parseValue<double>(json, "InvoiceAmount"),
        bookingId: parseValue<int>(json, "BookingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        brokerageInvoiceId: parseValue<int>(json, "BrokerageInvoiceId"),
        paymentMode: parseValue<String>(json, "PaymentMode"),
        bankListMasterId: parseValue<int>(json, "BankListMasterId"),
        bankName: parseValue<String>(json, "BankName"),
        paymentType: parseValue<String>(json, "PaymentType"),
        amountPaid: parseValue<double>(json, "AmountPaid"),
        tdsAmount: parseValue<double>(json, "TDSAmount"),
        accountNumber: parseValue<String>(json, "AccountNumber"),
        ifscCode: parseValue<String>(json, "IFSCCode"),
        transactionNumber: parseValue<String>(json, "TransactionNumber"),
        transactionReceiptURL: parseValue<String>(
          json,
          "TransactionReceiptURL",
        ),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : DateTime.parse(json["ModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
    "PaidBrokerageBookingId": paidBrokerageBookingId,
    "Uniquekey": uniqueKey,
    "BookingId": bookingId,
    "ProjectId": projectId,
    "BrokerageInvoiceId": brokerageInvoiceId,
    "PaymentMode": paymentMode,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "PaymentType": paymentType,
    "AmountPaid": amountPaid,
    "TDSAmount": tdsAmount,
    "AccountNumber": accountNumber,
    "IFSCCode": ifscCode,
    "TransactionNumber": transactionNumber,
    "TransactionReceiptURL": transactionReceiptURL,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
