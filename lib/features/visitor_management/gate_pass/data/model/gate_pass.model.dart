import 'package:k3h_erp_app/utils/functions/common_function.dart';

class GatePassModel {
  int externalId;
  String uniquekey;
  String fullName;
  String mobileNumber;
  String address;
  String purpose;
  String remark;
  int employeeId;
  String employeeName;
  DateTime passDateTime;
  DateTime? outDateTime;
  int noOfParticipants;
  bool isDelete;
  String photoUrl;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  GatePassModel({
    required this.externalId,
    required this.uniquekey,
    required this.fullName,
    required this.mobileNumber,
    required this.address,
    required this.purpose,
    required this.remark,
    required this.employeeId,
    required this.employeeName,
    required this.passDateTime,
    required this.outDateTime,
    required this.noOfParticipants,
    required this.isDelete,
    required this.photoUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory GatePassModel.fromJson(Map<String, dynamic> json) => GatePassModel(
    externalId: parseValue<int>(json, "ExternalId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    fullName: parseValue<String>(json, "FullName"),
    mobileNumber: parseValue<String>(json, "MobileNumber"),
    address: parseValue<String>(json, "Address"),
    purpose: parseValue<String>(json, "Purpose"),
    remark: parseValue<String>(json, "Remark"),
    employeeId: parseValue<int>(json, "EmployeeId"),
    employeeName: parseValue<String>(json, "EmployeeName"),
    passDateTime: DateTime.parse(json["PassDateTime"]),
    outDateTime:
        json["OutDateTime"] == null
            ? null
            : DateTime.parse(json["OutDateTime"]),
    noOfParticipants: parseValue<int>(json, "NoOfParticipants"),
    isDelete: parseValue<bool>(json, "IsDelete"),
    photoUrl: parseValue<String>(json, "PhotoURL"),
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
    "ExternalId": externalId,
    "Uniquekey": uniquekey,
    "FullName": fullName,
    "MobileNumber": mobileNumber,
    "Address": address,
    "Purpose": purpose,
    "Remark": remark,
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "PassDateTime": passDateTime.toIso8601String(),
    "OutDateTime": outDateTime?.toIso8601String(),
    "NoOfParticipants": noOfParticipants,
    "IsDelete": isDelete,
    "PhotoURL": photoUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
