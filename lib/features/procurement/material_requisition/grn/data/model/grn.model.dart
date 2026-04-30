import 'package:k3h_erp_app/utils/common_function.dart';

class GRNModel {
  int materialRequisitionGrnId;
  String uniquekey;
  int materialRequisitionId;
  String challanNumber;
  String vehicleNumber;
  String uploadChallanUrl;
  String remarks;
  int clientRegistrationId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;
  List<MaterialRequisitionDetailGrnDatum> materialRequisitionDetailGrnData;

  GRNModel({
    required this.materialRequisitionGrnId,
    required this.uniquekey,
    required this.materialRequisitionId,
    required this.challanNumber,
    required this.vehicleNumber,
    required this.uploadChallanUrl,
    required this.remarks,
    required this.clientRegistrationId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.materialRequisitionDetailGrnData,
  });

  factory GRNModel.fromJson(Map<String, dynamic> json) => GRNModel(
    materialRequisitionGrnId: parseValue<int>(json, "MaterialRequisitionGRNId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    materialRequisitionId: parseValue<int>(json, "MaterialRequisitionId"),
    challanNumber: parseValue<String>(json, "ChallanNumber"),
    vehicleNumber: parseValue<String>(json, "VehicleNumber"),
    uploadChallanUrl: parseValue<String>(json, "UploadChallanURL"),
    remarks: parseValue<String>(json, "Remarks"),
    clientRegistrationId: parseValue<int>(json, "ClientRegistrationId"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate: parseValue<DateTime>(json, "ModifiedDate"),
    materialRequisitionDetailGrnData:
        json["MaterialRequisitionDetailGRNData"] == null
            ? []
            : List<MaterialRequisitionDetailGrnDatum>.from(
              json["MaterialRequisitionDetailGRNData"].map(
                (x) => MaterialRequisitionDetailGrnDatum.fromJson(x),
              ),
            ),
  );

  Map<String, dynamic> toJson() => {
    "MaterialRequisitionGRNId": materialRequisitionGrnId,
    "Uniquekey": uniquekey,
    "MaterialRequisitionId": materialRequisitionId,
    "ChallanNumber": challanNumber,
    "VehicleNumber": vehicleNumber,
    "UploadChallanURL": uploadChallanUrl,
    "Remarks": remarks,
    "ClientRegistrationId": clientRegistrationId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
    "MaterialRequisitionDetailGRNData": List<dynamic>.from(
      materialRequisitionDetailGrnData.map((x) => x.toJson()),
    ),
  };
}

class MaterialRequisitionDetailGrnDatum {
  int materialRequisitionDetailGrnId;
  String uniquekey;
  int materialRequisitionGrnId;
  int materialRequisitionDetailId;
  String materialName;
  String subMaterialName;
  double materialQuantity;
  String uomCode;
  String uom;
  DateTime requiredDate;
  double totalReceivedMaterialQuantity;
  String? qualityAnalysisRemarks;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  MaterialRequisitionDetailGrnDatum({
    required this.materialRequisitionDetailGrnId,
    required this.uniquekey,
    required this.materialRequisitionGrnId,
    required this.materialRequisitionDetailId,
    required this.materialName,
    required this.subMaterialName,
    required this.materialQuantity,
    required this.uomCode,
    required this.uom,
    required this.requiredDate,
    required this.totalReceivedMaterialQuantity,
    required this.qualityAnalysisRemarks,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory MaterialRequisitionDetailGrnDatum.fromJson(
    Map<String, dynamic> json,
  ) => MaterialRequisitionDetailGrnDatum(
    materialRequisitionDetailGrnId: json["MaterialRequisitionDetailGRNId"],
    uniquekey: json["Uniquekey"],
    materialRequisitionGrnId: json["MaterialRequisitionGRNId"],
    materialRequisitionDetailId: json["MaterialRequisitionDetailId"],
    materialName: json["MaterialName"],
    subMaterialName: json["SubMaterialName"],
    materialQuantity: json["MaterialQuantity"],
    uomCode: json["UomCode"],
    uom: json["Uom"],
    requiredDate: DateTime.parse(json["RequiredDate"]),
    totalReceivedMaterialQuantity: json["TotalReceivedMaterialQuantity"],
    qualityAnalysisRemarks: json["QualityAnalysisRemarks"],
    createdById: json["CreatedById"],
    createdBy: json["CreatedBy"],
    createdDate: DateTime.parse(json["CreatedDate"]),
    modifiedById: json["ModifiedById"],
    modifiedBy: json["ModifiedBy"],
    modifiedDate: json["ModifiedDate"],
  );

  Map<String, dynamic> toJson() => {
    "MaterialRequisitionDetailGRNId": materialRequisitionDetailGrnId,
    "Uniquekey": uniquekey,
    "MaterialRequisitionGRNId": materialRequisitionGrnId,
    "MaterialRequisitionDetailId": materialRequisitionDetailId,
    "MaterialName": materialName,
    "SubMaterialName": subMaterialName,
    "MaterialQuantity": materialQuantity,
    "UomCode": uomCode,
    "Uom": uom,
    "RequiredDate": requiredDate.toIso8601String(),
    "TotalReceivedMaterialQuantity": totalReceivedMaterialQuantity,
    "QualityAnalysisRemarks": qualityAnalysisRemarks,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };

  Map<String, dynamic> toJsonPayload() => {
    "MaterialRequisitionDetailGRNId": materialRequisitionDetailGrnId,
    "MaterialRequisitionDetailId": materialRequisitionDetailId,
    "TotalReceivedMaterialQuantity": totalReceivedMaterialQuantity,
  };
}
