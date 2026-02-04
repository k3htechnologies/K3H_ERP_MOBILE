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

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime(1970);
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed ?? DateTime(1970);
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime(1970);
  }

  factory ContentDocumentModel.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return ContentDocumentModel(
        marketingContentId: 0,
        uniquekey: "",
        projectId: 0,
        marketingContentFolderId: 0,
        marketingContentFolderName: "",
        title: "",
        remark: "",
        marketingContentURL: "",
        createdById: 0,
        createdBy: "",
        createdDate: DateTime(1970),
        modifiedById: 0,
        modifiedBy: "",
        modifiedDate: null,
      );
    }
    final map = json;
    if (map.isEmpty) {
      return ContentDocumentModel(
        marketingContentId: 0,
        uniquekey: "",
        projectId: 0,
        marketingContentFolderId: 0,
        marketingContentFolderName: "",
        title: "",
        remark: "",
        marketingContentURL: "",
        createdById: 0,
        createdBy: "",
        createdDate: DateTime(1970),
        modifiedById: 0,
        modifiedBy: "",
        modifiedDate: null,
      );
    }
    return ContentDocumentModel(
      marketingContentId: parseValue<int>(map, "MarketingContentId"),
      uniquekey: parseValue<String>(map, "Uniquekey"),
      projectId: parseValue<int>(map, "ProjectId"),
      marketingContentFolderId: parseValue<int>(
        map,
        "MarketingContentFolderId",
      ),
      marketingContentFolderName: parseValue<String>(
        map,
        "MarketingContentFolderName",
      ),
      title: parseValue<String>(map, "Title"),
      remark: parseValue<String>(map, "Remark"),
      marketingContentURL: parseValue<String>(map, "MarketingContentURL"),
      createdById: parseValue<int>(map, "CreatedById"),
      createdBy: parseValue<String>(map, "CreatedBy"),
      createdDate: _parseDateTime(map["CreatedDate"]),
      modifiedById: parseValue<int>(map, "ModifiedById"),
      modifiedBy: parseValue<String>(map, "ModifiedBy"),
      modifiedDate:
          map["ModifiedDate"] == null
              ? null
              : _parseDateTime(map["ModifiedDate"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "MarketingContentId": marketingContentId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "MarketingContentFolderId": marketingContentFolderId,
    "MarketingContentFolderName": marketingContentFolderName,
    "Title": title,
    "Remark": remark,
    "MarketingContentURL": marketingContentURL,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
