import 'package:k3h_erp_app/utils/common_function.dart';

class BookingLoanDetailsModel {
  int bookingLoanDetailsId;
  String uniquekey;
  int bookingId;
  int projectId;
  double loanSanctionAmount;
  DateTime? loanSanctionDate;
  int bankListMasterId;
  String bankName;
  String loanAccountNumber;
  String bankBranchName;
  String bankStatusClosedActive;
  int noOfBankDocument;
  String address;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BookingLoanDetailsModel({
    required this.bookingLoanDetailsId,
    required this.uniquekey,
    required this.bookingId,
    required this.projectId,
    required this.loanSanctionAmount,
    required this.loanSanctionDate,
    required this.bankListMasterId,
    required this.bankName,
    required this.loanAccountNumber,
    required this.bankBranchName,
    required this.noOfBankDocument,
    required this.bankStatusClosedActive,
    required this.address,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
  });

  factory BookingLoanDetailsModel.fromJson(Map<String, dynamic> json) =>
      BookingLoanDetailsModel(
        bookingLoanDetailsId: parseValue<int>(json, "BookingLoanDetailsId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        bookingId: parseValue<int>(json, "BookingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        loanSanctionAmount: parseValue<double>(json, "LoanSanctionAmount"),
        loanSanctionDate:
            json["LoanSanctionDate"] == null
                ? null
                : parseValue<DateTime>(json, "LoanSanctionDate"),
        bankListMasterId: parseValue<int>(json, "BankListMasterId"),
        bankName: parseValue<String>(json, "BankName"),
        loanAccountNumber: parseValue<String>(json, "LoanAccountNumber"),
        bankBranchName: parseValue<String>(json, "BankBranchName"),
        address: parseValue<String>(json, "Address"),
        noOfBankDocument: parseValue<int>(json, "NoOfBankDocument"),
        bankStatusClosedActive: parseValue<String>(
          json,
          "BankStatusClosedActive",
        ),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "BookingLoanDetailsId": bookingLoanDetailsId,
    "Uniquekey": uniquekey,
    "BookingId": bookingId,
    "ProjectId": projectId,
    "LoanSanctionAmount": loanSanctionAmount,
    "LoanSanctionDate": loanSanctionDate?.toIso8601String(),
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "LoanAccountNumber": loanAccountNumber,
    "BankBranchName": bankBranchName,
    "Address": address,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
