import 'package:k3h_erp_app/utils/common_function.dart';

class OtherChargeModel {
  int otherChargesId;
  String uniquekey;
  int bookingOtherChargesId;
  String chargeName;
  String calculatedOn;
  double value;
  double gstPercentage;
  double gstValue;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  bool isMaster;

  OtherChargeModel({
    required this.otherChargesId,
    required this.uniquekey,
    required this.bookingOtherChargesId,
    required this.chargeName,
    required this.calculatedOn,
    required this.value,
    required this.gstPercentage,
    required this.gstValue,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.isMaster,
  });

  factory OtherChargeModel.fromJson(Map<String, dynamic> json) =>
      OtherChargeModel(
        otherChargesId: parseValue<int>(json, "OtherChargesId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        bookingOtherChargesId: parseValue<int>(json, "BookingOtherChargesId"),
        chargeName: parseValue<String>(json, "ChargeName"),
        calculatedOn: parseValue<String>(json, "CalculatedOn"),
        value: parseValue<double>(json, "Value"),
        gstPercentage: parseValue<double>(json, "GSTPercentage"),
        gstValue: parseValue<double>(json, "GSTValue"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
        isMaster: parseValue<bool>(json, "IsMaster"),
      );

  Map<String, dynamic> toJson() => {
    "OtherChargesId": otherChargesId,
    "Uniquekey": uniquekey,
    "BookingOtherChargesId": bookingOtherChargesId,
    "ChargeName": chargeName,
    "CalculatedOn": calculatedOn,
    "Value": value,
    "GSTPercentage": gstPercentage,
    "GSTValue": gstValue,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "IsMaster": isMaster,
  };

  OtherChargeModel copyWith({
    int? otherChargesId,
    String? uniquekey,
    int? bookingOtherChargesId,
    String? chargeName,
    String? calculatedOn,
    double? value,
    double? gstPercentage,
    double? gstValue,
    int? createdById,
    String? createdBy,
    DateTime? createdDate,
    int? modifiedById,
    String? modifiedBy,
    DateTime? modifiedDate,
    bool? isSelected,
    bool? isMaster,
  }) {
    return OtherChargeModel(
      otherChargesId: otherChargesId ?? this.otherChargesId,
      uniquekey: uniquekey ?? this.uniquekey,
      bookingOtherChargesId:
          bookingOtherChargesId ?? this.bookingOtherChargesId,
      chargeName: chargeName ?? this.chargeName,
      calculatedOn: calculatedOn ?? this.calculatedOn,
      value: value ?? this.value,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      gstValue: gstValue ?? this.gstValue,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      modifiedById: modifiedById ?? this.modifiedById,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      isMaster: isMaster ?? this.isMaster,
    );
  }
}
