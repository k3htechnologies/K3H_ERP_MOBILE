import 'package:k3h_erp_app/utils/common_function.dart';

class CallingDataModel {
  int callLogTrackerId;
  String uniquekey;
  String name;
  String emailId;
  String mobileNumber;
  String address;
  String designation;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  CallingDataModel({
    required this.callLogTrackerId,
    required this.uniquekey,
    required this.name,
    required this.emailId,
    required this.mobileNumber,
    required this.address,
    required this.designation,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory CallingDataModel.fromJson(Map<String, dynamic> json) =>
      CallingDataModel(
        callLogTrackerId: parseValue<int>(json, "CallLogTrackerId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        name: parseValue<String>(json, "Name"),
        emailId: parseValue<String>(json, "EmailId"),
        mobileNumber: parseValue<String>(json, "MobileNumber"),
        address: parseValue<String>(json, "Address"),
        designation: parseValue<String>(json, "Designation"),
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
    "CallLogTrackerId": callLogTrackerId,
    "Uniquekey": uniquekey,
    "Name": name,
    "EmailId": emailId,
    "MobileNumber": mobileNumber,
    "Address": address,
    "Designation": designation,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
