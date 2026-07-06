import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BrokerageModel {
  int bookingId;
  String uniquekey;
  int projectId;
  String projectName;
  String projectLocation;
  String applicantName;
  String applicantMobileNumber;
  String channelPartnerName;
  String channelPartnerCompany;
  String channelPartnerMobileNumber;
  int brokeragePercentage;
  double brokerageAmount;
  double paidBrokerageAmount;
  int inventoryFlatId;
  String buildingNumber;
  String wing;
  String floor;
  String flat;
  String flatType;
  int reraCarpetAreaSqFt;
  String flatConfiguration;
  int agreementValue;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BrokerageModel({
    required this.bookingId,
    required this.uniquekey,
    required this.projectId,
    required this.projectName,
    required this.projectLocation,
    required this.applicantName,
    required this.applicantMobileNumber,
    required this.channelPartnerName,
    required this.channelPartnerCompany,
    required this.channelPartnerMobileNumber,
    required this.brokeragePercentage,
    required this.brokerageAmount,
    required this.paidBrokerageAmount,
    required this.inventoryFlatId,
    required this.buildingNumber,
    required this.wing,
    required this.floor,
    required this.flat,
    required this.flatType,
    required this.reraCarpetAreaSqFt,
    required this.flatConfiguration,
    required this.agreementValue,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BrokerageModel.fromJson(Map<String, dynamic> json) => BrokerageModel(
    bookingId: parseValue<int>(json, "BookingId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    projectName: parseValue<String>(json, "ProjectName"),
    projectLocation: parseValue<String>(json, "ProjectLocation"),
    applicantName: parseValue<String>(json, "ApplicantName"),
    applicantMobileNumber: parseValue<String>(json, "ApplicantMobileNumber"),
    channelPartnerName: parseValue<String>(json, "ChannelPartnerName"),
    channelPartnerCompany: parseValue<String>(json, "ChannelPartnerCompany"),
    channelPartnerMobileNumber: parseValue<String>(
      json,
      "ChannelPartnerMobileNumber",
    ),
    brokeragePercentage: parseValue<int>(json, "BrokeragePercentage"),
    brokerageAmount: parseValue<double>(json, "BrokerageAmount"),
    paidBrokerageAmount: parseValue<double>(json, "PaidBrokerageAmount"),
    inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),
    buildingNumber: parseValue<String>(json, "BuildingNumber"),
    wing: parseValue<String>(json, "Wing"),
    floor: parseValue<String>(json, "Floor"),
    flat: parseValue<String>(json, "Flat"),
    flatType: parseValue<String>(json, "FlatType"),
    reraCarpetAreaSqFt: parseValue<int>(json, "RERACarpetAreaSqFt"),
    flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
    agreementValue: parseValue<int>(json, "AgreementValue"),
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
    "BookingId": bookingId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ProjectName": projectName,
    "ProjectLocation": projectLocation,
    "ApplicantName": applicantName,
    "ApplicantMobileNumber": applicantMobileNumber,
    "ChannelPartnerName": channelPartnerName,
    "ChannelPartnerCompany": channelPartnerCompany,
    "ChannelPartnerMobileNumber": channelPartnerMobileNumber,
    "BrokeragePercentage": brokeragePercentage,
    "BrokerageAmount": brokerageAmount,
    "PaidBrokerageAmount": paidBrokerageAmount,
    "InventoryFlatId": inventoryFlatId,
    "BuildingNumber": buildingNumber,
    "Wing": wing,
    "Floor": floor,
    "Flat": flat,
    "FlatType": flatType,
    "RERACarpetAreaSqFt": reraCarpetAreaSqFt,
    "FlatConfiguration": flatConfiguration,
    "AgreementValue": agreementValue,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
