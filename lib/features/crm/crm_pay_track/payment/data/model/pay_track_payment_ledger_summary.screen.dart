import 'package:k3h_erp_app/utils/common_function.dart';

class PayTrackPaymentLedgerSummaryModel {
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
  int projectBankListMasterId;
  String projectBankName;
  String projectAccountNumber;
  String projectIfscCode;
  double receivedAmount;
  String transactionChequeDemandDraftNumber;
  String transactionChequeDemandDraftUrl;
  DateTime transactionChequeDemandDraftDate;
  bool isBookingAmount;
  String approvalStatus;
  bool isApproval;
  String paymentReceiptUrl;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime modifiedDate;
  String projectName;
  String applicantName;
  String applicantMobileNumber;
  String applicantEmailId;
  String projectNatureOfAccount;
  String projectAcType;

  PayTrackPaymentLedgerSummaryModel({
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
    required this.projectBankListMasterId,
    required this.projectBankName,
    required this.projectAccountNumber,
    required this.projectIfscCode,
    required this.receivedAmount,
    required this.transactionChequeDemandDraftNumber,
    required this.transactionChequeDemandDraftUrl,
    required this.transactionChequeDemandDraftDate,
    required this.isBookingAmount,
    required this.approvalStatus,
    required this.isApproval,
    required this.paymentReceiptUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.projectName,
    required this.applicantName,
    required this.applicantMobileNumber,
    required this.applicantEmailId,
    required this.projectNatureOfAccount,
    required this.projectAcType,
  });

  factory PayTrackPaymentLedgerSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) => PayTrackPaymentLedgerSummaryModel(
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
    projectBankListMasterId: parseValue<int>(json, "ProjectBankListMasterId"),
    projectBankName: parseValue<String>(json, "ProjectBankName"),
    projectAccountNumber: parseValue<String>(json, "ProjectAccountNumber"),
    projectIfscCode: parseValue<String>(json, "ProjectIFSCCode"),
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
        json["TransactionChequeDemandDraftDate"] != null
            ? DateTime.parse(json["TransactionChequeDemandDraftDate"])
            : DateTime.now(),
    isBookingAmount: parseValue<bool>(json, "IsBookingAmount"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    paymentReceiptUrl: parseValue<String>(json, "PaymentReceiptURL"),
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
    projectName: parseValue<String>(json, "ProjectName"),
    applicantName: parseValue<String>(json, "ApplicantName"),
    applicantMobileNumber: parseValue<String>(json, "ApplicantMobileNumber"),
    applicantEmailId: parseValue<String>(json, "ApplicantEmailId"),
    projectNatureOfAccount: parseValue<String>(json, "ProjectNatureOfAccount"),
    projectAcType: parseValue<String>(json, "ProjectAcType"),
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
    "ProjectBankListMasterId": projectBankListMasterId,
    "ProjectBankName": projectBankName,
    "ProjectAccountNumber": projectAccountNumber,
    "ProjectIFSCCode": projectIfscCode,
    "ReceivedAmount": receivedAmount,
    "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
    "TransactionChequeDemandDraftURL": transactionChequeDemandDraftUrl,
    "TransactionChequeDemandDraftDate":
        transactionChequeDemandDraftDate.toIso8601String(),
    "IsBookingAmount": isBookingAmount,
    "ApprovalStatus": approvalStatus,
    "IsApproval": isApproval,
    "PaymentReceiptURL": paymentReceiptUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate.toIso8601String(),
    "ProjectName": projectName,
    "ApplicantName": applicantName,
    "ApplicantMobileNumber": applicantMobileNumber,
    "ApplicantEmailId": applicantEmailId,
    "ProjectNatureOfAccount": projectNatureOfAccount,
    "ProjectAcType": projectAcType,
  };
}
