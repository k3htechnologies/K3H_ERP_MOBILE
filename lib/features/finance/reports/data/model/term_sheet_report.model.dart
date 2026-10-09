import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TermSheetReportModel {
  String companyName;
  String nameOfInstitutionBankNBFC;
  String projectName;
  String loanTakenBy;
  String type;
  DateTime sanctionDate;
  double facilityAmount;
  double totalDisbursedAmount;
  double balanceDisbursementAmount;
  double totalRepayLedgerAmount;
  double balanceAsOnDateAmount;
  double rateOfInterestInPercentage;
  String approvalStatus;
  DateTime? closingDate;
  String termSheetURL;

  TermSheetReportModel({
    required this.companyName,
    required this.nameOfInstitutionBankNBFC,
    required this.projectName,
    required this.loanTakenBy,
    required this.type,
    required this.sanctionDate,
    required this.facilityAmount,
    required this.totalDisbursedAmount,
    required this.balanceDisbursementAmount,
    required this.totalRepayLedgerAmount,
    required this.balanceAsOnDateAmount,
    required this.rateOfInterestInPercentage,
    required this.approvalStatus,
    required this.closingDate,
    required this.termSheetURL,
  });

  factory TermSheetReportModel.fromJson(
    Map<String, dynamic> json,
  ) => TermSheetReportModel(
    companyName: parseValue<String>(json, "CompanyName"),
    nameOfInstitutionBankNBFC: parseValue<String>(
      json,
      "NameOfInstitutionBankNBFC",
    ),
    projectName: parseValue<String>(json, "ProjectName"),
    loanTakenBy: parseValue<String>(json, "LoanTakenBy"),
    type: parseValue<String>(json, "Type"),
    sanctionDate: parseValue<DateTime>(json, "SanctionDate"),
    facilityAmount: parseValue<double>(json, "FacilityAmount"),
    totalDisbursedAmount: parseValue<double>(json, "TotalDisbursedAmount"),
    balanceDisbursementAmount: parseValue<double>(
      json,
      "BalanceDisbursementAmount",
    ),
    totalRepayLedgerAmount: parseValue<double>(json, "TotalRepayLedgerAmount"),
    balanceAsOnDateAmount: parseValue<double>(json, "BalanceAsOnDateAmount"),
    rateOfInterestInPercentage: parseValue<double>(
      json,
      "RateOfInterestInPercentage",
    ),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    closingDate:
        json["ClosingDate"] == null
            ? null
            : parseValue<DateTime>(json, "ClosingDate"),
    termSheetURL: parseValue<String>(json, "TermSheetURL"),
  );

  Map<String, dynamic> toJson() => {
    "CompanyName": companyName,
    "NameOfInstitutionBankNBFC": nameOfInstitutionBankNBFC,
    "ProjectName": projectName,
    "LoanTakenBy": loanTakenBy,
    "Type": type,
    "SanctionDate": sanctionDate.toIso8601String(),
    "FacilityAmount": facilityAmount,
    "TotalDisbursedAmount": totalDisbursedAmount,
    "BalanceDisbursementAmount": balanceDisbursementAmount,
    "TotalRepayLedgerAmount": totalRepayLedgerAmount,
    "BalanceAsOnDateAmount": balanceAsOnDateAmount,
    "RateOfInterestInPercentage": rateOfInterestInPercentage,
    "ApprovalStatus": approvalStatus,
    "ClosingDate": closingDate?.toIso8601String(),
    "TermSheetURL": termSheetURL,
  };
}
