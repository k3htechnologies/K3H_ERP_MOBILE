import 'package:k3h_erp_app/utils/common_function.dart';

class ContentDocumentModel {
  int marketingContentId;
  String uniquekey;
  int projectId;
  int marketingContentFolderId;
  String marketingContentFolderName;
  String title;
  String remark;
  String marketingContentURL;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ContentDocumentModel({
    required this.marketingContentId,
    required this.uniquekey,
    required this.projectId,
    required this.marketingContentFolderId,
    required this.marketingContentFolderName,
    required this.title,
    required this.remark,
    required this.marketingContentURL,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
  });

  factory ContentDocumentModel.fromJson(Map<String, dynamic> json) =>
      ContentDocumentModel(
        marketingContentId: parseValue<int>(json, "MarketingContentId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        marketingContentFolderId: parseValue<int>(
          json,
          "MarketingContentFolderId",
        ),
        marketingContentFolderName: parseValue<String>(
          json,
          "MarketingContentFolderName",
        ),
        title: parseValue<String>(json, "Title"),
        remark: parseValue<String>(json, "Remark"),
        marketingContentURL: parseValue<String>(json, "MarketingContentURL"),
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
