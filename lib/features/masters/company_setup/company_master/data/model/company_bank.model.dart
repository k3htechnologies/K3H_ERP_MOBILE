import 'package:k3h_erp_app/utils/functions/common_function.dart';

class CompanyBankModel {
  int companyWithBankDetailsId;
  String uniquekey;
  int companyId;
  String companyName;
  String beneficiaryAccountHolderName;
  int bankListMasterId;
  String bankName;
  String accountNumber;
  String branch;
  String ifscCode;
  String acType;
  String natureOfAccount;
  String status;
  String mICRCode;
  String cancelChequeURL;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  CompanyBankModel({
    required this.companyWithBankDetailsId,
    required this.uniquekey,
    required this.companyId,
    required this.companyName,
    required this.beneficiaryAccountHolderName,
    required this.bankListMasterId,
    required this.bankName,
    required this.accountNumber,
    required this.branch,
    required this.ifscCode,
    required this.acType,
    required this.natureOfAccount,
    required this.status,
    required this.mICRCode,
    required this.cancelChequeURL,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory CompanyBankModel.fromJson(Map<String, dynamic> json) =>
      CompanyBankModel(
        companyWithBankDetailsId: parseValue<int>(
          json,
          "CompanyWithBankDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        companyId: parseValue<int>(json, "CompanyId"),
        companyName: parseValue<String>(json, "CompanyName"),
        beneficiaryAccountHolderName: parseValue<String>(
          json,
          "BeneficiaryAccountHolderName",
        ),
        bankListMasterId: parseValue<int>(json, "BankListMasterId"),
        bankName: parseValue<String>(json, "BankName"),
        accountNumber: parseValue<String>(json, "AccountNumber"),
        branch: parseValue<String>(json, "Branch"),
        ifscCode: parseValue<String>(json, "IFSCCode"),
        acType: parseValue<String>(json, "AcType"),
        natureOfAccount: parseValue<String>(json, "NatureOfAccount"),
        status: parseValue<String>(json, "Status"),
        mICRCode: parseValue<String>(json, "MICRCode"),
        cancelChequeURL: parseValue<String>(json, "CancelChequeURL"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "CompanyWithBankDetailsId": companyWithBankDetailsId,
    "Uniquekey": uniquekey,
    "CompanyId": companyId,
    "CompanyName": companyName,
    "BeneficiaryAccountHolderName": beneficiaryAccountHolderName,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "AccountNumber": accountNumber,
    "Branch": branch,
    "IFSCCode": ifscCode,
    "AcType": acType,
    "NatureOfAccount": natureOfAccount,
    "Status": status,
    "MICRCode": mICRCode,
    "CancelChequeURL": cancelChequeURL,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
