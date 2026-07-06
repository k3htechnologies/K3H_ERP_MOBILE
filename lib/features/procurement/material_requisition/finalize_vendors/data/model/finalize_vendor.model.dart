import 'package:k3h_erp_app/features/procurement/data/model/sub_material.model.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class RequisitionVendorModel extends VendorModel {
  final bool isApproval;
  final bool isFinalized;
  final String vendorFinalizedApproval;
  MaterialRequisitionQuotationTerms? materialRequisitionQuotationTermsData;
  final String magicLinkURL;
  // IT IS USED IN ENQUIRY REQUISITION SCREEN
  bool isSelected = false;

  RequisitionVendorModel({
    required super.vendorId,
    required super.uniquekey,
    required super.companyName,
    required super.companyType,
    required super.vendorName,
    required super.mobileNumber,
    required super.emailId,
    required super.aadharCardNumber,
    required super.aadharCardUrl,
    required super.panCardNumber,
    required super.panCardUrl,
    required super.gstNumber,
    required super.gstCertificateUrl,
    required super.address,
    required super.countryMasterId,
    required super.countryName,
    required super.stateMasterId,
    required super.stateName,
    required super.districtMasterId,
    required super.districtName,
    required super.cityMasterId,
    required super.cityName,
    required super.submaterialList,
    required super.contractList,
    required super.createdById,
    required super.createdBy,
    required super.createdDate,
    required super.modifiedById,
    required super.modifiedBy,
    required super.modifiedDate,
    required this.materialRequisitionQuotationTermsData,
    required this.isApproval,
    required this.isFinalized,
    this.isSelected = false,
    required this.magicLinkURL,
    required this.vendorFinalizedApproval,
  }) : super(villageMasterId: 0, villageName: '');

  factory RequisitionVendorModel.fromJson(Map<String, dynamic> json) =>
      RequisitionVendorModel(
        vendorId: parseValue<int>(json, "VendorId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        companyName: parseValue<String>(json, "CompanyName"),
        companyType: parseValue<String>(json, "CompanyType"),
        vendorName: parseValue<String>(json, "VendorName"),
        mobileNumber: parseValue<String>(json, "MobileNumber"),
        emailId: parseValue<String>(json, "EmailId"),
        aadharCardNumber: parseValue<String>(json, "AadharCardNumber"),
        aadharCardUrl: parseValue<String>(json, "AadharCardURL"),
        panCardNumber: parseValue<String>(json, "PanCardNumber"),
        panCardUrl: parseValue<String>(json, "PanCardURL"),
        gstNumber: parseValue<String>(json, "GSTNumber"),
        gstCertificateUrl: parseValue<String>(json, "GSTCertificateURL"),
        address: parseValue<String>(json, "Address"),
        countryMasterId: parseValue(json, "CountryMasterId"),
        countryName: parseValue<String>(json, "CountryName"),
        stateMasterId: parseValue<int>(json, "StateMasterId"),
        stateName: parseValue<String>(json, "StateName"),
        districtMasterId: parseValue<int>(json, "DistrictMasterId"),
        districtName: parseValue<String>(json, "DistrictName"),
        cityMasterId: parseValue(json, "CityMasterId"),
        cityName: parseValue<String>(json, "CityName"),
        submaterialList: [],
        // List<SubMaterialModel>.from(
        //   json["SubMaterialMasterData"].map((x) {
        //     var subMaterial = SubMaterialModel.fromJson(x);
        //     subMaterial.isSelected = true;
        //     return subMaterial;
        //   }),
        // ),
        contractList: List<String>.from(
          json["ContractTypeMasterData"].map((x) => x),
        ),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : DateTime.parse(json["ModifiedDate"]),
        materialRequisitionQuotationTermsData:
            List<MaterialRequisitionQuotationTerms>.from(
              json["MaterialRequisitionQuotationTermsData"].map(
                (x) => MaterialRequisitionQuotationTerms.fromJson(x),
              ),
            ).firstOrNull,
        isApproval: parseValue<bool>(json, "IsApproval"),
        isFinalized: parseValue<bool>(json, "IsFinalized"),
        magicLinkURL: parseValue<String>(json, "MagicLinkURL"),
        vendorFinalizedApproval: parseValue<String>(
          json,
          "VendorFinalizationApproval",
        ),
      );

  @override
  Map<String, dynamic> toJson() => {
    "VendorId": vendorId,
    "Uniquekey": uniquekey,
    "CompanyName": companyName,
    "CompanyType": companyType,
    "VendorName": vendorName,
    "MobileNumber": mobileNumber,
    "EmailId": emailId,
    "AadharCardNumber": aadharCardNumber,
    "AadharCardURL": aadharCardUrl,
    "PanCardNumber": panCardNumber,
    "PanCardURL": panCardUrl,
    "GSTNumber": gstNumber,
    "GSTCertificateURL": gstCertificateUrl,
    "Address": address,
    "CountryMasterId": countryMasterId,
    "CountryName": countryName,
    "StateMasterId": stateMasterId,
    "StateName": stateName,
    "DistrictMasterId": districtMasterId,
    "DistrictName": districtName,
    "CityMasterId": cityMasterId,
    "CityName": cityName,
    "SubMaterialMasterData": List<SubMaterialModel>.from(
      submaterialList.map((x) => x),
    ),
    "ContractTypeMasterData": List<dynamic>.from(contractList.map((x) => x)),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "MaterialRequisitionQuotationTermsData":
        materialRequisitionQuotationTermsData?.toJson(),
    "IsApproval": isApproval,
    "IsFinalized": isFinalized,
    "MagicLinkURL": magicLinkURL,
    "VendorFinalizationApproval": vendorFinalizedApproval,
  };
}

class MaterialRequisitionQuotationTerms {
  int materialRequisitionQuotationTermsId;
  String uniquekey;
  int materialRequisitionId;
  int vendorId;
  int expectedDeliveryInDays;
  int expectedPaymentInDays;
  double total;
  List<MaterialRequisitionQuotation> materialRequisitionQuotationData;

  MaterialRequisitionQuotationTerms({
    required this.materialRequisitionQuotationTermsId,
    required this.uniquekey,
    required this.materialRequisitionId,
    required this.vendorId,
    required this.expectedDeliveryInDays,
    required this.expectedPaymentInDays,
    required this.total,
    required this.materialRequisitionQuotationData,
  });
  factory MaterialRequisitionQuotationTerms.fromJson(
    Map<String, dynamic> json,
  ) => MaterialRequisitionQuotationTerms(
    materialRequisitionQuotationTermsId: parseValue<int>(
      json,
      "MaterialRequisitionQuotationTermsId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    materialRequisitionId: parseValue<int>(json, "MaterialRequisitionId"),
    vendorId: parseValue<int>(json, "VendorId"),
    expectedDeliveryInDays: json["ExpectedDeliveryInDays"],
    expectedPaymentInDays: json["ExpectedPaymentInDays"],
    total: parseValue<double>(json, "Total"),
    materialRequisitionQuotationData: List<MaterialRequisitionQuotation>.from(
      json["MaterialRequisitionQuotationData"].map(
        (x) => MaterialRequisitionQuotation.fromJson(x),
      ),
    ),
  );

  Map<String, dynamic> toJson() => {
    "MaterialRequisitionQuotationTermsId": materialRequisitionQuotationTermsId,
    "Uniquekey": uniquekey,
    "MaterialRequisitionId": materialRequisitionId,
    "VendorId": vendorId,
    "ExpectedDeliveryInDays": expectedDeliveryInDays,
    "ExpectedPaymentInDays": expectedPaymentInDays,
    "Total": total,
    "MaterialRequisitionQuotationData": List<dynamic>.from(
      materialRequisitionQuotationData.map((x) => x.toJson()),
    ),
  };
}

class MaterialRequisitionQuotation {
  int materialRequisitionQuotationId;
  String uniquekey;
  int materialRequisitionQuotationTermsId;
  int materialRequisitionDetailId;
  String materialCode;
  String materialName;
  String subMaterialName;
  String uomCode;
  String uom;
  double materialQuantity;
  double materialPerUnit;
  String logistics;
  double amount;
  double cgst;
  double sgst;
  double ugst;
  double tgst;
  // THIS VARIABLE IS INCLUSIVE OF ALL TAXES CALCULATION
  double totalAmount;
  MaterialRequisitionQuotation({
    required this.materialRequisitionQuotationId,
    required this.uniquekey,
    required this.materialRequisitionQuotationTermsId,
    required this.materialRequisitionDetailId,
    required this.materialCode,
    required this.materialName,
    required this.subMaterialName,
    required this.uomCode,
    required this.uom,
    required this.materialQuantity,
    required this.materialPerUnit,
    required this.logistics,
    required this.amount,
    required this.cgst,
    required this.sgst,
    required this.ugst,
    required this.tgst,
    this.totalAmount = 0.0,
  });
  factory MaterialRequisitionQuotation.fromJson(Map<String, dynamic> json) =>
      MaterialRequisitionQuotation(
        materialRequisitionQuotationId: parseValue<int>(
          json,
          "MaterialRequisitionQuotationId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        materialRequisitionQuotationTermsId: parseValue<int>(
          json,
          "MaterialRequisitionQuotationTermsId",
        ),
        materialRequisitionDetailId: parseValue<int>(
          json,
          "MaterialRequisitionDetailId",
        ),
        materialCode: parseValue<String>(json, "MaterialCode"),
        materialName: parseValue<String>(json, "MaterialName"),
        subMaterialName: parseValue<String>(json, "SubMaterialName"),
        uomCode: parseValue<String>(json, "UomCode"),
        uom: parseValue<String>(json, "Uom"),
        materialQuantity: parseValue<double>(json, "MaterialQuantity"),
        materialPerUnit: parseValue<double>(json, "MaterialPerUnit"),
        logistics: parseValue<String>(json, "Logistics"),
        amount: parseValue<double>(json, "Amount"),
        cgst: parseValue<double>(json, "CGST"),
        sgst: parseValue<double>(json, "SGST"),
        ugst: parseValue<double>(json, "UGST"),
        tgst: parseValue<double>(json, "TGST"),
      );
  Map<String, dynamic> toJson() => {
    "MaterialRequisitionQuotationId": materialRequisitionQuotationId,
    "Uniquekey": uniquekey,
    "MaterialRequisitionQuotationTermsId": materialRequisitionQuotationTermsId,
    "MaterialRequisitionDetailId": materialRequisitionDetailId,
    "MaterialCode": materialCode,
    "MaterialName": materialName,
    "SubMaterialName": subMaterialName,
    "UomCode": uomCode,
    "Uom": uom,
    "MaterialQuantity": materialQuantity,
    "MaterialPerUnit": materialPerUnit,
    "Logistics": logistics,
    "Amount": amount,
    "CGST": cgst,
    "SGST": sgst,
    "UGST": ugst,
    "TGST": tgst,
  };
}
