import 'package:k3h_erp_app/utils/common_function.dart';

class FinalizeVendorForComparisonModel {
  final int vendorId;
  final String uniquekey;
  final String companyName;
  final String companyType;
  final String vendorName;
  final String mobileNumber;
  final String emailId;
  final String aadharCardNumber;
  final String aadharCardUrl;
  final String panCardNumber;
  final String panCardUrl;
  final String gstNumber;
  final String gstCertificateUrl;
  final String address;
  final int countryMasterId;
  final String countryName;
  final int stateMasterId;
  final String stateName;
  final int districtMasterId;
  final String districtName;
  final int cityMasterId;
  final String cityName;
  final String availableMaterialList;
  final String availableContractList;
  final int createdById;
  final String createdBy;
  final DateTime? createdDate;
  final int modifiedById;
  final String modifiedBy;
  final DateTime? modifiedDate;
  final bool isApproval;
  final bool isFinalized;
  final String vendorFinalizationApproval;
  final List<MaterialRequisitionQuotationTermsDatum>
  materialRequisitionQuotationTermsData;
  final List<dynamic> subMaterialMasterData;
  final List<dynamic> contractTypeMasterData;
  final String magicLinkUrl;
  final String systemGeneratedCode;
  final String projectName;
  final double? paidAmount;
  final double? totalPoAmount;
  final double? totalInvoiceAmount;
  final double? totalInvoice;

  FinalizeVendorForComparisonModel({
    required this.vendorId,
    required this.uniquekey,
    required this.companyName,
    required this.companyType,
    required this.vendorName,
    required this.mobileNumber,
    required this.emailId,
    required this.aadharCardNumber,
    required this.aadharCardUrl,
    required this.panCardNumber,
    required this.panCardUrl,
    required this.gstNumber,
    required this.gstCertificateUrl,
    required this.address,
    required this.countryMasterId,
    required this.countryName,
    required this.stateMasterId,
    required this.stateName,
    required this.districtMasterId,
    required this.districtName,
    required this.cityMasterId,
    required this.cityName,
    required this.availableMaterialList,
    required this.availableContractList,
    required this.createdById,
    required this.createdBy,
    this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
    required this.isApproval,
    required this.isFinalized,
    required this.vendorFinalizationApproval,
    required this.materialRequisitionQuotationTermsData,
    required this.subMaterialMasterData,
    required this.contractTypeMasterData,
    required this.magicLinkUrl,
    required this.systemGeneratedCode,
    required this.projectName,
    required this.paidAmount,
    required this.totalPoAmount,
    required this.totalInvoiceAmount,
    required this.totalInvoice,
  });

  factory FinalizeVendorForComparisonModel.fromJson(
    Map<String, dynamic> json,
  ) => FinalizeVendorForComparisonModel(
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
    countryMasterId: parseValue<int>(json, "CountryMasterId"),
    countryName: parseValue<String>(json, "CountryName"),
    stateMasterId: parseValue<int>(json, "StateMasterId"),
    stateName: parseValue<String>(json, "StateName"),
    districtMasterId: parseValue<int>(json, "DistrictMasterId"),
    districtName: parseValue<String>(json, "DistrictName"),
    cityMasterId: parseValue<int>(json, "CityMasterId"),
    cityName: parseValue<String>(json, "CityName"),
    availableMaterialList: parseValue<String>(json, "AvailableMaterialList"),
    availableContractList: parseValue<String>(json, "AvailableContractList"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate: parseValue<DateTime>(json, "ModifiedDate"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    isFinalized: parseValue<bool>(json, "IsFinalized"),
    vendorFinalizationApproval: parseValue<String>(
      json,
      "VendorFinalizationApproval",
    ),
    materialRequisitionQuotationTermsData:
        List<MaterialRequisitionQuotationTermsDatum>.from(
          json["MaterialRequisitionQuotationTermsData"].map(
            (x) => MaterialRequisitionQuotationTermsDatum.fromJson(x),
          ),
        ),
    subMaterialMasterData: List<dynamic>.from(
      json["SubMaterialMasterData"].map((x) => x),
    ),
    contractTypeMasterData: List<dynamic>.from(
      json["ContractTypeMasterData"].map((x) => x),
    ),
    magicLinkUrl: json["MagicLinkURL"],
    systemGeneratedCode: json["SystemGeneratedCode"],
    projectName: json["ProjectName"],
    paidAmount: json["PaidAmount"],
    totalPoAmount: json["TotalPoAmount"],
    totalInvoiceAmount: json["TotalInvoiceAmount"],
    totalInvoice: json["TotalInvoice"],
  );

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
    "AvailableMaterialList": availableMaterialList,
    "AvailableContractList": availableContractList,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
    "IsApproval": isApproval,
    "IsFinalized": isFinalized,
    "VendorFinalizationApproval": vendorFinalizationApproval,
    "MaterialRequisitionQuotationTermsData": List<dynamic>.from(
      materialRequisitionQuotationTermsData.map((x) => x.toJson()),
    ),
    "SubMaterialMasterData": List<dynamic>.from(
      subMaterialMasterData.map((x) => x),
    ),
    "ContractTypeMasterData": List<dynamic>.from(
      contractTypeMasterData.map((x) => x),
    ),
    "MagicLinkURL": magicLinkUrl,
    "SystemGeneratedCode": systemGeneratedCode,
    "ProjectName": projectName,
    "PaidAmount": paidAmount,
    "TotalPoAmount": totalPoAmount,
    "TotalInvoiceAmount": totalInvoiceAmount,
    "TotalInvoice": totalInvoice,
  };
}

class MaterialRequisitionQuotationTermsDatum {
  final int materialRequisitionQuotationTermsId;
  final String uniquekey;
  final int materialRequisitionId;
  final int vendorId;
  final double expectedDeliveryInDays;
  final double expectedPaymentInDays;
  final double total;
  final List<MaterialRequisitionQuotationDatum>
  materialRequisitionQuotationData;
  final String systemGeneratedCode;
  final String projectName;
  final String companyName;
  final String vendorName;
  final String mobileNumber;
  final String emailId;

  MaterialRequisitionQuotationTermsDatum({
    required this.materialRequisitionQuotationTermsId,
    required this.uniquekey,
    required this.materialRequisitionId,
    required this.vendorId,
    required this.expectedDeliveryInDays,
    required this.expectedPaymentInDays,
    required this.total,
    required this.materialRequisitionQuotationData,
    required this.systemGeneratedCode,
    required this.projectName,
    required this.companyName,
    required this.vendorName,
    required this.mobileNumber,
    required this.emailId,
  });

  factory MaterialRequisitionQuotationTermsDatum.fromJson(
    Map<String, dynamic> json,
  ) => MaterialRequisitionQuotationTermsDatum(
    materialRequisitionQuotationTermsId: parseValue<int>(
      json,
      "MaterialRequisitionQuotationTermsId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    materialRequisitionId: parseValue<int>(json, "MaterialRequisitionId"),
    vendorId: parseValue<int>(json, "VendorId"),
    expectedDeliveryInDays:
        parseValue<double>(json, "ExpectedDeliveryInDays").toDouble(),
    expectedPaymentInDays:
        parseValue<double>(json, "ExpectedPaymentInDays").toDouble(),
    total: parseValue<double>(json, "Total").toDouble(),
    materialRequisitionQuotationData:
        List<MaterialRequisitionQuotationDatum>.from(
          json["MaterialRequisitionQuotationData"].map(
            (x) => MaterialRequisitionQuotationDatum.fromJson(x),
          ),
        ),
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    projectName: parseValue<String>(json, "ProjectName"),
    companyName: parseValue<String>(json, "CompanyName"),
    vendorName: parseValue<String>(json, "VendorName"),
    mobileNumber: parseValue<String>(json, "MobileNumber"),
    emailId: parseValue<String>(json, "EmailId"),
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
    "SystemGeneratedCode": systemGeneratedCode,
    "ProjectName": projectName,
    "CompanyName": companyName,
    "VendorName": vendorName,
    "MobileNumber": mobileNumber,
    "EmailId": emailId,
  };
}

class MaterialRequisitionQuotationDatum {
  final int materialRequisitionQuotationId;
  final String uniquekey;
  final int materialRequisitionQuotationTermsId;
  final int materialRequisitionDetailId;
  final String materialCode;
  final String materialName;
  final String subMaterialName;
  final String uomCode;
  final String uom;
  final double materialQuantity;
  final double materialPerUnit;
  final String logistics;
  final double amount;
  final double cgst;
  final double sgst;
  final double ugst;
  final double tgst;

  MaterialRequisitionQuotationDatum({
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
  });

  factory MaterialRequisitionQuotationDatum.fromJson(
    Map<String, dynamic> json,
  ) => MaterialRequisitionQuotationDatum(
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
    materialQuantity: parseValue<double>(json, "MaterialQuantity").toDouble(),
    materialPerUnit: parseValue<double>(json, "MaterialPerUnit").toDouble(),
    logistics: parseValue<String>(json, "Logistics"),
    amount: parseValue<double>(json, "Amount").toDouble(),
    cgst: parseValue<double>(json, "CGST").toDouble(),
    sgst: parseValue<double>(json, "SGST").toDouble(),
    ugst: parseValue<double>(json, "UGST").toDouble(),
    tgst: parseValue<double>(json, "TGST").toDouble(),
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
