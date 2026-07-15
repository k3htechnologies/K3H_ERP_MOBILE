import 'package:k3h_erp_app/utils/functions/common_function.dart';

class FlatHandoverChecklistModel {
  int flatHandOverCheckListId;
  String uniqueKey;
  int projectId;
  int bookingId;
  String section;
  String items;
  String status;
  String remark;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  FlatHandoverChecklistModel({
    required this.flatHandOverCheckListId,
    required this.uniqueKey,
    required this.projectId,
    required this.bookingId,
    required this.section,
    required this.items,
    required this.status,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory FlatHandoverChecklistModel.fromJson(Map<String, dynamic> json) =>
      FlatHandoverChecklistModel(
        flatHandOverCheckListId: parseValue<int>(
          json,
          "FlatHandOverCheckListId",
        ),
        uniqueKey: parseValue<String>(json, "UniqueKey"),
        projectId: parseValue<int>(json, "ProjectId"),
        bookingId: parseValue<int>(json, "BookingId"),
        section: parseValue<String>(json, "Section"),
        items: parseValue<String>(json, "Items"),
        status: parseValue<String>(json, "Status"),
        remark: parseValue<String>(json, "Remark"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate:
            json["CreatedDate"] != null
                ? DateTime.parse(json["CreatedDate"])
                : DateTime.now(),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] != null
                ? DateTime.parse(json["ModifiedDate"])
                : null,
      );

  Map<String, dynamic> toJson() => {
    "FlatHandOverCheckListId": flatHandOverCheckListId,
    "UniqueKey": uniqueKey,
    "ProjectId": projectId,
    "BookingId": bookingId,
    "Section": section,
    "Items": items,
    "Status": status,
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
