import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ChannelPartnerCategoryModel {
  final int projectId;
  final int channelPartnerCatgoryId;
  final String uniquekey;
  final String categoryName;
  final double bookingRevenue;
  final int noOfEnquiry;
  final int createdById;
  final String createdBy;
  final DateTime createdDate;
  final int modifiedById;
  final String modifiedBy;
  final DateTime? modifiedDate;

  const ChannelPartnerCategoryModel({
    required this.projectId,
    required this.channelPartnerCatgoryId,
    required this.uniquekey,
    required this.categoryName,
    required this.bookingRevenue,
    required this.noOfEnquiry,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
  });

  factory ChannelPartnerCategoryModel.fromJson(Map<String, dynamic> json) =>
      ChannelPartnerCategoryModel(
        projectId: parseValue<int>(json, "ProjectId"),
        channelPartnerCatgoryId: parseValue<int>(
          json,
          "ChannelPartnerCategoryId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        categoryName: parseValue<String>(json, "CategoryName"),
        bookingRevenue: parseValue<double>(json, "BookingRevenue"),
        noOfEnquiry: parseValue<int>(json, "NoOfEnquirys"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] != null
                ? DateTime.parse(json["ModifiedDate"])
                : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    "ProjectId": projectId,
    "ChannelPartnerCategoryId": channelPartnerCatgoryId,
    "Uniquekey": uniquekey,
    "CategoryName": categoryName,
    "BookingRevenue": bookingRevenue,
    "NoOfEnquirys": noOfEnquiry,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
