import 'package:k3h_erp_app/utils/functions/common_function.dart';

class CallLogModel {
  int callLogId;
  String uniquekey;
  int projectId;
  String callerName;
  String receiverName;
  String mobileNumber;
  DateTime callDate;
  String duration;
  String status;
  String remark;
  DateTime? rescheduleDate;
  DateTime? siteVisitProposedDate;
  String budget;
  String requirement;
  String requirementType;
  String villageMasterId;
  String villageName;
  bool isEditable;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  CallLogModel({
    required this.callLogId,
    required this.uniquekey,
    required this.projectId,
    required this.callerName,
    required this.receiverName,
    required this.mobileNumber,
    required this.callDate,
    required this.duration,
    required this.status,
    required this.remark,
    required this.rescheduleDate,
    required this.siteVisitProposedDate,
    required this.budget,
    required this.requirement,
    required this.requirementType,
    required this.villageMasterId,
    required this.villageName,
    required this.isEditable,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) => CallLogModel(
    callLogId: parseValue<int>(json, "CallLogId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    callerName: parseValue<String>(json, "CallerName"),
    receiverName: parseValue<String>(json, "ReceiverName"),
    mobileNumber: parseValue<String>(json, "MobileNumber"),
    callDate: DateTime.parse(json["CallDate"]),
    duration: parseValue<String>(json, "Duration"),
    status: parseValue<String>(json, "Status"),
    remark: parseValue<String>(json, "Remark"),

    rescheduleDate:
        json["RescheduleDate"] == null
            ? null
            : DateTime.parse(json["RescheduleDate"]),

    siteVisitProposedDate:
        json["SiteVisitProposedDate"] == null
            ? null
            : DateTime.parse(json["SiteVisitProposedDate"]),

    budget: parseValue<String>(json, "Budget"),
    requirement: parseValue<String>(json, "Requirement"),
    requirementType: parseValue<String>(json, "RequirementType"),
    villageMasterId: parseValue<String>(json, "VillageMasterId"),
    villageName: parseValue<String>(json, "VillageName"),

    isEditable: parseValue<bool>(json, "IsEditable"),

    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: DateTime.parse(json["CreatedDate"]),

    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),

    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : DateTime.parse(json["ModifiedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "CallLogId": callLogId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "CallerName": callerName,
    "ReceiverName": receiverName,
    "MobileNumber": mobileNumber,
    "CallDate": callDate.toIso8601String(),
    "Duration": duration,
    "Status": status,
    "Remark": remark,
    "RescheduleDate": rescheduleDate?.toIso8601String(),
    "SiteVisitProposedDate": siteVisitProposedDate?.toIso8601String(),
    "Budget": budget,
    "Requirement": requirement,
    "RequirementType": requirementType,
    "VillageMasterId": villageMasterId,
    "VillageName": villageName,
    "IsEditable": isEditable,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
