class BankDetailsModel {
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
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  BankDetailsModel({
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
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) =>
      BankDetailsModel(
        projectWithBankDetailsId: json["ProjectWithBankDetailsId"],
        uniquekey: json["Uniquekey"],
        projectId: json["ProjectId"],
        projectName: json["ProjectName"],
        beneficiaryAccountHolderName: json["BeneficiaryAccountHolderName"],
        bankListMasterId: json["BankListMasterId"],
        bankName: json["BankName"],
        accountNumber: json["AccountNumber"],
        branch: json["Branch"],
        ifscCode: json["IFSCCode"],
        acType: json["AcType"],
        createdById: json["CreatedById"],
        createdBy: json["CreatedBy"],
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: json["ModifiedById"],
        modifiedBy: json["ModifiedBy"],
        modifiedDate: json["ModifiedDate"],
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
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}