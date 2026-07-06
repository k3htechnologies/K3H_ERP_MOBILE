import 'package:k3h_erp_app/core/models/bank_details.model.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProjectModel {
  int projectId;
  String uniquekey;
  String projectName;
  String projectLocation;
  String projectPhotoUrl;
  String companyId;
  String ctsNumber;
  String employeeId;
  int numberOfEmployee;
  bool isRedevelopment;
  String bussinessCategory;
  String fileNumber;
  String liasoningArchitectName;
  String liasoningArchitectMobileNumber;
  String designingArchitectName;
  String designingArchitectMobileNumber;
  String rccConsultantName;
  String rccConsultantMobileNumber;
  String category;
  double tenderAmount;
  double tenderEmdAmount;
  DateTime? tenderPurchaseStartDate;
  DateTime? tenderPurchaseEndDate;
  String? tenderChequeNumber;
  String? tenderChequeNumberUrl;
  DateTime? tenderSubmissionDate;
  DateTime? tenderIssueDate;
  String? tenderPayorderRemark;
  String projectShortName;
  int countryMasterId;
  String countryName;
  int districtMasterId;
  String districtName;
  int stateMasterId;
  String stateName;
  int cityMasterId;
  String cityName;
  int villageMasterId;
  String villageName;
  String zipCode;
  String projectScope;
  double projectEstimateCost;
  String projectAreaInSqft;
  String? projectAreaInSqmt;
  String onGoingBudgetCost;
  DateTime? surveyDate;
  DateTime? expectedStartDate;
  DateTime? executionStartDate;
  String siteContactMobileNumber;
  String siteContactName;
  String projectStatus;
  String? apfNumber;
  String reraNumber;
  DateTime? reraCertificateDate;
  DateTime? reraComplitionDate;
  String projectScheme;
  String projectSubScheme;
  String googleLocation;
  int notificationCount;
  int clientRegistrationId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  List<CompanyModel>? companyData;
  List<BankDetailsModel>? projectWithBankDetailsData;
  List<UserModel>? employeeData;

  ProjectModel({
    required this.projectId,
    required this.uniquekey,
    required this.projectName,
    required this.projectLocation,
    required this.projectPhotoUrl,
    required this.companyId,
    required this.ctsNumber,
    required this.employeeId,
    required this.numberOfEmployee,
    required this.isRedevelopment,
    required this.bussinessCategory,
    required this.fileNumber,
    required this.liasoningArchitectName,
    required this.liasoningArchitectMobileNumber,
    required this.designingArchitectName,
    required this.designingArchitectMobileNumber,
    required this.rccConsultantName,
    required this.rccConsultantMobileNumber,
    required this.category,
    required this.tenderAmount,
    required this.tenderEmdAmount,
    this.tenderPurchaseStartDate,
    this.tenderPurchaseEndDate,
    this.tenderChequeNumber,
    this.tenderChequeNumberUrl,
    this.tenderSubmissionDate,
    this.tenderIssueDate,
    this.tenderPayorderRemark,
    required this.projectShortName,
    required this.countryMasterId,
    required this.countryName,
    required this.districtMasterId,
    required this.districtName,
    required this.stateMasterId,
    required this.stateName,
    required this.cityMasterId,
    required this.cityName,
    required this.villageMasterId,
    required this.villageName,
    required this.zipCode,
    required this.projectScope,
    required this.projectEstimateCost,
    required this.projectAreaInSqft,
    this.projectAreaInSqmt,
    required this.onGoingBudgetCost,
    this.surveyDate,
    this.expectedStartDate,
    this.executionStartDate,
    required this.siteContactMobileNumber,
    required this.siteContactName,
    required this.projectStatus,
    this.apfNumber,
    required this.reraNumber,
    this.reraCertificateDate,
    this.reraComplitionDate,
    required this.projectScheme,
    required this.projectSubScheme,
    required this.googleLocation,
    required this.notificationCount,
    required this.clientRegistrationId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
    this.companyData,
    this.projectWithBankDetailsData,
    this.employeeData,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    projectId: parseValue<int>(json, "ProjectId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectName: parseValue<String>(json, "ProjectName"),
    projectLocation: parseValue<String>(json, "ProjectLocation"),
    projectPhotoUrl: parseValue<String>(json, "ProjectPhotoURL"),
    companyId: parseValue<String>(json, "CompanyId"),
    ctsNumber: parseValue<String>(json, "CTSNumber"),
    employeeId: parseValue<String>(json, "EmployeeId"),
    numberOfEmployee: parseValue<int>(json, "NumberOfEmployee"),
    isRedevelopment: parseValue<bool>(json, "IsRedevelopment"),
    bussinessCategory: parseValue<String>(json, "BussinessCategory"),
    fileNumber: parseValue<String>(json, "FileNumber"),
    liasoningArchitectName: parseValue<String>(json, "LiasoningArchitectName"),
    liasoningArchitectMobileNumber: parseValue<String>(
      json,
      "LiasoningArchitectMobileNumber",
    ),
    designingArchitectName: parseValue<String>(json, "DesigningArchitectName"),
    designingArchitectMobileNumber: parseValue<String>(
      json,
      "DesigningArchitectMobileNumber",
    ),
    rccConsultantName: parseValue<String>(json, "RCCConsultantName"),
    rccConsultantMobileNumber: parseValue<String>(
      json,
      "RCCConsultantMobileNumber",
    ),
    category: parseValue<String>(json, "Category"),
    tenderAmount: parseValue<double>(json, "TenderAmount"),
    tenderEmdAmount: parseValue<double>(json, "TenderEMDAmount"),
    tenderPurchaseStartDate:
        json["TenderPurchaseStartDate"] != null
            ? DateTime.parse(json["TenderPurchaseStartDate"])
            : null,
    tenderPurchaseEndDate:
        json["TenderPurchaseEndDate"] != null
            ? DateTime.parse(json["TenderPurchaseEndDate"])
            : null,
    tenderChequeNumber: parseValue<String>(json, "TenderChequeNumber"),
    tenderChequeNumberUrl: parseValue<String>(json, "TenderChequeNumberURL"),
    tenderSubmissionDate:
        json["TenderSubmissionDate"] != null
            ? DateTime.parse(json["TenderSubmissionDate"])
            : null,
    tenderIssueDate:
        json["TenderIssueDate"] != null
            ? DateTime.parse(json["TenderIssueDate"])
            : null,
    tenderPayorderRemark: parseValue<String>(json, "TenderPayorderRemark"),
    projectShortName: parseValue<String>(json, "ProjectShortName"),
    countryMasterId: parseValue<int>(json, "CountryMasterId"),
    countryName: parseValue<String>(json, "CountryName"),
    districtMasterId: parseValue<int>(json, "DistrictMasterId"),
    districtName: parseValue<String>(json, "DistrictName"),
    stateMasterId: parseValue<int>(json, "StateMasterId"),
    stateName: parseValue<String>(json, "StateName"),
    cityMasterId: parseValue<int>(json, "CityMasterId"),
    cityName: parseValue<String>(json, "CityName"),
    villageMasterId: parseValue<int>(json, "VillageMasterId"),
    villageName: parseValue<String>(json, "VillageName"),
    zipCode: parseValue<String>(json, "ZipCode"),
    projectScope: parseValue<String>(json, "ProjectScope"),
    projectEstimateCost: parseValue<double>(json, "ProjectEstimateCost"),
    projectAreaInSqft: parseValue<String>(json, "ProjectAreaInSqft"),
    projectAreaInSqmt: parseValue<String>(json, "ProjectAreaInSqmt"),
    onGoingBudgetCost: parseValue<String>(json, "OnGoingBudgetCost"),
    surveyDate:
        json["SurveyDate"] != null ? DateTime.parse(json["SurveyDate"]) : null,
    expectedStartDate:
        json["ExpectedStartDate"] != null
            ? DateTime.parse(json["ExpectedStartDate"])
            : null,
    executionStartDate:
        json["ExecutionStartDate"] != null
            ? DateTime.parse(json["ExecutionStartDate"])
            : null,
    siteContactMobileNumber: parseValue<String>(
      json,
      "SiteContactMobileNumber",
    ),
    siteContactName: parseValue<String>(json, "SiteContactName"),
    projectStatus: parseValue<String>(json, "ProjectStatus"),
    apfNumber: parseValue<String>(json, "APFNumber"),
    reraNumber: parseValue<String>(json, "RERANumber"),
    reraCertificateDate:
        json["RERACertificateDate"] != null
            ? DateTime.parse(json["RERACertificateDate"])
            : null,
    reraComplitionDate:
        json["RERAComplitionDate"] != null
            ? DateTime.parse(json["RERAComplitionDate"])
            : null,
    projectScheme: parseValue<String>(json, "ProjectScheme"),
    projectSubScheme: parseValue<String>(json, "ProjectSubScheme"),
    googleLocation: parseValue<String>(json, "GoogleLocation"),
    notificationCount: parseValue<int>(json, "NotificationCount"),
    clientRegistrationId: parseValue<int>(json, "ClientRegistrationId"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: DateTime.parse(json["CreatedDate"]),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] != null
            ? DateTime.parse(json["ModifiedDate"])
            : null,
    companyData:
        json["CompanyData"] != null
            ? (json["CompanyData"] as List<dynamic>)
                .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
    projectWithBankDetailsData:
        json["ProjectWithBankDetailsData"] != null
            ? (json["ProjectWithBankDetailsData"] as List<dynamic>)
                .map(
                  (e) => BankDetailsModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
            : null,
    employeeData:
        json["EmployeeData"] != null
            ? (json["EmployeeData"] as List<dynamic>)
                .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
  );

  Map<String, dynamic> toJson() => {
    "ProjectId": projectId,
    "Uniquekey": uniquekey,
    "ProjectName": projectName,
    "ProjectLocation": projectLocation,
    "ProjectPhotoURL": projectPhotoUrl,
    "CompanyId": companyId,
    "CTSNumber": ctsNumber,
    "EmployeeId": employeeId,
    "NumberOfEmployee": numberOfEmployee,
    "IsRedevelopment": isRedevelopment,
    "BussinessCategory": bussinessCategory,
    "FileNumber": fileNumber,
    "LiasoningArchitectName": liasoningArchitectName,
    "LiasoningArchitectMobileNumber": liasoningArchitectMobileNumber,
    "DesigningArchitectName": designingArchitectName,
    "DesigningArchitectMobileNumber": designingArchitectMobileNumber,
    "RCCConsultantName": rccConsultantName,
    "RCCConsultantMobileNumber": rccConsultantMobileNumber,
    "Category": category,
    "TenderAmount": tenderAmount,
    "TenderEMDAmount": tenderEmdAmount,
    "TenderPurchaseStartDate": tenderPurchaseStartDate?.toIso8601String(),
    "TenderPurchaseEndDate": tenderPurchaseEndDate?.toIso8601String(),
    "TenderChequeNumber": tenderChequeNumber,
    "TenderChequeNumberURL": tenderChequeNumberUrl,
    "TenderSubmissionDate": tenderSubmissionDate?.toIso8601String(),
    "TenderIssueDate": tenderIssueDate?.toIso8601String(),
    "TenderPayorderRemark": tenderPayorderRemark,
    "ProjectShortName": projectShortName,
    "CountryMasterId": countryMasterId,
    "CountryName": countryName,
    "DistrictMasterId": districtMasterId,
    "DistrictName": districtName,
    "StateMasterId": stateMasterId,
    "StateName": stateName,
    "CityMasterId": cityMasterId,
    "CityName": cityName,
    "VillageMasterId": villageMasterId,
    "VillageName": villageName,
    "ZipCode": zipCode,
    "ProjectScope": projectScope,
    "ProjectEstimateCost": projectEstimateCost,
    "ProjectAreaInSqft": projectAreaInSqft,
    "ProjectAreaInSqmt": projectAreaInSqmt,
    "OnGoingBudgetCost": onGoingBudgetCost,
    "SurveyDate": surveyDate?.toIso8601String(),
    "ExpectedStartDate": expectedStartDate?.toIso8601String(),
    "ExecutionStartDate": executionStartDate?.toIso8601String(),
    "SiteContactMobileNumber": siteContactMobileNumber,
    "SiteContactName": siteContactName,
    "ProjectStatus": projectStatus,
    "APFNumber": apfNumber,
    "RERANumber": reraNumber,
    "RERACertificateDate": reraCertificateDate?.toIso8601String(),
    "RERAComplitionDate": reraComplitionDate?.toIso8601String(),
    "ProjectScheme": projectScheme,
    "ProjectSubScheme": projectSubScheme,
    "GoogleLocation": googleLocation,
    "NotificationCount": notificationCount,
    "ClientRegistrationId": clientRegistrationId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "CompanyData": companyData?.map((e) => e.toJson()).toList(),
    "ProjectWithBankDetailsData":
        projectWithBankDetailsData?.map((e) => e.toJson()).toList(),
    "EmployeeData": employeeData?.map((e) => e.toJson()).toList(),
  };
}
