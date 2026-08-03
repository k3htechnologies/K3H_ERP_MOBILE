import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProjectWithBankDetailsModel {
  int projectWithBankDetailsId;
  String uniquekey;
  int projectId;
  String projectName;
  String beneficiaryAccountHolderName;
  int bankListMasterId;
  String bankName;
  String accountNumber;
  String branch;
  String ifscCode;
  String acType;
  String natureOfAccount;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ProjectWithBankDetailsModel({
    required this.projectWithBankDetailsId,
    required this.uniquekey,
    required this.projectId,
    required this.projectName,
    required this.beneficiaryAccountHolderName,
    required this.bankListMasterId,
    required this.bankName,
    required this.accountNumber,
    required this.branch,
    required this.ifscCode,
    required this.acType,
    required this.natureOfAccount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ProjectWithBankDetailsModel.fromJson(Map<String, dynamic> json) =>
      ProjectWithBankDetailsModel(
        projectWithBankDetailsId: parseValue<int>(
          json,
          "ProjectWithBankDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        projectName: parseValue<String>(json, "ProjectName"),
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
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate:
            json["CreatedDate"] != null
                ? DateTime.parse(json["CreatedDate"])
                : null,
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] != null
                ? DateTime.parse(json["ModifiedDate"])
                : null,
      );

  Map<String, dynamic> toJson() => {
    "ProjectWithBankDetailsId": projectWithBankDetailsId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ProjectName": projectName,
    "BeneficiaryAccountHolderName": beneficiaryAccountHolderName,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "AccountNumber": accountNumber,
    "Branch": branch,
    "IFSCCode": ifscCode,
    "AcType": acType,
    "NatureOfAccount": natureOfAccount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
