import 'package:k3h_erp_app/utils/functions/common_function.dart';

class SourcingModel {
  final int? channelPartnerSourcingId;
  final String? uniquekey;
  final int? projectId;
  final int? channelPartnerId;
  final String? ibmObm;
  final String? sourcingRemark;
  final String? support;
  final double? sourcingLatitude;
  final double? sourcingLongitude;
  final String? sourcingLocation;
  final bool isAction;
  final int? createdById;
  final String? createdBy;
  final DateTime? createdDate;
  final int? modifiedById;
  final String? modifiedBy;
  final DateTime? modifiedDate;

  const SourcingModel({
    this.channelPartnerSourcingId,
    this.uniquekey,
    this.projectId,
    this.channelPartnerId,
    this.ibmObm,
    this.sourcingRemark,
    this.support,
    this.sourcingLatitude,
    this.sourcingLongitude,
    this.sourcingLocation,
    this.isAction = false,
    this.createdById,
    this.createdBy,
    this.createdDate,
    this.modifiedById,
    this.modifiedBy,
    this.modifiedDate,
  });

  /// ================= FROM JSON =================
  factory SourcingModel.fromJson(Map<String, dynamic> json) {
    return SourcingModel(
      channelPartnerSourcingId:
      parseValue<int>(json, "ChannelPartnerSourcingId"),
      uniquekey: parseValue<String>(json, "Uniquekey"),
      projectId: parseValue<int>(json, "ProjectId"),
      channelPartnerId: parseValue<int>(json, "ChannelPartnerId"),
      ibmObm: parseValue<String>(json, "IBM_OBM"),
      sourcingRemark: parseValue<String>(json, "SourcingRemark"),
      support: parseValue<String>(json, "Support"),
      sourcingLatitude:
      (json["SourcingLatitude"] as num?)?.toDouble(),
      sourcingLongitude:
      (json["SourcingLongitude"] as num?)?.toDouble(),
      sourcingLocation: parseValue<String>(json, "SourcingLocation"),
      isAction: parseValue<bool>(json, "IsAction"),
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate: json["CreatedDate"] == null
          ? null
          : DateTime.tryParse(json["CreatedDate"].toString()),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate: json["ModifiedDate"] == null
          ? null
          : DateTime.tryParse(json["ModifiedDate"].toString()),
    );
  }

  /// ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      "ChannelPartnerSourcingId": channelPartnerSourcingId,
      "Uniquekey": uniquekey,
      "ProjectId": projectId,
      "ChannelPartnerId": channelPartnerId,
      "IBM_OBM": ibmObm,
      "SourcingRemark": sourcingRemark,
      "Support": support,
      "SourcingLatitude": sourcingLatitude,
      "SourcingLongitude": sourcingLongitude,
      "SourcingLocation": sourcingLocation,
      "IsAction": isAction,
      "CreatedById": createdById,
      "CreatedBy": createdBy,
      "CreatedDate": createdDate?.toIso8601String(),
      "ModifiedById": modifiedById,
      "ModifiedBy": modifiedBy,
      "ModifiedDate": modifiedDate?.toIso8601String(),
    };
  }

  /// ================= HELPERS =================
  bool get isIBM => ibmObm == "IBM";
  bool get isOBM => ibmObm == "OBM";
}