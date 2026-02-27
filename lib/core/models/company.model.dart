import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

class CompanyModel {
  int companyId;
  String uniquekey;
  String companyName;
  String firmsType;
  String contactPerson;
  String mobileNumber;
  String landLineNumber;
  String gstNumber;
  String gstCertificateURL;
  String cinNumber;
  String cinURL;
  String panNumber;
  String panCardURL;
  String tanNumber;
  String emailId;
  int countryMasterId;
  String countryName;
  int stateMasterId;
  String stateName;
  int districtMasterId;
  String districtName;
  int cityMasterId;
  String cityName;
  String companyLetterheadHeaderURL;
  String companyLetterheadFooterURL;
  String tanURL;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  List<CompanyPartnerModel> companyPartnerData;
  bool isSelected;
  // VARIABLE USED IN PROJECT MASTER FOR HANDLING THE STATE OF SELECTED EMPLOYEE

  CompanyModel({
    required this.companyId,
    required this.uniquekey,
    required this.companyName,
    required this.firmsType,
    required this.contactPerson,
    required this.mobileNumber,
    required this.landLineNumber,
    required this.gstNumber,
    required this.gstCertificateURL,
    required this.cinNumber,
    required this.cinURL,
    required this.panNumber,
    required this.panCardURL,
    required this.tanNumber,
    required this.emailId,
    required this.countryMasterId,
    required this.countryName,
    required this.stateMasterId,
    required this.stateName,
    required this.districtMasterId,
    required this.districtName,
    required this.cityMasterId,
    required this.cityName,
    required this.companyLetterheadHeaderURL,
    required this.companyLetterheadFooterURL,
    required this.tanURL,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.companyPartnerData,
    this.isSelected = false
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
      companyId: parseValue<int>(json, "CompanyId"),
      uniquekey: parseValue<String>(json, "Uniquekey"),
      companyName: parseValue<String>(json, "CompanyName"),
      firmsType: parseValue<String>(json, "FirmsType"),
      contactPerson: parseValue<String>(json, "ContactPerson"),
      mobileNumber: parseValue<String>(json, "MobileNumber"),
      landLineNumber: parseValue<String>(json, "LandLineNumber"),
      gstNumber: parseValue<String>(json, "GSTNumber"),
      gstCertificateURL: parseValue<String>(json, "GSTCertificateURL"),
      cinNumber: parseValue<String>(json, "CINNumber"),
      cinURL: parseValue<String>(json, "CINURL"),
      panNumber: parseValue<String>(json, "PANNumber"),
      panCardURL: parseValue<String>(json, "PanCardURL"),
      tanNumber: parseValue<String>(json, "TANNumber"),
      tanURL: parseValue<String>(json, "TANURL"),
      emailId: parseValue<String>(json, "EmailId"),
      countryMasterId: parseValue<int>(json, "CountryMasterId"),
      countryName: parseValue<String>(json, "CountryName"),
      stateMasterId: parseValue<int>(json, "StateMasterId"),
      stateName: parseValue<String>(json, "StateName"),
      districtMasterId: parseValue<int>(json, "DistrictMasterId"),
      districtName: parseValue<String>(json, "DistrictName"),
      cityMasterId: parseValue<int>(json, "CityMasterId"),
      cityName: parseValue<String>(json, "CityName"),
      companyLetterheadHeaderURL: parseValue<String>(
        json,
        "CompanyLetterheadHeaderURL",
      ),
      companyLetterheadFooterURL: parseValue<String>(
        json,
        "CompanyLetterheadFooterURL",
      ),
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate: parseValue<DateTime>(json, "CreatedDate"),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate:
      json["ModifiedDate"] == null
          ? null
          : parseValue<DateTime>(json, "ModifiedDate"),
      companyPartnerData:
      (json["CompanyPartnerData"] as List<dynamic>?)
          ?.map(
            (e) => CompanyPartnerModel.fromJson(e as Map<String, dynamic>),
      )
          .toList() ??
          [],
      isSelected: false
  );

  Map<String, dynamic> toJson() => {
    "CompanyId": companyId,
    "Uniquekey": uniquekey,
    "CompanyName": companyName,
    "FirmsType": firmsType,
    "ContactPerson": contactPerson,
    "MobileNumber": mobileNumber,
    "LandLineNumber": landLineNumber,
    "GSTNumber": gstNumber,
    "GSTCertificateURL": gstCertificateURL,
    "CINNumber": cinNumber,
    "CINURL": cinURL,
    "PANNumber": panNumber,
    "PanCardURL": panCardURL,
    "TANNumber": tanNumber,
    "TANURL": tanURL,
    "EmailId": emailId,
    "CountryMasterId": countryMasterId,
    "CountryName": countryName,
    "StateMasterId": stateMasterId,
    "StateName": stateName,
    "DistrictMasterId": districtMasterId,
    "DistrictName": districtName,
    "CityMasterId": cityMasterId,
    "CityName": cityName,
    "CompanyLetterheadHeaderURL": companyLetterheadHeaderURL,
    "CompanyLetterheadFooterURL": companyLetterheadFooterURL,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "CompanyPartnerData": companyPartnerData.map((e) => e.toJson()).toList(),
  };
}

class CompanyPartnerModel {
  int companyPartnerId;
  String uniquekey;
  int companyId;
  String firstName;
  String lastName;
  String middleName;
  String fullName;
  DateTime dateOfBirth;
  String gender;
  String mobileNumber;
  String emailId;
  double partnerPercentage;
  String panNumber;
  String panCardURL;
  String aadharCardNumber;
  String aadharCardURL;
  String photoURL;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  // THIS HAS BEEN ADDED ONLY TO SELECT THE FILE DATA
  MultiFilePickerModel? aadharCardFile;
  MultiFilePickerModel? panCardFile;
  MultiFilePickerModel? photoFile;

  CompanyPartnerModel({
    required this.companyPartnerId,
    required this.uniquekey,
    required this.companyId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.mobileNumber,
    required this.emailId,
    required this.partnerPercentage,
    required this.panNumber,
    required this.panCardURL,
    required this.aadharCardNumber,
    required this.aadharCardURL,
    required this.photoURL,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    this.aadharCardFile,
    this.panCardFile,
    this.photoFile,
  });

  factory CompanyPartnerModel.fromJson(Map<String, dynamic> json) =>
      CompanyPartnerModel(
        companyPartnerId: parseValue<int>(json, "CompanyPartnerId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        companyId: parseValue<int>(json, "CompanyId"),
        firstName: parseValue<String>(json, "FirstName"),
        lastName: parseValue<String>(json, "LastName"),
        middleName: parseValue<String>(json, "MiddleName"),
        fullName: parseValue<String>(json, "FullName"),
        dateOfBirth: parseValue<DateTime>(json, "DateOfBirth"),
        gender: parseValue<String>(json, "Gender"),
        mobileNumber: parseValue<String>(json, "MobileNumber"),
        emailId: parseValue<String>(json, "EmailId"),
        partnerPercentage: parseValue<double>(json, "PartnerPercentage"),
        panNumber: parseValue<String>(json, "PanNumber"),
        panCardURL: parseValue<String>(json, "PanCardURL"),
        aadharCardNumber: parseValue<String>(json, "AadharCardNumber"),
        aadharCardURL: parseValue<String>(json, "AadharCardURL"),
        photoURL: parseValue<String>(json, "PhotoURL"),
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
    "CompanyPartnerId": companyPartnerId,
    "Uniquekey": uniquekey,
    "CompanyId": companyId,
    "FirstName": firstName,
    "LastName": lastName,
    "MiddleName": middleName,
    "FullName": fullName,
    "DateOfBirth": dateOfBirth.toIso8601String(),
    "Gender": gender,
    "MobileNumber": mobileNumber,
    "EmailId": emailId,
    "PartnerPercentage": partnerPercentage,
    "PanNumber": panNumber,
    "PanCardURL": panCardURL,
    "AadharCardNumber": aadharCardNumber,
    "AadharCardURL": aadharCardURL,
    "PhotoURL": photoURL,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}