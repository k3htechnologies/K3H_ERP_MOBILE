import 'package:k3h_erp_app/utils/functions/common_function.dart';

class WeekOffMasterModel {
  final int weekOffPolicyMasterId;
  final String uniqueKey;
  final String weekOffPolicyCode;
  final String weekOffPolicyName;
  final int weekDays;
  final String weekDaysStartsOn;
  final String weeklyOff;
  final String weeklyOff2;
  final String weeklyOff2Type;
  final String notApplicableForMonths;
  final String createdBy;
  final DateTime createdDate;
  final String modifiedBy;
  final DateTime modifiedDate;

  WeekOffMasterModel({
    required this.weekOffPolicyMasterId,
    required this.uniqueKey,
    required this.weekOffPolicyCode,
    required this.weekOffPolicyName,
    required this.weekDays,
    required this.weekDaysStartsOn,
    required this.weeklyOff,
    required this.weeklyOff2,
    required this.weeklyOff2Type,
    required this.notApplicableForMonths,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory WeekOffMasterModel.fromJson(Map<String, dynamic> json) {
    return WeekOffMasterModel(
      weekOffPolicyMasterId: parseValue<int>(json, 'WeekOffPolicyMasterId'),
      uniqueKey: parseValue<String>(json, 'Uniquekey'),
      weekOffPolicyCode: parseValue<String>(json, 'WeekOffPolicyCode'),
      weekOffPolicyName: parseValue<String>(json, 'WeekOffPolicyName'),
      weekDays: parseValue<int>(json, 'WeekDays'),
      weekDaysStartsOn: parseValue<String>(json, 'WeekDaysStartsOn'),
      weeklyOff: parseValue<String>(json, 'WeeklyOff'),
      weeklyOff2: parseValue<String>(json, 'WeeklyOff2'),
      weeklyOff2Type: parseValue<String>(json, 'WeeklyOff2Type'),
      notApplicableForMonths: parseValue<String>(
        json,
        'NotApplicableForMonths',
      ),
      createdBy: parseValue<String>(json, 'CreatedBy'),
      createdDate: parseValue<DateTime>(json, 'CreatedDate'),
      modifiedBy: parseValue<String>(json, 'ModifiedBy'),
      modifiedDate: parseValue<DateTime>(json, 'ModifiedDate'),
    );
  }

  Map<String, dynamic> toJson() => {
    'WeekOffPolicyMasterId': weekOffPolicyMasterId,
    'Uniquekey': uniqueKey,
    'WeekOffPolicyCode': weekOffPolicyCode,
    'WeekOffPolicyName': weekOffPolicyName,
    'WeekDays': weekDays,
    'WeekDaysStartsOn': weekDaysStartsOn,
    'WeeklyOff': weeklyOff,
    'WeeklyOff2': weeklyOff2,
    'WeeklyOff2Type': weeklyOff2Type,
    'NotApplicableForMonths': notApplicableForMonths,
    'CreatedBy': createdBy,
    'CreatedDate': createdDate.toIso8601String(),
    'ModifiedBy': modifiedBy,
    'ModifiedDate': modifiedDate.toIso8601String(),
  };
}
