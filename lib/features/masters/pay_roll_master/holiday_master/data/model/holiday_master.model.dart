import 'package:k3h_erp_app/utils/functions/common_function.dart';

class HolidayMasterModel {
  int holidayMasterId;
  String uniquekey;
  String holidayName;
  String holidayUrl;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  HolidayMasterModel({
    required this.holidayMasterId,
    required this.uniquekey,
    required this.holidayName,
    required this.holidayUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory HolidayMasterModel.fromJson(Map<String, dynamic> json) =>
      HolidayMasterModel(
        holidayMasterId: parseValue<int>(json, "HolidayMasterId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        holidayName: parseValue<String>(json, "HolidayName"),
        holidayUrl: parseValue<String>(json, "HolidayURL"),
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
    "HolidayMasterId": holidayMasterId,
    "Uniquekey": uniquekey,
    "HolidayName": holidayName,
    "HolidayURL": holidayUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
