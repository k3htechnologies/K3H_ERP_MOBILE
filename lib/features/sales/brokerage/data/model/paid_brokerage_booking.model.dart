import 'package:k3h_erp_app/utils/functions/common_function.dart';

class PaidBrokerageBookingModel {
  int paidBrokerageBookingId;
  String uniquekey;
  int bookingId;
  int projectId;
  int brokerageInvoiceId;
  String invoiceNumber;
  double invoiceAmount;
  String paymentMode;
  int projectBankListMasterId;
  String projectBankName;
  String projectAccountNumber;
  String projectIFSCCode;
  String projectNatureOfAccount;
  String projectAcType;
  String paymentType;
  double amountPaid;
  double tdsAmount;
  String accountNumber;
  String ifscCode;
  String transactionNumber;
  String transactionReceiptURL;
  DateTime transactionChequeDemandDraftDate;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  PaidBrokerageBookingModel({
    required this.paidBrokerageBookingId,
    required this.uniquekey,
    required this.bookingId,
    required this.projectId,
    required this.brokerageInvoiceId,
    required this.invoiceNumber,
    required this.invoiceAmount,
    required this.paymentMode,
    required this.projectBankListMasterId,
    required this.projectBankName,
    required this.projectAccountNumber,
    required this.projectIFSCCode,
    required this.projectNatureOfAccount,
    required this.projectAcType,
    required this.paymentType,
    required this.amountPaid,
    required this.tdsAmount,
    required this.accountNumber,
    required this.ifscCode,
    required this.transactionNumber,
    required this.transactionReceiptURL,
    required this.transactionChequeDemandDraftDate,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });
  factory PaidBrokerageBookingModel.fromJson(
    Map<String, dynamic> json,
  ) => PaidBrokerageBookingModel(
    paidBrokerageBookingId: parseValue<int>(json, "PaidBrokerageBookingId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    bookingId: parseValue<int>(json, "BookingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    brokerageInvoiceId: parseValue<int>(json, "BrokerageInvoiceId"),
    invoiceNumber: parseValue<String>(json, "InvoiceNumber"),
    invoiceAmount: parseValue<double>(json, "InvoiceAmount"),
    paymentMode: parseValue<String>(json, "PaymentMode"),
    projectBankListMasterId: parseValue<int>(json, "ProjectBankListMasterId"),
    projectBankName: parseValue<String>(json, "ProjectBankName"),
    projectAccountNumber: parseValue<String>(json, "ProjectAccountNumber"),
    projectIFSCCode: parseValue<String>(json, "ProjectIFSCCode"),
    projectNatureOfAccount: parseValue<String>(json, "ProjectNatureOfAccount"),
    projectAcType: parseValue<String>(json, "ProjectAcType"),
    paymentType: parseValue<String>(json, "PaymentType"),
    amountPaid: parseValue<double>(json, "AmountPaid"),
    tdsAmount: parseValue<double>(json, "TDSAmount"),
    accountNumber: parseValue<String>(json, "AccountNumber"),
    ifscCode: parseValue<String>(json, "IFSCCode"),
    transactionNumber: parseValue<String>(json, "TransactionNumber"),
    transactionReceiptURL: parseValue<String>(json, "TransactionReceiptURL"),
    transactionChequeDemandDraftDate: parseValue<DateTime>(
      json,
      "TransactionChequeDemandDraftDate",
    ),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : DateTime.parse(json["ModifiedDate"]),
  );
  Map<String, dynamic> toJson() => {
    "PaidBrokerageBookingId": paidBrokerageBookingId,
    "Uniquekey": uniquekey,
    "BookingId": bookingId,
    "ProjectId": projectId,
    "BrokerageInvoiceId": brokerageInvoiceId,
    "InvoiceNumber": invoiceNumber,
    "InvoiceAmount": invoiceAmount,
    "PaymentMode": paymentMode,
    "ProjectBankListMasterId": projectBankListMasterId,
    "ProjectBankName": projectBankName,
    "ProjectAccountNumber": projectAccountNumber,
    "ProjectIFSCCode": projectIFSCCode,
    "ProjectNatureOfAccount": projectNatureOfAccount,
    "ProjectAcType": projectAcType,
    "PaymentType": paymentType,
    "AmountPaid": amountPaid,
    "TDSAmount": tdsAmount,
    "AccountNumber": accountNumber,
    "IFSCCode": ifscCode,
    "TransactionNumber": transactionNumber,
    "TransactionReceiptURL": transactionReceiptURL,
    "TransactionChequeDemandDraftDate": transactionChequeDemandDraftDate,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
