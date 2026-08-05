import 'package:k3h_erp_app/utils/functions/common_function.dart';

class OtpLogsModel {
  String otp;
  String module;
  String mobileNumber;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  OtpLogsModel({
    required this.otp,
    required this.module,
    required this.mobileNumber,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory OtpLogsModel.fromJson(Map<String, dynamic> json) => OtpLogsModel(
    otp: parseValue<String>(json, "OTP"),
    module: parseValue<String>(json, "Module"),
    mobileNumber: parseValue<String>(json, "MobileNumber"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate:
        json["CreatedDate"] != null
            ? DateTime.parse(json["CreatedDate"])
            : null,
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] != null
            ? DateTime.parse(json["ModifiedDate"])
            : null,
  );

  Map<String, dynamic> toJson() => {
    "OTP": otp,
    "Module": module,
    "MobileNumber": mobileNumber,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
