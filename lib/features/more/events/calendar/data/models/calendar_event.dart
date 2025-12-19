import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

CalendarEventModel calendarEventModelFromJson(String str) =>
    CalendarEventModel.fromJson(json.decode(str));

String calendarEventModelToJson(CalendarEventModel data) =>
    json.encode(data.toJson());

class CalendarEventModel {
  final int eventId;
  final String uniquekey;
  final String type;
  final String title;
  final DateTime? date;
  final DateTime? deadlineDate;
  final String? startTime;
  final String? endTime;
  final String? projectId;
  final String? projectName;
  final String? departmentId;
  final String? departmentName;
  final String? employeeId;
  final String? fullName;
  final String? employeeFullName;
  final String? room;
  final String? priority;
  final String? documentUrl;
  final String? description;
  final int createdById;
  final String? createdBy;
  final DateTime? createdDate;
  final int modifiedById;
  final String? modifiedBy;
  final dynamic modifiedDate;

  CalendarEventModel({
    required this.eventId,
    required this.uniquekey,
    required this.type,
    required this.title,
    this.date,
    this.deadlineDate,
    this.startTime,
    this.endTime,
    this.projectId,
    this.projectName,
    this.departmentId,
    this.departmentName,
    this.employeeId,
    this.fullName,
    this.employeeFullName,
    this.room,
    this.priority,
    this.documentUrl,
    this.description,
    required this.createdById,
    this.createdBy,
    this.createdDate,
    required this.modifiedById,
    this.modifiedBy,
    this.modifiedDate,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      eventId: parseValue<int>(json, "EventId"),
      uniquekey: parseValue<String>(json, "Uniquekey"),
      type: parseValue<String>(json, "Type"),
      title: parseValue<String>(json, "Title"),
      date: json["Date"] != null && json["Date"].toString().isNotEmpty
          ? DateTime.tryParse(json["Date"].toString())
          : null,
      deadlineDate: json["DeadlineDate"] != null && json["DeadlineDate"].toString().isNotEmpty
          ? DateTime.tryParse(json["DeadlineDate"].toString())
          : null,
      startTime: parseValue<String>(json, "StartTime"),
      endTime: parseValue<String>(json, "EndTime"),
      projectId: parseValue<String>(json, "ProjectId"),
      projectName: parseValue<String>(json, "ProjectName"),
      departmentId: parseValue<String>(json, "DepartmentId"),
      departmentName: parseValue<String>(json, "DepartmentName"),
      employeeId: parseValue<String>(json, "EmployeeId"),
      fullName: parseValue<String>(json, "FullName"),
      employeeFullName: parseValue<String>(json, "EmployeeFullName"),
      room: parseValue<String>(json, "Room"),
      priority: parseValue<String>(json, "Priority"),
      documentUrl: parseValue<String>(json, "DocumentURL"),
      description: parseValue<String>(json, "Description"),
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate: json["CreatedDate"] != null && json["CreatedDate"].toString().isNotEmpty
          ? DateTime.tryParse(json["CreatedDate"].toString())
          : null,
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate: json["ModifiedDate"],
    );
  }

  Map<String, dynamic> toJson() => {
    "EventId": eventId,
    "Uniquekey": uniquekey,
    "Type": type,
    "Title": title,
    "Date": date?.toIso8601String(),
    "DeadlineDate": deadlineDate?.toIso8601String(),
    "StartTime": startTime,
    "EndTime": endTime,
    "ProjectId": projectId,
    "ProjectName": projectName,
    "DepartmentId": departmentId,
    "DepartmentName": departmentName,
    "EmployeeId": employeeId,
    "FullName": fullName,
    "EmployeeFullName": employeeFullName,
    "Room": room,
    "Priority": priority,
    "DocumentURL": documentUrl,
    "Description": description,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };

  // Helper method to get the appropriate date based on event type
  DateTime? getEventDate() {
    final eventType = type.toLowerCase();
    if (eventType == 'task') {
      return deadlineDate;
    } else {
      return date;
    }
  }

  // Helper method to parse startTime string to DateTime for time operations
  DateTime? getStartTimeAsDateTime() {
    if (startTime == null || startTime!.isEmpty) return null;
    try {
      final parts = startTime!.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(2000, 1, 1, hour, minute);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Helper method to parse endTime string to DateTime for time operations
  DateTime? getEndTimeAsDateTime() {
    if (endTime == null || endTime!.isEmpty) return null;
    try {
      final parts = endTime!.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(2000, 1, 1, hour, minute);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

Color eventTypeColor(CalendarEventType type) {
  switch (type) {
    case CalendarEventType.task:
      return AppColor.primary;
    case CalendarEventType.meeting:
      return AppColor.error;
    case CalendarEventType.conferenceRoom:
      return AppColor.warning;
  }
}

enum CalendarEventType { task, meeting, conferenceRoom }

extension CalendarEventTypeMapper on String {
  CalendarEventType toCalendarEventType() {
    switch (toLowerCase()) {
      case 'task':
        return CalendarEventType.task;
      case 'meeting':
        return CalendarEventType.meeting;
      case 'conferenceroombooking':
      case 'conference_room_booking':
      case 'conference room booking':
        return CalendarEventType.conferenceRoom;
      default:
        return CalendarEventType.task;
    }
  }
}

