import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';

class LocalTermSheetModel {
  final String nameOfInstitutionBankNBFC;
  final String loanTakenBy;
  final DateTime? loanStartDate;
  final DateTime? loanEndDate;
  final String loanTenureInMonth;
  final String rateOfInterestInPercentage;
  final String remark;
  final DateTime? termSheetDate;
  final DateTime? sanctionDate;
  final String minimumSellingPrice;
  final String legalAndDocumentationFees;
  final String monotoriumPeriodInMonth;
  final String emiAmount;
  final String otherImportantTermsIfAny;
  final String type;
  final double facilityAmount;
  final String processingFeesInPercentage;

  final List<String> termSheetURL;

  final MultiFilePickerModel termSheetFiles;

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

  factory LocalTermSheetModel.fromTermSheetModel(TermSheetModel model) {
    return LocalTermSheetModel(
      nameOfInstitutionBankNBFC: model.nameOfInstitutionBankNbfc,
      loanTakenBy: model.loanTakenBy,

      loanStartDate: model.loanStartDate,

      loanEndDate: model.loanEndDate,

      loanTenureInMonth: model.loanTenureInMonth.toString(),

      rateOfInterestInPercentage: model.rateOfInterestInPercentage.toString(),

      remark: model.remark,

      termSheetDate: model.termSheetDate,

      sanctionDate: model.sanctionDate,

      minimumSellingPrice: model.minimumSellingPrice.toString(),

      legalAndDocumentationFees: model.legalAndDoumentationFees.toString(),

      monotoriumPeriodInMonth: model.monotoriumPeriodInMonth.toString(),

      emiAmount: model.emiAmount.toString(),

      otherImportantTermsIfAny: model.otherImportantTermsIfAny,

      type: model.type,

      facilityAmount: model.facilityAmount,

      processingFeesInPercentage: model.processingFeesInPercentage.toString(),

      termSheetURL: model.termSheetUrl.isNotEmpty ? [model.termSheetUrl] : [],

      termSheetFiles: MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: model.termSheetUrl.isNotEmpty ? [model.termSheetUrl] : [],
        deletedFileList: "",
      ),
    );
  }

  factory LocalTermSheetModel.fromTermSheetViewModel(
    TermSheetDetailsView model,
  ) {
    return LocalTermSheetModel(
      nameOfInstitutionBankNBFC: model.nameOfInstitutionBankNbfc,
      loanTakenBy: model.loanTakenBy,

      loanStartDate: model.loanStartDate,
      loanEndDate: model.loanEndDate,

      loanTenureInMonth: model.loanTenureInMonth.toString(),

      rateOfInterestInPercentage: model.rateOfInterestInPercentage.toString(),

      remark: model.remark,

      termSheetDate: model.termSheetDate,

      sanctionDate: model.sanctionDate,

      minimumSellingPrice: model.minimumSellingPrice.toString(),

      legalAndDocumentationFees: model.legalAndDocumentationFees.toString(),

      monotoriumPeriodInMonth: model.monotoriumPeriodInMonth.toString(),

      emiAmount: model.emiAmount.toString(),

      otherImportantTermsIfAny: model.otherImportantTermsIfAny,

      type: model.type,

      facilityAmount: model.facilityAmount,

      processingFeesInPercentage: model.processingFeesInPercentage.toString(),

      termSheetURL: model.termSheetUrl.isNotEmpty ? [model.termSheetUrl] : [],

      termSheetFiles: MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: model.termSheetUrl.isNotEmpty ? [model.termSheetUrl] : [],
        deletedFileList: "",
      ),
    );
  }
  LocalTermSheetModel copyWith({
    String? nameOfInstitutionBankNBFC,
    String? loanTakenBy,
    DateTime? loanStartDate,
    DateTime? loanEndDate,
    String? loanTenureInMonth,
    String? rateOfInterestInPercentage,
    String? remark,
    DateTime? termSheetDate,
    DateTime? sanctionDate,
    String? minimumSellingPrice,
    String? legalAndDocumentationFees,
    String? monotoriumPeriodInMonth,
    String? emiAmount,
    String? otherImportantTermsIfAny,
    String? type,
    double? facilityAmount,
    String? processingFeesInPercentage,
    List<String>? termSheetURL,
    MultiFilePickerModel? termSheetFiles,
  }) {
    return LocalTermSheetModel(
      nameOfInstitutionBankNBFC:
          nameOfInstitutionBankNBFC ?? this.nameOfInstitutionBankNBFC,
      loanTakenBy: loanTakenBy ?? this.loanTakenBy,
      loanStartDate: loanStartDate ?? this.loanStartDate,
      loanEndDate: loanEndDate ?? this.loanEndDate,
      loanTenureInMonth: loanTenureInMonth ?? this.loanTenureInMonth,
      rateOfInterestInPercentage:
          rateOfInterestInPercentage ?? this.rateOfInterestInPercentage,
      remark: remark ?? this.remark,
      termSheetDate: termSheetDate ?? this.termSheetDate,
      sanctionDate: sanctionDate ?? this.sanctionDate,
      minimumSellingPrice: minimumSellingPrice ?? this.minimumSellingPrice,
      legalAndDocumentationFees:
          legalAndDocumentationFees ?? this.legalAndDocumentationFees,
      monotoriumPeriodInMonth:
          monotoriumPeriodInMonth ?? this.monotoriumPeriodInMonth,
      emiAmount: emiAmount ?? this.emiAmount,
      otherImportantTermsIfAny:
          otherImportantTermsIfAny ?? this.otherImportantTermsIfAny,
      type: type ?? this.type,
      facilityAmount: facilityAmount ?? this.facilityAmount,
      processingFeesInPercentage:
          processingFeesInPercentage ?? this.processingFeesInPercentage,
      termSheetURL: termSheetURL ?? this.termSheetURL,
      termSheetFiles: termSheetFiles ?? this.termSheetFiles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "LoanStartDate": loanStartDate?.toIso8601String(),
      "LoanTenureInMonth": loanTenureInMonth,
      "RemoveTermSheetURL": "",
      "RateOfInterestInPercentage": rateOfInterestInPercentage,
      "Remark": remark,
      "TermSheetDate": termSheetDate?.toIso8601String(),
      "NameOfInstitutionBankNBFC": nameOfInstitutionBankNBFC,
      "SanctionDate": sanctionDate?.toIso8601String(),
      "MinimumSellingPrice": minimumSellingPrice,
      "LegalAndDocumentationFees": legalAndDocumentationFees,
      "TermSheetDetailsId": 0,
      "MonotoriumPeriodInMonth": monotoriumPeriodInMonth,
      "LoanTakenBy": loanTakenBy,
      "TermSheetId": 0,
      "Uniquekey": "",
      "ProjectId": 0,
      "EMIAmount": emiAmount,
      "LoanEndDate": loanEndDate?.toIso8601String(),
      "OtherImportantTermsIfAny": otherImportantTermsIfAny,
      "Type": type,
      "FacilityAmount": facilityAmount,
      "TermSheetURL": termSheetURL,
      "ProcessingFeesInPercentage": processingFeesInPercentage,
    };
  }
}
