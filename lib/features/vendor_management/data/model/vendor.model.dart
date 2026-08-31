import 'package:k3h_erp_app/features/procurement/data/model/sub_material.model.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class VendorModel {
  int vendorId;
  String uniquekey;
  String systemGeneratedCode;
  String companyName;
  String vendorType;
  String companyType;
  String vendorName;
  String mobileNumberCountryCode;
  String mobileNumber;
  String emailId;
  String aadharCardNumber;
  String aadharCardUrl;
  String panCardNumber;
  String panCardUrl;
  String gstNumber;
  String gstCertificateUrl;
  String address;
  int countryMasterId;
  String countryName;
  int stateMasterId;
  String stateName;
  int districtMasterId;
  String districtName;
  int cityMasterId;
  String cityName;
  int villageMasterId;
  String villageName;
  List<SubMaterialModel> submaterialList;
  List<String> contractList;
  String verifiedNonVerified;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  VendorModel({
    required this.vendorId,
    required this.uniquekey,
    required this.systemGeneratedCode,
    required this.companyName,
    required this.vendorType,
    required this.companyType,
    required this.vendorName,
    required this.mobileNumberCountryCode,
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
    required this.villageMasterId,
    required this.villageName,
    required this.submaterialList,
    required this.contractList,
    required this.verifiedNonVerified,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
    vendorId: parseValue<int>(json, "VendorId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    companyName: parseValue<String>(json, "CompanyName"),
    vendorType: parseValue<String>(json, "VendorType"),
    companyType: parseValue<String>(json, "CompanyType"),
    vendorName: parseValue<String>(json, "VendorName"),
    mobileNumberCountryCode: parseValue<String>(
      json,
      "MobileNumberCountryCode",
    ),
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
    villageMasterId: parseValue(json, "VillageMasterId"),
    villageName: parseValue<String>(json, "VillageName"),
    submaterialList: List<SubMaterialModel>.from(
      json["SubMaterialMasterData"].map((x) => SubMaterialModel.fromJson(x)),
    ),
    contractList: List<String>.from(
      json["ContractTypeMasterData"].map((x) => x),
    ),
    verifiedNonVerified: parseValue<String>(json, "VerifiedNonVerified"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : DateTime.parse(json["ModifiedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "VendorId": vendorId,
    "Uniquekey": uniquekey,
    "SystemGeneratedCode": systemGeneratedCode,
    "CompanyName": companyName,
    "VendorType": vendorType,
    "CompanyType": companyType,
    "VendorName": vendorName,
    "MobileNumberCountryCode": mobileNumberCountryCode,
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
    "VillageMasterId": villageMasterId,
    "VillageName": villageName,
    "SubMaterialMasterData": List<SubMaterialModel>.from(
      submaterialList.map((x) => x),
    ),
    "ContractTypeMasterData": List<dynamic>.from(contractList.map((x) => x)),
    "VerifiedNonVerified": verifiedNonVerified,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
