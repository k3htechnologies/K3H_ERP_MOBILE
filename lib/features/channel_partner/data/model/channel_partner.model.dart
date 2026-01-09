import 'package:k3h_erp_app/utils/common_function.dart';

class ChannelPartnerModel {
  final int channelPartnerId;
  final String uniquekey;
  final String name;
  final String emailId;
  final String mobileNumber;
  final String alternativeMobileNumber;
  final String panNumber;
  final String panCardUrl;
  final String adharCardNumber;
  final String adharCardUrl;
  final String companyName;
  final String reraNumber;
  final String gstNumber;
  final String speciality;
  final String officeAddress;
  final String villageMasterId;
  final String villageName;
  final String projectId;
  final String projectName;
  final int createdById;
  final String createdBy;
  final DateTime createdDate;
  final int modifiedById;
  final String modifiedBy;
  final DateTime? modifiedDate;

  ChannelPartnerModel({
    required this.channelPartnerId,
    required this.uniquekey,
    required this.name,
    required this.emailId,
    required this.mobileNumber,
    required this.alternativeMobileNumber,
    required this.panNumber,
    required this.panCardUrl,
    required this.adharCardNumber,
    required this.adharCardUrl,
    required this.companyName,
    required this.reraNumber,
    required this.gstNumber,
    required this.speciality,
    required this.officeAddress,
    required this.villageMasterId,
    required this.villageName,
    required this.projectId,
    required this.projectName,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
  });

  factory ChannelPartnerModel.fromJson(Map<String, dynamic> json) =>
      ChannelPartnerModel(
        channelPartnerId: parseValue<int>(json, "ChannelPartnerId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        name: parseValue<String>(json, "Name"),
        emailId: parseValue<String>(json, "EmailId"),
        mobileNumber: parseValue<String>(json, "MobileNumber"),
        alternativeMobileNumber: parseValue<String>(
          json,
          "AlternativeMobileNumber",
        ),
        panNumber: parseValue<String>(json, "PanNumber"),
        panCardUrl: parseValue<String>(json, "PanCardURL"),
        adharCardNumber: parseValue<String>(json, "AdharCardNumber"),
        adharCardUrl: parseValue<String>(json, "AdharCardURL"),
        companyName: parseValue<String>(json, "CompanyName"),
        reraNumber: parseValue<String>(json, "RERANumber"),
        gstNumber: parseValue<String>(json, "GSTNumber"),
        speciality: parseValue<String>(json, "Speciality"),
        officeAddress: parseValue<String>(json, "OfficeAddress"),
        villageMasterId: parseValue<String>(json, "VillageMasterId"),
        villageName: parseValue<String>(json, "VillageName"),
        projectId: parseValue<String>(json, "ProjectId"),
        projectName: parseValue<String>(json, "ProjectName"),
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
    "ChannelPartnerId": channelPartnerId,
    "Uniquekey": uniquekey,
    "Name": name,
    "EmailId": emailId,
    "MobileNumber": mobileNumber,
    "AlternativeMobileNumber": alternativeMobileNumber,
    "PanNumber": panNumber,
    "PanCardURL": panCardUrl,
    "AdharCardNumber": adharCardNumber,
    "AdharCardURL": adharCardUrl,
    "CompanyName": companyName,
    "RERANumber": reraNumber,
    "GSTNumber": gstNumber,
    "Speciality": speciality,
    "OfficeAddress": officeAddress,
    "VillageMasterId": villageMasterId,
    "VillageName": villageName,
    "ProjectId": projectId,
    "ProjectName": projectName,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
