import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TicketModel {
  int ticketId;
  String uniquekey;
  String systemGeneratedCode;
  String platform;
  String module;
  String attachmentUrl;
  String priority;
  String ticketStatus;
  String ticketDescription;
  String ticketRemark;
  int employeeId;
  String employeeName;
  String collaboratorsEmployeeId;
  String collaboratorsName;
  String assignedStatus;
  String assignedBy;
  String assignedRemark;
  DateTime? assignedDate;
  DateTime? resolvedTillDate;
  String departmentName;
  List<AssignTicketHistory> assignTicketHistory;
  bool canAction;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TicketModel({
    required this.ticketId,
    required this.uniquekey,
    required this.systemGeneratedCode,
    required this.platform,
    required this.module,
    required this.attachmentUrl,
    required this.priority,
    required this.ticketStatus,
    required this.ticketDescription,
    required this.ticketRemark,
    required this.employeeId,
    required this.employeeName,
    required this.collaboratorsEmployeeId,
    required this.collaboratorsName,
    required this.assignedStatus,
    required this.assignedBy,
    required this.assignedRemark,
    required this.assignedDate,
    required this.resolvedTillDate,
    required this.departmentName,
    required this.assignTicketHistory,
    required this.canAction,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
    ticketId: parseValue<int>(json, "TicketId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    platform: parseValue<String>(json, "Platform"),
    module: parseValue<String>(json, "Module"),
    attachmentUrl: parseValue<String>(json, "AttachmentURL"),
    priority: parseValue<String>(json, "Priority"),
    ticketStatus: parseValue<String>(json, "TicketStatus"),
    ticketDescription: parseValue<String>(json, "TicketDescription"),
    ticketRemark: parseValue<String>(json, "TicketRemark"),
    employeeId: parseValue<int>(json, "EmployeeId"),
    employeeName: parseValue<String>(json, "EmployeeName"),
    collaboratorsEmployeeId: parseValue<String>(
      json,
      "CollaboratorsEmployeeId",
    ),
    collaboratorsName: parseValue<String>(json, "CollaboratorsName"),
    assignedStatus: parseValue<String>(json, "AssignedStatus"),
    assignedBy: parseValue<String>(json, "AssignedBy"),
    assignedRemark: parseValue<String>(json, "AssignedRemark"),
    assignedDate:
        json["AssignedDate"] == null
            ? null
            : parseValue<DateTime>(json, "AssignedDate"),
    resolvedTillDate:
        json["ResolvedTillDate"] == null
            ? null
            : parseValue<DateTime>(json, "ResolvedTillDate"),
    departmentName: parseValue<String>(json, "DepartmentName"),
    assignTicketHistory: List<AssignTicketHistory>.from(
      json["AssignTicketHistory"].map((x) => AssignTicketHistory.fromJson(x)),
    ),
    canAction: parseValue<bool>(json, "CanAction"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate:
        json["CreatedDate"] == null
            ? null
            : parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
  );

  Map<String, dynamic> toJson() => {
    "TicketId": ticketId,
    "Uniquekey": uniquekey,
    "SystemGeneratedCode": systemGeneratedCode,
    "Platform": platform,
    "Module": module,
    "AttachmentURL": attachmentUrl,
    "Priority": priority,
    "TicketStatus": ticketStatus,
    "TicketDescription": ticketDescription,
    "TicketRemark": ticketRemark,
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "CollaboratorsEmployeeId": collaboratorsEmployeeId,
    "CollaboratorsName": collaboratorsName,
    "AssignedStatus": assignedStatus,
    "AssignedBy": assignedBy,
    "AssignedRemark": assignedRemark,
    "AssignedDate": assignedDate,
    "ResolvedTillDate": resolvedTillDate,
    "DepartmentName": departmentName,
    "AssignTicketHistory": List<dynamic>.from(
      assignTicketHistory.map((x) => x.toJson()),
    ),
    "CanAction": canAction,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class AssignTicketHistory {
  String assignedRemark;
  String assignedStatus;
  DateTime? createdDate;

  AssignTicketHistory({
    required this.assignedRemark,
    required this.assignedStatus,
    required this.createdDate,
  });

  factory AssignTicketHistory.fromJson(Map<String, dynamic> json) =>
      AssignTicketHistory(
        assignedRemark: parseValue<String>(json, "AssignedRemark"),
        assignedStatus: parseValue<String>(json, "AssignedStatus"),
        createdDate:
            json["CreatedDate"] == null
                ? null
                : parseValue<DateTime>(json, "CreatedDate"),
      );

  Map<String, dynamic> toJson() => {
    "AssignedRemark": assignedRemark,
    "AssignedStatus": assignedStatus,
    "CreatedDate": createdDate?.toIso8601String(),
  };
}
