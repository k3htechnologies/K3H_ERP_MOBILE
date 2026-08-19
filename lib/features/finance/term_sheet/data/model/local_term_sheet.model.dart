import 'package:k3h_erp_app/core/models/file_picker.model.dart';

class LocalTermSheetModel {
  final String nameOfInstitutionBankNBFC;
  final String loanTakenBy;
  final String loanStartDate;
  final String loanEndDate;
  final String loanTenureInMonth;
  final String rateOfInterestInPercentage;
  final String remark;
  final String termSheetDate;
  final String sanctionDate;
  final String minimumSellingPrice;
  final String legalAndDocumentationFees;
  final String monotoriumPeriodInMonth;
  final String emiAmount;
  final String otherImportantTermsIfAny;
  final String type;
  final String facilityAmount;
  final String processingFeesInPercentage;

  final List<String> termSheetURL;

  MultiFilePickerModel termSheetFiles = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  LocalTermSheetModel({
    required this.nameOfInstitutionBankNBFC,
    required this.loanTakenBy,
    required this.loanStartDate,
    required this.loanEndDate,
    required this.loanTenureInMonth,
    required this.rateOfInterestInPercentage,
    required this.remark,
    required this.termSheetDate,
    required this.sanctionDate,
    required this.minimumSellingPrice,
    required this.legalAndDocumentationFees,
    required this.monotoriumPeriodInMonth,
    required this.emiAmount,
    required this.otherImportantTermsIfAny,
    required this.type,
    required this.facilityAmount,
    required this.processingFeesInPercentage,
    required this.termSheetURL,
    required this.termSheetFiles,
  });

  Map<String, dynamic> toJson() {
    return {
      "LoanStartDate": loanStartDate,
      "LoanTenureInMonth": loanTenureInMonth,
      "RemoveTermSheetURL": "",
      "RateOfInterestInPercentage": rateOfInterestInPercentage,
      "Remark": remark,
      "TermSheetDate": termSheetDate,
      "NameOfInstitutionBankNBFC": nameOfInstitutionBankNBFC,
      "SanctionDate": sanctionDate,
      "MinimumSellingPrice": minimumSellingPrice,
      "LegalAndDocumentationFees": legalAndDocumentationFees,
      "TermSheetDetailsId": 0,
      "MonotoriumPeriodInMonth": monotoriumPeriodInMonth,
      "LoanTakenBy": loanTakenBy,
      "TermSheetId": 0,
      "Uniquekey": "",
      "ProjectId": 0,
      "EMIAmount": emiAmount,
      "LoanEndDate": loanEndDate,
      "OtherImportantTermsIfAny": otherImportantTermsIfAny,
      "Type": type,
      "FacilityAmount": facilityAmount,
      "TermSheetURL": termSheetURL,
      "ProcessingFeesInPercentage": processingFeesInPercentage,
    };
  }
}
