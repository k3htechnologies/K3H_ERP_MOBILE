import 'package:k3h_erp_app/utils/functions/common_function.dart';

class SnagChecklistModel {
  int snagCheckListId;
  String uniqueKey;
  int projectId;
  int bookingId;
  String categoryName;
  String subCategoryName;
  String title;
  String tags;
  String checkFor;
  bool isCheck;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  SnagChecklistModel({
    required this.snagCheckListId,
    required this.uniqueKey,
    required this.projectId,
    required this.bookingId,
    required this.categoryName,
    required this.subCategoryName,
    required this.title,
    required this.tags,
    required this.checkFor,
    required this.isCheck,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory SnagChecklistModel.fromJson(Map<String, dynamic> json) =>
      SnagChecklistModel(
        snagCheckListId: parseValue<int>(json, "SnagCheckListId"),
        uniqueKey: parseValue<String>(json, "UniqueKey"),
        projectId: parseValue<int>(json, "ProjectId"),
        bookingId: parseValue<int>(json, "BookingId"),
        categoryName: parseValue<String>(json, "CategoryName"),
        subCategoryName: parseValue<String>(json, "SubCategoryName"),
        title: parseValue<String>(json, "Title"),
        tags: parseValue<String>(json, "Tags"),
        checkFor: parseValue<String>(json, "CheckFor"),
        isCheck: parseValue<bool>(json, "IsCheck"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate:
            json["CreatedDate"] != null
                ? DateTime.parse(json["CreatedDate"])
                : null,
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] != null
                ? DateTime.parse(json["ModifiedDate"])
                : null,
      );

  Map<String, dynamic> toJson() => {
    "SnagCheckListId": snagCheckListId,
    "UniqueKey": uniqueKey,
    "ProjectId": projectId,
    "BookingId": bookingId,
    "CategoryName": categoryName,
    "SubCategoryName": subCategoryName,
    "Title": title,
    "Tags": tags,
    "CheckFor": checkFor,
    "IsCheck": isCheck,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
