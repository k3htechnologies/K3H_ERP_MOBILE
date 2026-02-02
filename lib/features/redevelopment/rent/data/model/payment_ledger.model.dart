import 'package:k3h_erp_app/utils/common_function.dart';

class PaymentLedgerModel {
  int payTrackRentId;
  String uniquekey;
  int tenantId;
  int tenantApplicantId;
  int buildingId;
  int projectId;
  String flatNumber;
  double flatCarpetAreaSqFt;
  String facing;
  String flatType;
  String flatConfiguration;
  String applicantType;
  String applicantName;
  String applicantMobileNumber;
  String applicantEmailId;
  String paymentMode;
  int projectBankListMasterId;
  String projectBankName;
  String projectBankAccountNumber;
  String projectBankIfscCode;
  String projectBankAccountHolderName;
  int bankListMasterId;
  String bankName;
  String accountNumber;
  String ifscCode;
  String amountType;
  String paymentType;
  double payAmount;
  String transactionChequeDemandDraftNumber;
  String transactionChequeDemandDraftUrl;
  DateTime transactionChequeDemandDraftDate;
  String paymentReceiptUrl;
  String approvalStatus;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  String tenure;
  String chargeType;

  PaymentLedgerModel({
    required this.payTrackRentId,
    required this.uniquekey,
    required this.tenantId,
    required this.tenantApplicantId,
    required this.buildingId,
    required this.projectId,
    required this.flatNumber,
    required this.flatCarpetAreaSqFt,
    required this.facing,
    required this.flatType,
    required this.flatConfiguration,
    required this.applicantType,
    required this.applicantName,
    required this.applicantMobileNumber,
    required this.applicantEmailId,
    required this.paymentMode,
    required this.projectBankListMasterId,
    required this.projectBankName,
    required this.projectBankAccountNumber,
    required this.projectBankIfscCode,
    required this.projectBankAccountHolderName,
    required this.bankListMasterId,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.amountType,
    required this.paymentType,
    required this.payAmount,
    required this.transactionChequeDemandDraftNumber,
    required this.transactionChequeDemandDraftUrl,
    required this.transactionChequeDemandDraftDate,
    required this.paymentReceiptUrl,
    required this.approvalStatus,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.tenure,
    required this.chargeType,
  });

  factory PaymentLedgerModel.fromJson(Map<String, dynamic> json) =>
      PaymentLedgerModel(
        payTrackRentId: parseValue<int>(json, "PayTrackRentId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        tenantId: parseValue<int>(json, "TenantId"),
        tenantApplicantId: parseValue<int>(json, "TenantApplicantId"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        flatNumber: parseValue<String>(json, "FlatNumber"),
        flatCarpetAreaSqFt: parseValue<double>(json, "FlatCarpetAreaSqFt"),
        facing: parseValue<String>(json, "Facing"),
        flatType: parseValue<String>(json, "FlatType"),
        flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
        applicantType: parseValue<String>(json, "ApplicantType"),
        applicantName: parseValue<String>(json, "ApplicantName"),
        applicantMobileNumber: parseValue<String>(json, "ApplicantMobileNumber"),
        applicantEmailId: parseValue<String>(json, "ApplicantEmailId"),
        paymentMode: parseValue<String>(json, "PaymentMode"),
        projectBankListMasterId:
            parseValue<int>(json, "ProjectBankListMasterId"),
        projectBankName: parseValue<String>(json, "ProjectBankName"),
        projectBankAccountNumber:
            parseValue<String>(json, "ProjectBankAccountNumber"),
        projectBankIfscCode: parseValue<String>(json, "ProjectBankIFSCCode"),
        projectBankAccountHolderName:
            parseValue<String>(json, "ProjectBankAccountHolderName"),
        bankListMasterId: parseValue<int>(json, "BankListMasterId"),
        bankName: parseValue<String>(json, "BankName"),
        accountNumber: parseValue<String>(json, "AccountNumber"),
        ifscCode: parseValue<String>(json, "IFSCCode"),
        amountType: parseValue<String>(json, "AmountType"),
        paymentType: parseValue<String>(json, "PaymentType"),
        payAmount: parseValue<double>(json, "PayAmount"),
        transactionChequeDemandDraftNumber:
            parseValue<String>(json, "TransactionChequeDemandDraftNumber"),
        transactionChequeDemandDraftUrl:
            parseValue<String>(json, "TransactionChequeDemandDraftURL"),
        transactionChequeDemandDraftDate:
            parseValue<DateTime>(json, "TransactionChequeDemandDraftDate"),
        paymentReceiptUrl: parseValue<String>(json, "PaymentReceiptURL"),
        approvalStatus: parseValue<String>(json, "ApprovalStatus"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
        tenure: parseValue<String>(json, "Tenure"),
        chargeType: parseValue<String>(json, "ChargeType"),
      );

  Map<String, dynamic> toJson() => {
    "PayTrackRentId": payTrackRentId,
    "Uniquekey": uniquekey,
    "TenantId": tenantId,
    "TenantApplicantId": tenantApplicantId,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "FlatNumber": flatNumber,
    "FlatCarpetAreaSqFt": flatCarpetAreaSqFt,
    "Facing": facing,
    "FlatType": flatType,
    "FlatConfiguration": flatConfiguration,
    "ApplicantType": applicantType,
    "ApplicantName": applicantName,
    "ApplicantMobileNumber": applicantMobileNumber,
    "ApplicantEmailId": applicantEmailId,
    "PaymentMode": paymentMode,
    "ProjectBankListMasterId": projectBankListMasterId,
    "ProjectBankName": projectBankName,
    "ProjectBankAccountNumber": projectBankAccountNumber,
    "ProjectBankIFSCCode": projectBankIfscCode,
    "ProjectBankAccountHolderName": projectBankAccountHolderName,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "AccountNumber": accountNumber,
    "IFSCCode": ifscCode,
    "AmountType": amountType,
    "PaymentType": paymentType,
    "PayAmount": payAmount,
    "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
    "TransactionChequeDemandDraftURL": transactionChequeDemandDraftUrl,
    "TransactionChequeDemandDraftDate": transactionChequeDemandDraftDate.toIso8601String(),
    "PaymentReceiptURL": paymentReceiptUrl,
    "ApprovalStatus": approvalStatus,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
    "Tenure": tenure,
    "ChargeType": chargeType,
  };
}
