import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ClientLoanReportModel {
  String applicantName;
  String applicantMobileNumberCountryCode;
  String applicantMobileNumber;
  String buildingNumber;
  String wing;
  String floor;
  String flat;
  String flatType;
  double reraCarpetAreaSqFt;
  String flatConfiguration;
  double agreementValue;
  double loanSanctionAmount;
  DateTime loanSanctionDate;
  String bankName;
  String loanAccountNumber;
  String bankBranchName;
  String address;
  String bankStatusClosedActive;

  ClientLoanReportModel({
    required this.applicantName,
    required this.applicantMobileNumberCountryCode,
    required this.applicantMobileNumber,
    required this.buildingNumber,
    required this.wing,
    required this.floor,
    required this.flat,
    required this.flatType,
    required this.reraCarpetAreaSqFt,
    required this.flatConfiguration,
    required this.agreementValue,
    required this.loanSanctionAmount,
    required this.loanSanctionDate,
    required this.bankName,
    required this.loanAccountNumber,
    required this.bankBranchName,
    required this.address,
    required this.bankStatusClosedActive,
  });

  factory ClientLoanReportModel.fromJson(
    Map<String, dynamic> json,
  ) => ClientLoanReportModel(
    applicantName: parseValue<String>(json, "ApplicantName"),
    applicantMobileNumberCountryCode: parseValue<String>(
      json,
      "ApplicantMobileNumberCountryCode",
    ),
    applicantMobileNumber: parseValue<String>(json, "ApplicantMobileNumber"),
    buildingNumber: parseValue<String>(json, "BuildingNumber"),
    wing: parseValue<String>(json, "Wing"),
    floor: parseValue<String>(json, "Floor"),
    flat: parseValue<String>(json, "Flat"),
    flatType: parseValue<String>(json, "FlatType"),
    reraCarpetAreaSqFt: parseValue<double>(json, "RERACarpetAreaSqFt"),
    flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
    agreementValue: parseValue<double>(json, "AgreementValue"),
    loanSanctionAmount: parseValue<double>(json, "LoanSanctionAmount"),
    loanSanctionDate: parseValue<DateTime>(json, "LoanSanctionDate"),
    bankName: parseValue<String>(json, "BankName"),
    loanAccountNumber: parseValue<String>(json, "LoanAccountNumber"),
    bankBranchName: parseValue<String>(json, "BankBranchName"),
    address: parseValue<String>(json, "Address"),
    bankStatusClosedActive: parseValue<String>(json, "BankStatusClosedActive"),
  );

  Map<String, dynamic> toJson() => {
    "ApplicantName": applicantName,
    "ApplicantMobileNumberCountryCode": applicantMobileNumberCountryCode,
    "ApplicantMobileNumber": applicantMobileNumber,
    "BuildingNumber": buildingNumber,
    "Wing": wing,
    "Floor": floor,
    "Flat": flat,
    "FlatType": flatType,
    "RERACarpetAreaSqFt": reraCarpetAreaSqFt,
    "FlatConfiguration": flatConfiguration,
    "AgreementValue": agreementValue,
    "LoanSanctionAmount": loanSanctionAmount,
    "LoanSanctionDate": loanSanctionDate,
    "BankName": bankName,
    "LoanAccountNumber": loanAccountNumber,
    "BankBranchName": bankBranchName,
    "Address": address,
    "BankStatusClosedActive": bankStatusClosedActive,
  };
}
