import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TermSheetViewModel {
  int termSheetId;
  String uniquekey;
  int projectId;
  String projectName;
  int companyId;
  String companyName;
  DateTime? closingDate;
  String closingRemark;
  bool isClosed;
  List<TermSheetDetailsView> termSheetDetailsData;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TermSheetViewModel({
    required this.termSheetId,
    required this.uniquekey,
    required this.projectId,
    required this.projectName,
    required this.companyId,
    required this.companyName,
    required this.closingDate,
    required this.closingRemark,
    required this.isClosed,
    required this.termSheetDetailsData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TermSheetViewModel.fromJson(Map<String, dynamic> json) =>
      TermSheetViewModel(
        termSheetId: parseValue<int>(json, "TermSheetId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        projectName: parseValue<String>(json, "ProjectName"),
        companyId: parseValue<int>(json, "CompanyId"),
        companyName: parseValue<String>(json, "CompanyName"),
        closingDate:
            json["ClosingDate"] == null
                ? null
                : DateTime.parse(json["ClosingDate"]),
        closingRemark: parseValue<String>(json, "ClosingRemark"),
        isClosed: parseValue<bool>(json, "IsClosed"),
        termSheetDetailsData: List<TermSheetDetailsView>.from(
          json["TermSheetDetailsData"].map(
            (x) => TermSheetDetailsView.fromJson(x),
          ),
        ),
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
    "ClosingDate": closingDate?.toIso8601String(),
    "ClosingRemark": closingRemark,
    "IsClosed": isClosed,
    "TermSheetDetailsData": List<dynamic>.from(
      termSheetDetailsData.map((x) => x.toJson()),
    ),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class TermSheetDetailsView {
  int termSheetDetailsId;
  String uniquekey;
  int termSheetId;
  int projectId;
  int companyId;
  String companyName;
  String loanTakenBy;
  String nameOfInstitutionBankNbfc;
  String type;
  DateTime? termSheetDate;
  DateTime? sanctionDate;
  double facilityAmount;
  double rateOfInterestInPercentage;
  double processingFeesInPercentage;
  double legalAndDocumentationFees;
  int monotoriumPeriodInMonth;
  int loanTenureInMonth;
  double minimumSellingPrice;
  String otherImportantTermsIfAny;
  String remark;
  DateTime? loanStartDate;
  DateTime? loanEndDate;
  double emiAmount;
  String termSheetUrl;
  List<TermSheetDisbursedAmountDetailsData> termSheetDisbursedAmountDetailsData;
  List<TermSheetSweepRatioDetailsData> termSheetSweepRatioDetailsData;
  List<TermSheetDirectSellingAgentData> termSheetDirectSellingAgentData;
  List<TermSheetRepayLedgerData> termSheetRepayLedgerData;
  List<TermSheetDebtServiceReserveAccountData>
  termSheetDebtServiceReserveAccountData;
  double totalDisbursedAmount;
  double totalRepayLedgerAmount;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  bool isApproval;
  String approvalStatus;

  TermSheetDetailsView({
    required this.termSheetDetailsId,
    required this.uniquekey,
    required this.termSheetId,
    required this.projectId,
    required this.companyId,
    required this.companyName,
    required this.loanTakenBy,
    required this.nameOfInstitutionBankNbfc,
    required this.type,
    required this.termSheetDate,
    required this.sanctionDate,
    required this.facilityAmount,
    required this.rateOfInterestInPercentage,
    required this.processingFeesInPercentage,
    required this.legalAndDocumentationFees,
    required this.monotoriumPeriodInMonth,
    required this.loanTenureInMonth,
    required this.minimumSellingPrice,
    required this.otherImportantTermsIfAny,
    required this.remark,
    required this.loanStartDate,
    required this.loanEndDate,
    required this.emiAmount,
    required this.termSheetUrl,
    required this.termSheetDisbursedAmountDetailsData,
    required this.termSheetSweepRatioDetailsData,
    required this.termSheetDirectSellingAgentData,
    required this.termSheetRepayLedgerData,
    required this.termSheetDebtServiceReserveAccountData,
    required this.totalDisbursedAmount,
    required this.totalRepayLedgerAmount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.isApproval,
    required this.approvalStatus,
  });

  factory TermSheetDetailsView.fromJson(
    Map<String, dynamic> json,
  ) => TermSheetDetailsView(
    termSheetDetailsId: parseValue<int>(json, "TermSheetDetailsId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    termSheetId: parseValue<int>(json, "TermSheetId"),
    projectId: parseValue<int>(json, "ProjectId"),
    companyId: parseValue<int>(json, "CompanyId"),
    companyName: parseValue<String>(json, "CompanyName"),
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
    legalAndDocumentationFees: parseValue<double>(
      json,
      "LegalAndDocumentationFees",
    ),
    monotoriumPeriodInMonth: parseValue<int>(json, "MonotoriumPeriodInMonth"),
    loanTenureInMonth: parseValue<int>(json, "LoanTenureInMonth"),
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
    termSheetDisbursedAmountDetailsData:
        (json["TermSheetDisbursedAmountDetailsData"] as List? ?? [])
            .map(
              (item) => TermSheetDisbursedAmountDetailsData.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
    termSheetSweepRatioDetailsData:
        (json["TermSheetSweepRatioDetailsData"] as List? ?? [])
            .map(
              (item) => TermSheetSweepRatioDetailsData.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
    termSheetDirectSellingAgentData:
        (json["TermSheetDirectSellingAgentData"] as List? ?? [])
            .map(
              (item) => TermSheetDirectSellingAgentData.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),

    termSheetRepayLedgerData:
        (json["TermSheetRepayLedgerData"] as List? ?? [])
            .map(
              (item) => TermSheetRepayLedgerData.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),

    termSheetDebtServiceReserveAccountData:
        (json["TermSheetDebtServiceReserveAccountData"] as List? ?? [])
            .map(
              (item) => TermSheetDebtServiceReserveAccountData.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),

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
    isApproval: parseValue<bool>(json, "IsApproval"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
  );

  Map<String, dynamic> toJson() => {
    "TermSheetDetailsId": termSheetDetailsId,
    "Uniquekey": uniquekey,
    "TermSheetId": termSheetId,
    "ProjectId": projectId,
    "CompanyId": companyId,
    "CompanyName": companyName,
    "LoanTakenBy": loanTakenBy,
    "NameOfInstitutionBankNBFC": nameOfInstitutionBankNbfc,
    "Type": type,
    "TermSheetDate": termSheetDate?.toIso8601String(),
    "SanctionDate": sanctionDate?.toIso8601String(),
    "FacilityAmount": facilityAmount,
    "RateOfInterestInPercentage": rateOfInterestInPercentage,
    "ProcessingFeesInPercentage": processingFeesInPercentage,
    "LegalAndDocumentationFees": legalAndDocumentationFees,
    "MonotoriumPeriodInMonth": monotoriumPeriodInMonth,
    "LoanTenureInMonth": loanTenureInMonth,
    "MinimumSellingPrice": minimumSellingPrice,
    "OtherImportantTermsIfAny": otherImportantTermsIfAny,
    "Remark": remark,
    "LoanStartDate": loanStartDate?.toIso8601String(),
    "LoanEndDate": loanEndDate,
    "EMIAmount": emiAmount,
    "TermSheetURL": termSheetUrl,
    "TermSheetDisbursedAmountDetailsData": List<dynamic>.from(
      termSheetDisbursedAmountDetailsData.map((x) => x),
    ),
    "TermSheetSweepRatioDetailsData": List<dynamic>.from(
      termSheetSweepRatioDetailsData.map((x) => x),
    ),
    "TermSheetDirectSellingAgentData": List<dynamic>.from(
      termSheetDirectSellingAgentData.map((x) => x),
    ),
    "TermSheetRepayLedgerData": List<dynamic>.from(
      termSheetRepayLedgerData.map((x) => x),
    ),
    "TermSheetDebtServiceReserveAccountData": List<dynamic>.from(
      termSheetDebtServiceReserveAccountData.map((x) => x),
    ),
    "TotalDisbursedAmount": totalDisbursedAmount,
    "TotalRepayLedgerAmount": totalRepayLedgerAmount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "IsApproval": isApproval,
    "ApprovalStatus": approvalStatus,
  };
}

class TermSheetDisbursedAmountDetailsData {
  int termSheetDisbursedAmountDetailsId;
  String uniquekey;
  int termSheetId;
  int termSheetDetailsId;
  int projectId;
  double disbursedAmount;
  DateTime? disbursedDate;
  String remark;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  TermSheetDisbursedAmountDetailsData({
    required this.termSheetDisbursedAmountDetailsId,
    required this.uniquekey,
    required this.termSheetId,
    required this.termSheetDetailsId,
    required this.projectId,
    required this.disbursedAmount,
    required this.disbursedDate,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });
  factory TermSheetDisbursedAmountDetailsData.fromJson(
    Map<String, dynamic> json,
  ) => TermSheetDisbursedAmountDetailsData(
    termSheetDisbursedAmountDetailsId: parseValue<int>(
      json,
      "TermSheetDisbursedAmountDetailsId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    termSheetId: parseValue<int>(json, "TermSheetId"),
    termSheetDetailsId: parseValue<int>(json, "TermSheetDetailsId"),
    projectId: parseValue<int>(json, "ProjectId"),
    disbursedAmount: parseValue<double>(json, "DisbursedAmount"),
    disbursedDate:
        json["DisbursedDate"] == null
            ? null
            : DateTime.parse(json["DisbursedDate"]),
    remark: parseValue<String>(json, "Remark"),
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
    "TermSheetDisbursedAmountDetailsId": termSheetDisbursedAmountDetailsId,
    "Uniquekey": uniquekey,
    "TermSheetId": termSheetId,
    "TermSheetDetailsId": termSheetDetailsId,
    "ProjectId": projectId,
    "DisbursedAmount": disbursedAmount,
    "DisbursedDate": disbursedDate?.toIso8601String(),
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class TermSheetSweepRatioDetailsData {
  int termSheetSweepRatioDetailsId;
  String uniquekey;
  int termSheetId;
  int termSheetDetailsId;
  int projectId;
  double ownSweepRatioInPercentage;
  double lenderSweepRatioInPercentage;
  DateTime? date;
  String remark;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  TermSheetSweepRatioDetailsData({
    required this.termSheetSweepRatioDetailsId,
    required this.uniquekey,
    required this.termSheetId,
    required this.termSheetDetailsId,
    required this.projectId,
    required this.ownSweepRatioInPercentage,
    required this.lenderSweepRatioInPercentage,
    required this.date,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TermSheetSweepRatioDetailsData.fromJson(Map<String, dynamic> json) =>
      TermSheetSweepRatioDetailsData(
        termSheetSweepRatioDetailsId: parseValue<int>(
          json,
          "TermSheetSweepRatioDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        termSheetId: parseValue<int>(json, "TermSheetId"),
        termSheetDetailsId: parseValue<int>(json, "TermSheetDetailsId"),
        projectId: parseValue<int>(json, "ProjectId"),
        ownSweepRatioInPercentage: parseValue<double>(
          json,
          "OwnSweepRatioInPercentage",
        ),
        lenderSweepRatioInPercentage: parseValue<double>(
          json,
          "LenderSweepRatioInPercentage",
        ),
        date: json["Date"] == null ? null : DateTime.parse(json["Date"]),
        remark: parseValue<String>(json, "Remark"),
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
    "TermSheetSweepRatioDetailsId": termSheetSweepRatioDetailsId,
    "Uniquekey": uniquekey,
    "TermSheetId": termSheetId,
    "TermSheetDetailsId": termSheetDetailsId,
    "ProjectId": projectId,
    "OwnSweepRatioInPercentage": ownSweepRatioInPercentage,
    "LenderSweepRatioInPercentage": lenderSweepRatioInPercentage,
    "Date": date?.toIso8601String(),
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class TermSheetDirectSellingAgentData {
  int termSheetDirectSellingAgentId;
  String uniquekey;
  int termSheetId;
  int termSheetDetailsId;
  int projectId;
  double amount;
  String nameOfConsultant;
  double commissionInPercentage;
  DateTime? paymentDate;
  String remark;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  TermSheetDirectSellingAgentData({
    required this.termSheetDirectSellingAgentId,
    required this.uniquekey,
    required this.termSheetId,
    required this.termSheetDetailsId,
    required this.projectId,
    required this.amount,
    required this.nameOfConsultant,
    required this.commissionInPercentage,
    required this.paymentDate,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });
  factory TermSheetDirectSellingAgentData.fromJson(Map<String, dynamic> json) =>
      TermSheetDirectSellingAgentData(
        termSheetDirectSellingAgentId: parseValue<int>(
          json,
          "TermSheetDirectSellingAgentId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        termSheetId: parseValue<int>(json, "TermSheetId"),
        termSheetDetailsId: parseValue<int>(json, "TermSheetDetailsId"),
        projectId: parseValue<int>(json, "ProjectId"),
        amount: parseValue<double>(json, "Amount"),
        nameOfConsultant: parseValue<String>(json, "NameOfConsultant"),
        commissionInPercentage: parseValue<double>(
          json,
          "CommissionInPercentage",
        ),
        paymentDate:
            json["PaymentDate"] == null
                ? null
                : DateTime.parse(json["PaymentDate"]),
        remark: parseValue<String>(json, "Remark"),
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
    "TermSheetDirectSellingAgentId": termSheetDirectSellingAgentId,
    "Uniquekey": uniquekey,
    "TermSheetId": termSheetId,
    "TermSheetDetailsId": termSheetDetailsId,
    "ProjectId": projectId,
    "Amount": amount,
    "NameOfConsultant": nameOfConsultant,
    "CommissionInPercentage": commissionInPercentage,
    "PaymentDate": paymentDate?.toIso8601String(),
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class TermSheetRepayLedgerData {
  int termSheetRepayLedgerId;
  String uniquekey;
  int termSheetId;
  int termSheetDetailsId;
  int projectId;
  double amount;
  DateTime? paymentDate;
  String remark;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TermSheetRepayLedgerData({
    required this.termSheetRepayLedgerId,
    required this.uniquekey,
    required this.termSheetId,
    required this.termSheetDetailsId,
    required this.projectId,
    required this.amount,
    required this.paymentDate,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });
  factory TermSheetRepayLedgerData.fromJson(Map<String, dynamic> json) =>
      TermSheetRepayLedgerData(
        termSheetRepayLedgerId: parseValue<int>(json, "TermSheetRepayLedgerId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        termSheetId: parseValue<int>(json, "TermSheetId"),
        termSheetDetailsId: parseValue<int>(json, "TermSheetDetailsId"),
        projectId: parseValue<int>(json, "ProjectId"),
        amount: parseValue<double>(json, "Amount"),
        paymentDate:
            json["PaymentDate"] == null
                ? null
                : DateTime.parse(json["PaymentDate"]),
        remark: parseValue<String>(json, "Remark"),
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
    "TermSheetRepayLedgerId": termSheetRepayLedgerId,
    "Uniquekey": uniquekey,
    "TermSheetId": termSheetId,
    "TermSheetDetailsId": termSheetDetailsId,
    "ProjectId": projectId,
    "Amount": amount,
    "PaymentDate": paymentDate?.toIso8601String(),
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class TermSheetDebtServiceReserveAccountData {
  int termSheetDebtServiceReserveAccountId;
  String uniquekey;
  int termSheetId;
  int termSheetDetailsId;
  int projectId;
  String term;
  double unit;
  double perUnitRate;
  double amount;
  DateTime? date;
  double rateOfInterestInPercentage;
  double redemptionValue;
  double maturityPeriod;
  double withdrawAmount;
  dynamic withdrawDate;
  String remark;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TermSheetDebtServiceReserveAccountData({
    required this.termSheetDebtServiceReserveAccountId,
    required this.uniquekey,
    required this.termSheetId,
    required this.termSheetDetailsId,
    required this.projectId,
    required this.term,
    required this.unit,
    required this.perUnitRate,
    required this.amount,
    required this.date,
    required this.rateOfInterestInPercentage,
    required this.redemptionValue,
    required this.maturityPeriod,
    required this.withdrawAmount,
    required this.withdrawDate,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });
  factory TermSheetDebtServiceReserveAccountData.fromJson(
    Map<String, dynamic> json,
  ) => TermSheetDebtServiceReserveAccountData(
    termSheetDebtServiceReserveAccountId: parseValue(
      json,
      "TermSheetDebtServiceReserveAccountId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    termSheetId: parseValue<int>(json, "TermSheetId"),
    termSheetDetailsId: parseValue<int>(json, "TermSheetDetailsId"),
    projectId: parseValue<int>(json, "ProjectId"),
    term: parseValue<String>(json, "Term"),
    unit: parseValue<double>(json, "Unit"),
    perUnitRate: parseValue<double>(json, "PerUnitRate"),
    amount: parseValue<double>(json, "Amount"),
    date: json["Date"] == null ? null : DateTime.parse(json["Date"]),
    rateOfInterestInPercentage: parseValue<double>(
      json,
      "RateOfInterestInPercentage",
    ),
    redemptionValue: parseValue<double>(json, "RedemptionValue"),
    maturityPeriod: parseValue<double>(json, "MaturityPeriod"),
    withdrawAmount: parseValue<double>(json, "WithdrawAmount"),
    withdrawDate:
        json["WithdrawDate"] == null
            ? null
            : DateTime.parse(json["WithdrawDate"]),
    remark: parseValue<String>(json, "Remark"),
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
    "TermSheetDebtServiceReserveAccountId":
        termSheetDebtServiceReserveAccountId,
    "Uniquekey": uniquekey,
    "TermSheetId": termSheetId,
    "TermSheetDetailsId": termSheetDetailsId,
    "ProjectId": projectId,
    "Term": term,
    "Unit": unit,
    "PerUnitRate": perUnitRate,
    "Amount": amount,
    "Date": date?.toIso8601String(),
    "RateOfInterestInPercentage": rateOfInterestInPercentage,
    "RedemptionValue": redemptionValue,
    "MaturityPeriod": maturityPeriod,
    "WithdrawAmount": withdrawAmount,
    "WithdrawDate": withdrawDate?.toIso8601String(),
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
