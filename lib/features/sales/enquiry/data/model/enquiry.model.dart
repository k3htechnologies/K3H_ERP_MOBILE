import 'package:k3h_erp_app/utils/common_function.dart';

class EnquiryModel {
  EnquiryModel({
    required this.enquiryId,
    required this.uniquekey,
    required this.projectId,
    required this.enquiryTimeIn,
    required this.enquiryTimeOut,
    required this.name,
    required this.mobileNumber,
    required this.emailId,
    required this.dateOfBirth,
    required this.age,
    required this.accommodation,
    required this.occupationType,
    required this.nationality,
    required this.countryOfResidence,
    required this.cityOfResidence,
    required this.currentLocation,
    required this.possessionType,
    required this.areaPreferred,
    required this.desiredFloorBand,
    required this.budget,
    required this.requirement,
    required this.requirementType,
    required this.customerClassification,
    required this.source,
    required this.subSource,
    required this.subSubSource,
    required this.sourceOfFunding,
    required this.ethnicity,
    required this.timeline,
    required this.finalStage,
    required this.finalStageDetail,
    required this.enquiryDate,
    required this.nextFollowUpDate,
    required this.salesAdvisor,
    required this.sourcingManager,
    required this.salesAdvisorId,
    required this.sourcingManagerId,
    required this.channelPartnerTeamMemberId,
    required this.channelPartnerTeamMemberName,
    required this.channelPartnerTeamMemberMobileNumber,
    required this.channelPartnerMobileNumber,
    required this.systemGeneratedCode,
    required this.channelPartnerName,
    required this.villageName,
    required this.referelName,
    required this.referelMobileNumber,
    required this.referelProjectName,
    required this.referelUnitNumber,
    required this.loyaltyExistingProjectName,
    required this.loyaltyExistingUnitNumber,
    required this.employeeReferenceName,
    required this.employeeReferenceMobileNumber,
    required this.remark,
    required this.villageMasterId,

    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  int enquiryId;
  String uniquekey;
  int projectId;
  String enquiryTimeIn;
  String enquiryTimeOut;
  String name;
  String mobileNumber;
  String emailId;
  String systemGeneratedCode;

  DateTime? dateOfBirth;
  int age;
  String channelPartnerMobileNumber;

  String accommodation;
  String occupationType;
  String nationality;
  String countryOfResidence;
  String cityOfResidence;
  String currentLocation;
  String possessionType;
  int areaPreferred;
  String desiredFloorBand;
  String budget;
  String requirement;
  String requirementType;
  String customerClassification;
  String source;
  String subSource;
  String subSubSource;
  String sourceOfFunding;
  String ethnicity;
  String timeline;
  String finalStage;
  String finalStageDetail;
  DateTime? enquiryDate;
  DateTime? nextFollowUpDate;

  /// NAMES
  String salesAdvisor;
  String sourcingManager;

  /// IDS
  int salesAdvisorId;
  int sourcingManagerId;
  int channelPartnerTeamMemberId;

  /// CHANNEL PARTNER
  String channelPartnerTeamMemberName;
  String channelPartnerTeamMemberMobileNumber;
  String channelPartnerName;
  String villageName;

  /// REFERRAL
  String referelName;
  String referelMobileNumber;
  String referelProjectName;
  String referelUnitNumber;

  /// LOYALTY
  String loyaltyExistingProjectName;
  String loyaltyExistingUnitNumber;

  /// EMPLOYEE REF
  String employeeReferenceName;
  String employeeReferenceMobileNumber;

  /// OTHER
  String remark;
  dynamic villageMasterId;

  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    return EnquiryModel(
      enquiryId: parseValue<int>(json, "EnquiryId"),
      uniquekey: parseValue<String>(json, "Uniquekey"),
      systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
      projectId: parseValue<int>(json, "ProjectId"),
      enquiryTimeIn: parseValue<String>(json, "EnquiryTimeIn"),
      enquiryTimeOut: parseValue<String>(json, "EnquiryTimeOut"),
      name: parseValue<String>(json, "Name"),
      mobileNumber: parseValue<String>(json, "MobileNumber"),
      emailId: parseValue<String>(json, "EmailId"),
      dateOfBirth: parseValue<DateTime>(json, "DateOfBirth"),
      age: parseValue<int>(json, "Age"),
      accommodation: parseValue<String>(json, "Accommodation"),
      occupationType: parseValue<String>(json, "OccupationType"),
      nationality: parseValue<String>(json, "Nationality"),
      countryOfResidence: parseValue<String>(json, "CountryOfResidence"),
      cityOfResidence: parseValue<String>(json, "CityOfResidence"),
      currentLocation: parseValue<String>(json, "CurrentLocation"),
      possessionType: parseValue<String>(json, "PossessionType"),
      areaPreferred: parseValue<int>(json, "AreaPreferred"),
      desiredFloorBand: parseValue<String>(json, "DesiredFloorBand"),
      budget: parseValue<String>(json, "Budget"),
      requirement: parseValue<String>(json, "Requirement"),
      requirementType: parseValue<String>(json, "RequirementType"),
      customerClassification: parseValue<String>(
        json,
        "CustomerClassification",
      ),
      source: parseValue<String>(json, "Source"),
      subSource: parseValue<String>(json, "SubSource"),
      subSubSource: parseValue<String>(json, "SubSubSource"),
      sourceOfFunding: parseValue<String>(json, "SourceOfFunding"),
      ethnicity: parseValue<String>(json, "Ethnicity"),
      timeline: parseValue<String>(json, "Timeline"),
      finalStage: parseValue<String>(json, "FinalStage"),
      finalStageDetail: parseValue<String>(json, "FinalStageDetail"),
      enquiryDate: parseValue<DateTime>(json, "EnquiryDate"),
      nextFollowUpDate: parseValue<DateTime>(json, "NextFollowUpDate"),
      salesAdvisor: parseValue<String>(json, "SalesAdvisor"),
      sourcingManager: parseValue<String>(json, "SourcingManager"),
      salesAdvisorId: parseValue<int>(json, "SalesAdvisorId"),
      sourcingManagerId: parseValue<int>(json, "SourcingManagerId"),
      channelPartnerTeamMemberId: parseValue<int>(
        json,
        "ChannelPartnerTeamMemberId",
      ),
      channelPartnerTeamMemberName: parseValue<String>(
        json,
        "ChannelPartnerTeamMemberName",
      ),
      channelPartnerTeamMemberMobileNumber: parseValue<String>(
        json,
        "ChannelPartnerTeamMemberMobileNumber",
      ),
      channelPartnerMobileNumber: parseValue<String>(
        json,
        "ChannelPartnerMobileNumber",
      ),
      channelPartnerName: parseValue<String>(json, "ChannelPartnerName"),
      villageName: parseValue<String>(json, "VillageName"),
      referelName: parseValue<String>(json, "ReferelName"),
      referelMobileNumber: parseValue<String>(json, "ReferelMobileNumber"),
      referelProjectName: parseValue<String>(json, "ReferelProjectName"),
      referelUnitNumber: parseValue<String>(json, "ReferelUnitNumber"),
      loyaltyExistingProjectName: parseValue<String>(
        json,
        "LoyaltyExistingProjectName",
      ),
      loyaltyExistingUnitNumber: parseValue<String>(
        json,
        "LoyaltyExistingUnitNumber",
      ),
      employeeReferenceName: parseValue<String>(json, "EmployeeReferenceName"),
      employeeReferenceMobileNumber: parseValue<String>(
        json,
        "EmployeeReferenceMobileNumber",
      ),
      remark: parseValue<String>(json, "Remark"),
      villageMasterId: json["VillageMasterId"],

      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate: parseValue<DateTime>(json, "CreatedDate"),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate: parseValue<DateTime>(json, "ModifiedDate"),
    );
  }

  Map<String, dynamic> toJson() => {
    "EnquiryId": enquiryId,
    "SystemGeneratedCode": systemGeneratedCode,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "EnquiryTimeIn": enquiryTimeIn,
    "EnquiryTimeOut": enquiryTimeOut,
    "Name": name,
    "MobileNumber": mobileNumber,
    "EmailId": emailId,
    "DateOfBirth": dateOfBirth?.toIso8601String(),
    "Age": age,
    "Accommodation": accommodation,
    "OccupationType": occupationType,
    "Nationality": nationality,
    "CountryOfResidence": countryOfResidence,
    "CityOfResidence": cityOfResidence,
    "CurrentLocation": currentLocation,
    "PossessionType": possessionType,
    "AreaPreferred": areaPreferred,
    "DesiredFloorBand": desiredFloorBand,
    "Budget": budget,
    "Requirement": requirement,
    "RequirementType": requirementType,
    "CustomerClassification": customerClassification,
    "Source": source,
    "SubSource": subSource,
    "SubSubSource": subSubSource,
    "SourceOfFunding": sourceOfFunding,
    "Ethnicity": ethnicity,
    "Timeline": timeline,
    "FinalStage": finalStage,
    "FinalStageDetail": finalStageDetail,
    "EnquiryDate": enquiryDate?.toIso8601String(),
    "NextFollowUpDate": nextFollowUpDate?.toIso8601String(),
    "SalesAdvisor": salesAdvisor,
    "SourcingManager": sourcingManager,
    "SalesAdvisorId": salesAdvisorId,
    "SourcingManagerId": sourcingManagerId,
    "ChannelPartnerTeamMemberId": channelPartnerTeamMemberId,
    "ChannelPartnerTeamMemberName": channelPartnerTeamMemberName,
    "ChannelPartnerTeamMemberMobileNumber":
        channelPartnerTeamMemberMobileNumber,
    "ChannelPartnerName": channelPartnerName,
    "VillageName": villageName,
    "ReferelName": referelName,
    "ReferelMobileNumber": referelMobileNumber,
    "ReferelProjectName": referelProjectName,
    "ReferelUnitNumber": referelUnitNumber,
    "LoyaltyExistingProjectName": loyaltyExistingProjectName,
    "LoyaltyExistingUnitNumber": loyaltyExistingUnitNumber,
    "EmployeeReferenceName": employeeReferenceName,
    "EmployeeReferenceMobileNumber": employeeReferenceMobileNumber,
    "Remark": remark,
    "VillageMasterId": villageMasterId,
    "ChannelPartnerMobileNumber": channelPartnerMobileNumber,

    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
