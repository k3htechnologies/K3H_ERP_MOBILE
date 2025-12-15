import 'package:k3h_erp_app/utils/common_function.dart';

class ContentFolderModel {
  int marketingContentFolderId;
  String uniquekey;
  int projectId;
  String marketingContentFolderName;
  int numberOfMarketingContent;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  // CUSTOM VARIABLES
  bool isSelected;

  ContentFolderModel({
    required this.marketingContentFolderId,
    required this.uniquekey,
    required this.projectId,
    required this.marketingContentFolderName,
    required this.numberOfMarketingContent,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
    this.isSelected = false,
  });

  factory ContentFolderModel.fromJson(
    Map<String, dynamic> json,
  ) => ContentFolderModel(
    marketingContentFolderId: parseValue<int>(json, "MarketingContentFolderId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    marketingContentFolderName: parseValue<String>(
      json,
      "MarketingContentFolderName",
    ),
    numberOfMarketingContent: parseValue<int>(json, "NumberOfMarketingContent"),
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

  Map<String, dynamic> toJson() => {};
}
