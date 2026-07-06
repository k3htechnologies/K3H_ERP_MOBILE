import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BrokerageInvoiceModel {
  int brokerageInvoiceId;
  String uniqueKey;
  int bookingId;
  int projectId;
  String invoiceNumber;
  final DateTime invoiceDate;
  String uploadInvoiceURL;
  int bankListMasterId;
  String bankName;
  String accountName;
  String accountNumber;
  String ifscCode;
  double invoiceAmount;
  double paymentAmount;
  DateTime dueDate;
  String remark;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  String approvalStatus;
  bool isApproval;

  BrokerageInvoiceModel({
    required this.brokerageInvoiceId,
    required this.uniqueKey,
    required this.bookingId,
    required this.projectId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.uploadInvoiceURL,
    required this.bankListMasterId,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.invoiceAmount,
    required this.paymentAmount,
    required this.dueDate,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
    required this.approvalStatus,
    required this.isApproval,
  });

  factory BrokerageInvoiceModel.fromJson(Map<String, dynamic> json) {
    return BrokerageInvoiceModel(
      brokerageInvoiceId: parseValue<int>(json, "BrokerageInvoiceId"),
      uniqueKey: parseValue<String>(json, "Uniquekey"),
      bookingId: parseValue<int>(json, "BookingId"),
      projectId: parseValue<int>(json, "ProjectId"),
      invoiceNumber: parseValue<String>(json, "InvoiceNumber"),
      invoiceDate: DateTime.parse(json["InvoiceDate"]),
      uploadInvoiceURL: parseValue<String>(json, "UploadInvoiceURL"),
      bankListMasterId: parseValue<int>(json, "BankListMasterId"),
      bankName: parseValue<String>(json, "BankName"),
      accountName: parseValue<String>(json, "AccountName"),
      accountNumber: parseValue<String>(json, "AccountNumber"),
      ifscCode: parseValue<String>(json, "IFSCCode"),
      invoiceAmount: parseValue<double>(json, "InvoiceAmount"),
      paymentAmount: parseValue<double>(json, "PaymentAmount"),
      dueDate: DateTime.parse(json["DueDate"]),
      remark: parseValue<String>(json, "Remark"),
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate: DateTime.parse(json["CreatedDate"]),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate:
          json["ModifiedDate"] == null
              ? null
              : DateTime.parse(json["ModifiedDate"]),
      approvalStatus: parseValue<String>(json, "ApprovalStatus"),
      isApproval: parseValue<bool>(json, "IsApproval"),
    );
  }

  Map<String, dynamic> toJson() => {
    "BrokerageInvoiceId": brokerageInvoiceId,
    "Uniquekey": uniqueKey,
    "BookingId": bookingId,
    "ProjectId": projectId,
    "InvoiceNumber": invoiceNumber,
    "InvoiceDate": invoiceDate.toIso8601String(),
    "UploadInvoiceURL": uploadInvoiceURL,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "AccountName": accountName,
    "AccountNumber": accountNumber,
    "IFSCCode": ifscCode,
    "InvoiceAmount": invoiceAmount,
    "PaymentAmount": paymentAmount,
    "DueDate": dueDate.toIso8601String(),
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "ApprovalStatus": approvalStatus,
    "IsApproval": isApproval,
  };
}
