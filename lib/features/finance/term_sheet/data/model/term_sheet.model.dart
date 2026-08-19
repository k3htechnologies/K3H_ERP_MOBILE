import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TermSheetModel {
  int termSheetId;
  String uniquekey;
  int projectId;
  String projectName;
  int companyId;
  String companyName;
  String approvalStatus;
  DateTime? closingDate;
  String closingRemark;
  int termSheetDetailsId;
  String loanTakenBy;
  String nameOfInstitutionBankNbfc;
  String type;
  DateTime? termSheetDate;
  DateTime? sanctionDate;
  double facilityAmount;
  double rateOfInterestInPercentage;
  double processingFeesInPercentage;
  double legalAndDoumentationFees;
  double monotoriumPeriodInMonth;
  double loanTenureInMonth;
  double minimumSellingPrice;
  String otherImportantTermsIfAny;
  String remark;
  DateTime? loanStartDate;
  DateTime? loanEndDate;
  double emiAmount;
  String termSheetUrl;
  double totalDisbursedAmount;
  double totalRepayLedgerAmount;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TermSheetModel({
    required this.termSheetId,
    required this.uniquekey,
    required this.projectId,
    required this.projectName,
    required this.companyId,
    required this.companyName,
    required this.approvalStatus,
    required this.closingDate,
    required this.closingRemark,
    required this.termSheetDetailsId,
    required this.loanTakenBy,
    required this.nameOfInstitutionBankNbfc,
    required this.type,
    required this.termSheetDate,
    required this.sanctionDate,
    required this.facilityAmount,
    required this.rateOfInterestInPercentage,
    required this.processingFeesInPercentage,
    required this.legalAndDoumentationFees,
    required this.monotoriumPeriodInMonth,
    required this.loanTenureInMonth,
    required this.minimumSellingPrice,
    required this.otherImportantTermsIfAny,
    required this.remark,
    required this.loanStartDate,
    required this.loanEndDate,
    required this.emiAmount,
    required this.termSheetUrl,
    required this.totalDisbursedAmount,
    required this.totalRepayLedgerAmount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TermSheetModel.fromJson(Map<String, dynamic> json) => TermSheetModel(
    termSheetId: parseValue<int>(json, "TermSheetId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    projectName: parseValue<String>(json, "ProjectName"),
    companyId: parseValue<int>(json, "CompanyId"),
    companyName: parseValue<String>(json, "CompanyName"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    closingDate:
        json["ClosingDate"] == null
            ? null
            : DateTime.parse(json["ClosingDate"]),
    closingRemark: parseValue<String>(json, "ClosingRemark"),
    termSheetDetailsId: parseValue<int>(json, "TermSheetDetailsId"),
    loanTakenBy: parseValue<String>(json, "LoanTakenBy"),
    nameOfInstitutionBankNbfc: parseValue<String>(
      json,
      "NameOfInstitutionBankNBFC",
    ),
    type: parseValue<String>(json, "Type"),
    termSheetDate:
        json["TermSheetDate"] == null
            ? null
            : DateTime.parse(json["TermSheetDate"]),
    sanctionDate:
        json["SanctionDate"] == null
            ? null
            : DateTime.parse(json["SanctionDate"]),
    facilityAmount: parseValue<double>(json, "FacilityAmount"),
    rateOfInterestInPercentage: parseValue<double>(
      json,
      "RateOfInterestInPercentage",
    ),
    processingFeesInPercentage: parseValue<double>(
      json,
      "ProcessingFeesInPercentage",
    ),
    legalAndDoumentationFees: parseValue<double>(
      json,
      "LegalAndDoumentationFees",
    ),
    monotoriumPeriodInMonth: parseValue<double>(
      json,
      "MonotoriumPeriodInMonth",
    ),
    loanTenureInMonth: parseValue<double>(json, "LoanTenureInMonth"),
    minimumSellingPrice: parseValue<double>(json, "MinimumSellingPrice"),
    otherImportantTermsIfAny: parseValue<String>(
      json,
      "OtherImportantTermsIfAny",
    ),
    remark: parseValue<String>(json, "Remark"),
    loanStartDate:
        json["LoanStartDate"] == null
            ? null
            : DateTime.parse(json["LoanStartDate"]),
    loanEndDate:
        json["LoanEndDate"] == null
            ? null
            : DateTime.parse(json["LoanEndDate"]),
    emiAmount: parseValue<double>(json, "EMIAmount"),
    termSheetUrl: parseValue<String>(json, "TermSheetURL"),
    totalDisbursedAmount: parseValue<double>(json, "TotalDisbursedAmount"),
    totalRepayLedgerAmount: parseValue<double>(json, "TotalRepayLedgerAmount"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate:
        json["CreatedDate"] == null
            ? null
            : DateTime.parse(json["CreatedDate"]),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : DateTime.parse(json["ModifiedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "TermSheetId": termSheetId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ProjectName": projectName,
    "CompanyId": companyId,
    "CompanyName": companyName,
    "ApprovalStatus": approvalStatus,
    "ClosingDate": closingDate?.toIso8601String(),
    "ClosingRemark": closingRemark,
    "TermSheetDetailsId": termSheetDetailsId,
    "LoanTakenBy": loanTakenBy,
    "NameOfInstitutionBankNBFC": nameOfInstitutionBankNbfc,
    "Type": type,
    "TermSheetDate": termSheetDate?.toIso8601String(),
    "SanctionDate": sanctionDate?.toIso8601String(),
    "FacilityAmount": facilityAmount,
    "RateOfInterestInPercentage": rateOfInterestInPercentage,
    "ProcessingFeesInPercentage": processingFeesInPercentage,
    "LegalAndDoumentationFees": legalAndDoumentationFees,
    "MonotoriumPeriodInMonth": monotoriumPeriodInMonth,
    "LoanTenureInMonth": loanTenureInMonth,
    "MinimumSellingPrice": minimumSellingPrice,
    "OtherImportantTermsIfAny": otherImportantTermsIfAny,
    "Remark": remark,
    "LoanStartDate": loanStartDate?.toIso8601String(),
    "LoanEndDate": loanEndDate?.toIso8601String(),
    "EMIAmount": emiAmount,
    "TermSheetURL": termSheetUrl,
    "TotalDisbursedAmount": totalDisbursedAmount,
    "TotalRepayLedgerAmount": totalRepayLedgerAmount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
