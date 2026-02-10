import 'package:k3h_erp_app/utils/common_function.dart';

class EnquiryModel {
  int enquiryId;
  String uniquekey;
  int projectId;
  String projectName;
  String name;
  String emailId;
  String mobileNumber;
  String occupationType;
  String accommodation;
  String budget;
  bool isHomeLoan;
  String requirement;
  String requirementType;
  int areaPreferred;
  String possessionType;
  String source;
  String subSource;
  String channelPartnerName;
  String channelPartnerCompany;
  String channelPartnerMobileNumber;
  String finalStage;
  String finalStageDetail;
  DateTime nextFollowUpDate;
  DateTime enquiryDate;
  String remark;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  EnquiryModel({
    required this.enquiryId,
    required this.uniquekey,
    required this.projectId,
    required this.projectName,
    required this.name,
    required this.emailId,
    required this.mobileNumber,
    required this.occupationType,
    required this.accommodation,
    required this.budget,
    required this.isHomeLoan,
    required this.requirement,
    required this.requirementType,
    required this.areaPreferred,
    required this.possessionType,
    required this.source,
    required this.subSource,
    required this.channelPartnerName,
    required this.channelPartnerCompany,
    required this.channelPartnerMobileNumber,
    required this.finalStage,
    required this.finalStageDetail,
    required this.nextFollowUpDate,
    required this.enquiryDate,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) => EnquiryModel(
    enquiryId: parseValue<int>(json, "EnquiryId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    projectName: parseValue<String>(json, "ProjectName"),
    name: parseValue<String>(json, "Name"),
    emailId: parseValue<String>(json, "EmailId"),
    mobileNumber: parseValue<String>(json, "MobileNumber"),
    occupationType: parseValue<String>(json, "OccupationType"),
    accommodation: parseValue<String>(json, "Accommodation"),
    budget: parseValue<String>(json, "Budget"),
    isHomeLoan: parseValue<bool>(json, "IsHomeLoan"),
    requirement: parseValue<String>(json, "Requirement"),
    requirementType: parseValue<String>(json, "RequirementType"),
    areaPreferred: parseValue<int>(json, "AreaPreferred"),
    possessionType: parseValue<String>(json, "PossessionType"),
    source: parseValue<String>(json, "Source"),
    subSource: parseValue<String>(json, "SubSource"),
    channelPartnerName: parseValue<String>(json, "ChannelPartnerName"),
    channelPartnerCompany: parseValue<String>(json, "ChannelPartnerCompany"),
    channelPartnerMobileNumber: parseValue<String>(
      json,
      "ChannelPartnerMobileNumber",
    ),
    finalStage: parseValue<String>(json, "FinalStage"),
    finalStageDetail: parseValue<String>(json, "FinalStageDetail"),
    nextFollowUpDate: parseValue<DateTime>(json, "NextFollowUpDate"),
    enquiryDate: parseValue<DateTime>(json, "EnquiryDate"),
    remark: parseValue<String>(json, "Remark"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
  );

  Map<String, dynamic> toJson() => {
    "EnquiryId": enquiryId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ProjectName": projectName,
    "Name": name,
    "EmailId": emailId,
    "MobileNumber": mobileNumber,
    "OccupationType": occupationType,
    "Accommodation": accommodation,
    "Budget": budget,
    "IsHomeLoan": isHomeLoan,
    "Requirement": requirement,
    "RequirementType": requirementType,
    "AreaPreferred": areaPreferred,
    "PossessionType": possessionType,
    "Source": source,
    "SubSource": subSource,
    "ChannelPartnerName": channelPartnerName,
    "ChannelPartnerCompany": channelPartnerCompany,
    "ChannelPartnerMobileNumber": channelPartnerMobileNumber,
    "FinalStage": finalStage,
    "FinalStageDetail": finalStageDetail,
    "NextFollowUpDate": nextFollowUpDate.toIso8601String(),
    "EnquiryDate": enquiryDate.toIso8601String(),
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
