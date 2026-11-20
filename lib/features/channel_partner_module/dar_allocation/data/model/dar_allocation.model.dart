import 'package:k3h_erp_app/utils/functions/common_function.dart';

class DarAllocationModel {
  int darAllocationId;
  String uniquekey;
  String employeeName;
  int employeeId;
  String villageName;
  String villageMasterId;
  int numberOfChannelPartner;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  DarAllocationModel({
    required this.darAllocationId,
    required this.uniquekey,
    required this.employeeName,
    required this.employeeId,
    required this.villageName,
    required this.villageMasterId,
    required this.numberOfChannelPartner,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory DarAllocationModel.fromJson(Map<String, dynamic> json) =>
      DarAllocationModel(
        darAllocationId: parseValue<int>(json, "DarAllocationId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        employeeName: parseValue<String>(json, "EmployeeName"),
        employeeId: parseValue<int>(json, "EmployeeId"),
        villageName: parseValue<String>(json, "VillageName"),
        villageMasterId: parseValue<String>(json, "VillageMasterId"),
        numberOfChannelPartner: parseValue<int>(json, "NumberOfChannelPartner"),
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
    "DarAllocationId": darAllocationId,
    "Uniquekey": uniquekey,
    "EmployeeName": employeeName,
    "EmployeeId": employeeId,
    "VillageName": villageName,
    "VillageMasterId": villageMasterId,
    "NumberOfChannelPartner": numberOfChannelPartner,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
