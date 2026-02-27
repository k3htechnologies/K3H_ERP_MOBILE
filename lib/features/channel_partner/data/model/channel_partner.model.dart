import 'package:k3h_erp_app/utils/common_function.dart';

class ChannelPartnerModel {
  final int channelPartnerId;
  final String uniquekey;
  final String systemGeneratedCode;
  final String name;
  final String emailId;
  final String mobileNumber;
  final String alternativeMobileNumber;
  final String panNumber;
  final String panCardUrl;
  final String aadharCardNumber;
  final String aadharCardUrl;
  final String gstCertificateUrl;
  final String companyName;
  final String firmsType;
  final String designation;
  final String type;
  final String reraNumber;
  final String gstNumber;
  final String speciality;
  final String officeAddress;
  final int countryMasterId;
  final String countryName;
  final int districtMasterId;
  final String districtName;
  final int stateMasterId;
  final String stateName;
  final int cityMasterId;
  final String cityName;
  final int villageMasterId;
  final String villageName;
  final int createdById;
  final String createdBy;
  final DateTime createdDate;
  final int modifiedById;
  final String modifiedBy;
  final DateTime? modifiedDate;
  final int noOfEnquiry;
  final int noOfBooking;
  final int brokeragePercentage;
  final double brokerageAmount;
  final double paidBrokerageAmount;

  ChannelPartnerModel({
    required this.channelPartnerId,
    required this.uniquekey,
    required this.systemGeneratedCode,
    required this.name,
    required this.emailId,
    required this.mobileNumber,
    required this.alternativeMobileNumber,
    required this.panNumber,
    required this.panCardUrl,
    required this.aadharCardNumber,
    required this.aadharCardUrl,
    required this.gstCertificateUrl,
    required this.companyName,
    required this.firmsType,
    required this.designation,
    required this.type,
    required this.reraNumber,
    required this.gstNumber,
    required this.speciality,
    required this.officeAddress,
    required this.countryMasterId,
    required this.countryName,
    required this.districtMasterId,
    required this.districtName,
    required this.stateMasterId,
    required this.stateName,
    required this.cityMasterId,
    required this.cityName,
    required this.villageMasterId,
    required this.villageName,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
    required this.noOfEnquiry,
    required this.noOfBooking,
    required this.brokeragePercentage,
    required this.brokerageAmount,
    required this.paidBrokerageAmount,
  });

  factory ChannelPartnerModel.fromJson(Map<String, dynamic> json) =>
      ChannelPartnerModel(
        channelPartnerId: parseValue<int>(json, "ChannelPartnerId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
        name: parseValue<String>(json, "Name"),
        emailId: parseValue<String>(json, "EmailId"),
        mobileNumber: parseValue<String>(json, "MobileNumber"),
        alternativeMobileNumber: parseValue<String>(
          json,
          "AlternativeMobileNumber",
        ),
        panNumber: parseValue<String>(json, "PanNumber"),
        panCardUrl: parseValue<String>(json, "PanCardURL"),
        aadharCardNumber: parseValue<String>(json, "AadharCardNumber"),
        aadharCardUrl: parseValue<String>(json, "AadharCardURL"),
        gstCertificateUrl: parseValue<String>(json, "GSTCertificateURL"),
        companyName: parseValue<String>(json, "CompanyName"),
        firmsType: parseValue<String>(json, "FirmsType"),
        designation: parseValue<String>(json, "Designation"),
        type: parseValue<String>(json, "Type"),
        reraNumber: parseValue<String>(json, "RERANumber"),
        gstNumber: parseValue<String>(json, "GSTNumber"),
        speciality: parseValue<String>(json, "Speciality"),
        officeAddress: parseValue<String>(json, "OfficeAddress"),
        countryMasterId: parseValue<int>(json, "CountryMasterId"),
        countryName: parseValue<String>(json, "CountryName"),
        districtMasterId: parseValue<int>(json, "DistrictMasterId"),
        districtName: parseValue<String>(json, "DistrictName"),
        stateMasterId: parseValue<int>(json, "StateMasterId"),
        stateName: parseValue<String>(json, "StateName"),
        cityMasterId: parseValue<int>(json, "CityMasterId"),
        cityName: parseValue<String>(json, "CityName"),
        villageMasterId: parseValue<int>(json, "VillageMasterId"),
        villageName: parseValue<String>(json, "VillageName"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate: parseValue<DateTime>(json, "ModifiedDate"),
        noOfEnquiry: parseValue<int>(json, "NoOfEnquiry"),
        noOfBooking: parseValue<int>(json, "NoOfBooking"),
        brokeragePercentage: parseValue<int>(json, "BrokeragePercentage"),
        brokerageAmount: parseValue<double>(json, "BrokerageAmount").toDouble(),
        paidBrokerageAmount:
            parseValue<double>(json, "PaidBrokerageAmount").toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "ChannelPartnerId": channelPartnerId,
    "Uniquekey": uniquekey,
    "SystemGeneratedCode": systemGeneratedCode,
    "Name": name,
    "EmailId": emailId,
    "MobileNumber": mobileNumber,
    "AlternativeMobileNumber": alternativeMobileNumber,
    "PanNumber": panNumber,
    "PanCardURL": panCardUrl,
    "GSTCertificateURL": gstCertificateUrl,
    "AadharCardNumber": aadharCardNumber,
    "AadharCardURL": aadharCardUrl,
    "CompanyName": companyName,
    "FirmsType": firmsType,
    "Designation": designation,
    "Type": type,
    "RERANumber": reraNumber,
    "GSTNumber": gstNumber,
    "Speciality": speciality,
    "OfficeAddress": officeAddress,
    "CountryMasterId": countryMasterId,
    "CountryName": countryName,
    "DistrictMasterId": districtMasterId,
    "DistrictName": districtName,
    "StateMasterId": stateMasterId,
    "StateName": stateName,
    "CityMasterId": cityMasterId,
    "CityName": cityName,
    "VillageMasterId": villageMasterId,
    "VillageName": villageName,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "NoOfEnquiry": noOfEnquiry,
    "NoOfBooking": noOfBooking,
    "BrokeragePercentage": brokeragePercentage,
    "BrokerageAmount": brokerageAmount,
    "PaidBrokerageAmount": paidBrokerageAmount,
  };
}
