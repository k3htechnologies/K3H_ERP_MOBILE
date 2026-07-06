import 'package:k3h_erp_app/utils/functions/common_function.dart';

class MaterialRequisitionPaymentModel {
  int materialRequisitionPaymentId;
  String uniquekey;
  int materialRequisitionInvoiceId;
  int materialRequisitionId;
  String paymentMode;
  int bankListMasterId;
  String bankName;
  String accountNumber;
  String ifscCode;
  String paymentType;
  double amountPaid;
  double tdsAmount;
  String transactionNumber;
  String transactionReceiptUrl;
  bool isAdvance;
  int clientRegistrationId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  MaterialRequisitionPaymentModel({
    required this.materialRequisitionPaymentId,
    required this.uniquekey,
    required this.materialRequisitionInvoiceId,
    required this.materialRequisitionId,
    required this.paymentMode,
    required this.bankListMasterId,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.paymentType,
    required this.amountPaid,
    required this.tdsAmount,
    required this.transactionNumber,
    required this.transactionReceiptUrl,
    required this.isAdvance,
    required this.clientRegistrationId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory MaterialRequisitionPaymentModel.fromJson(Map<String, dynamic> json) =>
      MaterialRequisitionPaymentModel(
        materialRequisitionPaymentId: parseValue<int>(
          json,
          "MaterialRequisitionPaymentId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        materialRequisitionInvoiceId: parseValue<int>(
          json,
          "MaterialRequisitionInvoiceId",
        ),
        materialRequisitionId: parseValue<int>(json, "MaterialRequisitionId"),
        paymentMode: parseValue<String>(json, "PaymentMode"),
        bankListMasterId: parseValue<int>(json, "BankListMasterId"),
        bankName: parseValue<String>(json, "BankName"),
        accountNumber: parseValue<String>(json, "AccountNumber"),
        ifscCode: parseValue<String>(json, "IFSCCode"),
        paymentType: parseValue<String>(json, "PaymentType"),
        amountPaid: parseValue<double>(json, "AmountPaid"),
        tdsAmount: parseValue<double>(json, "TDSAmount"),
        transactionNumber: parseValue<String>(json, "TransactionNumber"),
        transactionReceiptUrl: parseValue<String>(
          json,
          "TransactionReceiptURL",
        ),
        isAdvance: parseValue<bool>(json, "IsAdvance"),
        clientRegistrationId: parseValue<int>(json, "ClientRegistrationId"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate: parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "MaterialRequisitionPaymentId": materialRequisitionPaymentId,
    "Uniquekey": uniquekey,
    "MaterialRequisitionInvoiceId": materialRequisitionInvoiceId,
    "MaterialRequisitionId": materialRequisitionId,
    "PaymentMode": paymentMode,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "AccountNumber": accountNumber,
    "IFSCCode": ifscCode,
    "PaymentType": paymentType,
    "AmountPaid": amountPaid,
    "TDSAmount": tdsAmount,
    "TransactionNumber": transactionNumber,
    "TransactionReceiptURL": transactionReceiptUrl,
    "IsAdvance": isAdvance,
    "ClientRegistrationId": clientRegistrationId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
