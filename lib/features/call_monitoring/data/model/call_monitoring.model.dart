import 'package:k3h_erp_app/utils/functions/common_function.dart';

class CallMonitoringModel {
  int callMonitoringId;
  String uniquekey;
  int projectId;
  int id;
  String pageName;
  String name;
  String mobileNumber;
  DateTime callDate;
  String duration;
  String callStatus;
  String callPurpose;
  String remark;
  DateTime? rescheduleDate;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  CallMonitoringModel({
    required this.callMonitoringId,
    required this.uniquekey,
    required this.projectId,
    required this.id,
    required this.pageName,
    required this.name,
    required this.mobileNumber,
    required this.callDate,
    required this.duration,
    required this.callStatus,
    required this.callPurpose,
    required this.remark,
    required this.rescheduleDate,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory CallMonitoringModel.fromJson(Map<String, dynamic> json) =>
      CallMonitoringModel(
        callMonitoringId: parseValue<int>(json, "CallMonitoringId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        id: parseValue<int>(json, "Id"),
        pageName: parseValue<String>(json, "PageName"),
        name: parseValue<String>(json, "Name"),
        mobileNumber: parseValue<String>(json, "MobileNumber"),
        callDate: parseValue<DateTime>(json, "CallDate"),
        duration: parseValue<String>(json, "Duration"),
        callStatus: parseValue<String>(json, "CallStatus"),
        callPurpose: parseValue<String>(json, "CallPurpose"),
        remark: parseValue<String>(json, "Remark"),
        rescheduleDate:
            json["RescheduleDate"] == null
                ? null
                : parseValue<DateTime>(json, "RescheduleDate"),
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
    "CallMonitoringId": callMonitoringId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "Id": id,
    "PageName": pageName,
    "Name": name,
    "MobileNumber": mobileNumber,
    "CallDate": callDate,
    "Duration": duration,
    "CallStatus": callStatus,
    "CallPurpose": callPurpose,
    "Remark": remark,
    "RescheduleDate": rescheduleDate?.toIso8601String(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
