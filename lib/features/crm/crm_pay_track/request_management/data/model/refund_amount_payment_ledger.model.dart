import 'package:k3h_erp_app/utils/common_function.dart';

class RefundedAmountLedgerModel {
  int refundedAmountLedgerId;
  String uniquekey;
  int bookingId;
  int projectId;
  String paymentMode;
  int projectBankListMasterId;
  String projectBankName;
  String projectAccountNumber;
  String projectIfscCode;
  String projectNatureOfAccount;
  String projectAcType;
  String accountHolderName;
  int bankListMasterId;
  String bankName;
  String accountNumber;
  String ifscCode;
  double refundedAmount;
  String transactionChequeDemandDraftNumber;
  String transactionChequeDemandDraftUrl;
  DateTime transactionChequeDemandDraftDate;
  String approvalStatus;
  bool isApproval;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  RefundedAmountLedgerModel({
    required this.refundedAmountLedgerId,
    required this.uniquekey,
    required this.bookingId,
    required this.projectId,
    required this.paymentMode,
    required this.projectBankListMasterId,
    required this.projectBankName,
    required this.projectAccountNumber,
    required this.projectIfscCode,
    required this.projectNatureOfAccount,
    required this.projectAcType,
    required this.accountHolderName,
    required this.bankListMasterId,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.refundedAmount,
    required this.transactionChequeDemandDraftNumber,
    required this.transactionChequeDemandDraftUrl,
    required this.transactionChequeDemandDraftDate,
    required this.approvalStatus,
    required this.isApproval,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory RefundedAmountLedgerModel.fromJson(
    Map<String, dynamic> json,
  ) => RefundedAmountLedgerModel(
    refundedAmountLedgerId: parseValue<int>(json, "RefundedAmountLedgerId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    bookingId: parseValue<int>(json, "BookingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    paymentMode: parseValue<String>(json, "PaymentMode"),
    projectBankListMasterId: parseValue<int>(json, "ProjectBankListMasterId"),
    projectBankName: parseValue<String>(json, "ProjectBankName"),
    projectAccountNumber: parseValue<String>(json, "ProjectAccountNumber"),
    projectIfscCode: parseValue<String>(json, "ProjectIFSCCode"),
    projectNatureOfAccount: parseValue<String>(json, "ProjectNatureOfAccount"),
    projectAcType: parseValue<String>(json, "ProjectAcType"),
    accountHolderName: parseValue<String>(json, "AccountHolderName"),
    bankListMasterId: parseValue<int>(json, "BankListMasterId"),
    bankName: parseValue<String>(json, "BankName"),
    accountNumber: parseValue<String>(json, "AccountNumber"),
    ifscCode: parseValue<String>(json, "IFSCCode"),
    refundedAmount: parseValue<double>(json, "RefundedAmount"),
    transactionChequeDemandDraftNumber: parseValue<String>(
      json,
      "TransactionChequeDemandDraftNumber",
    ),
    transactionChequeDemandDraftUrl: parseValue<String>(
      json,
      "TransactionChequeDemandDraftURL",
    ),
    transactionChequeDemandDraftDate: parseValue<DateTime>(
      json,
      "TransactionChequeDemandDraftDate",
    ),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    isApproval: parseValue<bool>(json, "IsApproval"),
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
    "RefundedAmountLedgerId": refundedAmountLedgerId,
    "Uniquekey": uniquekey,
    "BookingId": bookingId,
    "ProjectId": projectId,
    "PaymentMode": paymentMode,
    "ProjectBankListMasterId": projectBankListMasterId,
    "ProjectBankName": projectBankName,
    "ProjectAccountNumber": projectAccountNumber,
    "ProjectIFSCCode": projectIfscCode,
    "ProjectNatureOfAccount": projectNatureOfAccount,
    "ProjectAcType": projectAcType,
    "AccountHolderName": accountHolderName,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "AccountNumber": accountNumber,
    "IFSCCode": ifscCode,
    "RefundedAmount": refundedAmount.toDouble(),
    "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
    "TransactionChequeDemandDraftURL": transactionChequeDemandDraftUrl,
    "TransactionChequeDemandDraftDate":
        transactionChequeDemandDraftDate.toIso8601String(),
    "ApprovalStatus": approvalStatus,
    "IsApproval": isApproval,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
