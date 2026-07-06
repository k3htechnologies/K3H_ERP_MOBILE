import 'package:k3h_erp_app/utils/functions/common_function.dart';

class PayTrackCallLogModel {
  int payTrackCallLogId;
  String uniquekey;
  int projectId;
  int bookingId;
  String applicantType;
  String applicantName;
  String applicantMobileNumber;
  DateTime callDate;
  String duration;
  String callStatus;
  String callPurpose;
  String remark;
  DateTime rescheduleDate;
  DateTime registrationDate;
  double promiseAmount;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime modifiedDate;

  PayTrackCallLogModel({
    required this.payTrackCallLogId,
    required this.uniquekey,
    required this.projectId,
    required this.bookingId,
    required this.applicantType,
    required this.applicantName,
    required this.applicantMobileNumber,
    required this.callDate,
    required this.duration,
    required this.callStatus,
    required this.callPurpose,
    required this.remark,
    required this.rescheduleDate,
    required this.registrationDate,
    required this.promiseAmount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory PayTrackCallLogModel.fromJson(Map<String, dynamic> json) =>
      PayTrackCallLogModel(
        payTrackCallLogId: parseValue<int>(json, "PayTrackCallLogId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        bookingId: (parseValue<int>(json, "BookingId")),
        applicantType: parseValue<String>(json, "ApplicantType"),
        applicantName: parseValue<String>(json, "ApplicantName"),
        applicantMobileNumber: parseValue<String>(
          json,
          "ApplicantMobileNumber",
        ),
        callDate:
            json["CallDate"] != null
                ? DateTime.parse(json["CallDate"])
                : DateTime.now(),
        duration: parseValue<String>(json, "Duration"),
        callStatus: parseValue<String>(json, "CallStatus"),
        callPurpose: parseValue<String>(json, "CallPurpose"),
        remark: parseValue<String>(json, "Remark"),
        rescheduleDate:
            json["RescheduleDate"] != null
                ? DateTime.parse(json["RescheduleDate"])
                : DateTime.now(),
        registrationDate:
            json["RegistrationDate"] != null
                ? DateTime.parse(json["RegistrationDate"])
                : DateTime.now(),
        promiseAmount: parseValue<double>(json, "PromiseAmount"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate:
            json["CreatedDate"] != null
                ? DateTime.parse(json["CreatedDate"])
                : DateTime.now(),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] != null
                ? DateTime.parse(json["ModifiedDate"])
                : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    "PayTrackCallLogId": payTrackCallLogId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "BookingId": bookingId,
    "ApplicantType": applicantType,
    "ApplicantName": applicantName,
    "ApplicantMobileNumber": applicantMobileNumber,
    "CallDate": callDate.toIso8601String(),
    "Duration": duration,
    "CallStatus": callStatus,
    "CallPurpose": callPurpose,
    "Remark": remark,
    "RescheduleDate": rescheduleDate.toIso8601String(),
    "RegistrationDate": registrationDate.toIso8601String(),
    "PromiseAmount": promiseAmount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate.toIso8601String(),
  };
}
