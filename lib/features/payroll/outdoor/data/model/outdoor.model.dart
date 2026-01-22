import 'package:k3h_erp_app/utils/common_function.dart';

class OutdoorModel {
  int outdoorId;
  String uniquekey;
  DateTime outDoorDate;
  DateTime outDoorTime;
  String accompaniedById;
  String accompaniedByName;
  int departmentId;
  String departmentName;
  String companyName;
  String companyAddress;
  String visitingCardUrl;
  String purpose;
  String conclusion;
  DateTime? punchIn;
  DateTime? punchOut;
  String punchInAddress;
  String punchOutAddress;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  OutdoorModel({
    required this.outdoorId,
    required this.uniquekey,
    required this.outDoorDate,
    required this.outDoorTime,
    required this.accompaniedById,
    required this.accompaniedByName,
    required this.departmentId,
    required this.departmentName,
    required this.companyName,
    required this.companyAddress,
    required this.visitingCardUrl,
    required this.purpose,
    required this.conclusion,
    required this.punchIn,
    required this.punchOut,
    required this.punchInAddress,
    required this.punchOutAddress,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory OutdoorModel.fromJson(Map<String, dynamic> json) => OutdoorModel(
    outdoorId: parseValue<int>(json, "OutdoorId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    outDoorDate: parseValue<DateTime>(json, "OutDoorDate"),
    outDoorTime: parseValue<DateTime>(json, "OutDoorTime"),
    accompaniedById: parseValue<String>(json, "AccompaniedById"),
    accompaniedByName: parseValue<String>(json, "AccompaniedByName"),
    departmentId: parseValue<int>(json, "DepartmentId"),
    departmentName: parseValue<String>(json, "DepartmentName"),
    companyName: parseValue<String>(json, "CompanyName"),
    companyAddress: parseValue<String>(json, "CompanyAddress"),
    visitingCardUrl: parseValue<String>(json, "VisitingCardURL"),
    purpose: parseValue<String>(json, "Purpose"),
    conclusion: parseValue<String>(json, "Conclusion"),
    punchIn:
        json["PunchIn"] == null ? null : parseValue<DateTime>(json, "PunchIn"),
    punchOut:
        json["PunchOut"] == null
            ? null
            : parseValue<DateTime>(json, "PunchOut"),
    punchInAddress: parseValue<String>(json, "PunchInAddress"),
    punchOutAddress: parseValue<String>(json, "PunchOutAddress"),
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
    "OutdoorId": outdoorId,
    "Uniquekey": uniquekey,
    "OutDoorDate": outDoorDate.toIso8601String(),
    "OutDoorTime": outDoorTime.toIso8601String(),
    "AccompaniedById": accompaniedById,
    "AccompaniedByName": accompaniedByName,
    "DepartmentId": departmentId,
    "DepartmentName": departmentName,
    "CompanyName": companyName,
    "CompanyAddress": companyAddress,
    "VisitingCardURL": visitingCardUrl,
    "Purpose": purpose,
    "Conclusion": conclusion,
    "PunchIn": punchIn?.toIso8601String(),
    "PunchOut": punchOut?.toIso8601String(),
    "PunchInAddress": punchInAddress,
    "PunchOutAddress": punchOutAddress,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
