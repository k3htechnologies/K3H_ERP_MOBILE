import 'package:k3h_erp_app/utils/functions/common_function.dart';

class NotificationModel {
  int notificationId;
  String title;
  String description;
  bool isRead;
  DateTime createdDate;
  String path;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.description,
    required this.isRead,
    required this.createdDate,
    required this.path,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        notificationId: parseValue<int>(json, "NotificationId"),
        title: parseValue<String>(json, "Title"),
        description: parseValue<String>(json, "Description"),
        isRead: parseValue<bool>(json, "IsRead"),
        createdDate: DateTime.parse(json["CreatedDate"]),
        path: json["Path"],
      );

  Map<String, dynamic> toJson() => {
    "NotificationId": notificationId,
    "Title": title,
    "Description": description,
    "IsRead": isRead,
    "CreatedDate": createdDate.toIso8601String(),
    "Path": path,
  };
}
