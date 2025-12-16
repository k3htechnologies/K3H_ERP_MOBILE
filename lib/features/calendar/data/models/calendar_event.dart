import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';

CalendarEventModel calendarEventModelFromJson(String str) =>
    CalendarEventModel.fromJson(json.decode(str));

String calendarEventModelToJson(CalendarEventModel data) =>
    json.encode(data.toJson());

class CalendarEventModel {
  final int eventId;
  final String uniquekey;
  final String type;
  final String title;
  final DateTime date;
  final DateTime time;
  final String employeeId;
  final String employeeFullName;
  final String room;
  final String documentUrl;
  final String remarks;
  final int createdById;
  final String createdBy;
  final DateTime createdDate;
  final int modifiedById;
  final String modifiedBy;
  final dynamic modifiedDate;

  CalendarEventModel({
    required this.eventId,
    required this.uniquekey,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.employeeId,
    required this.employeeFullName,
    required this.room,
    required this.documentUrl,
    required this.remarks,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      eventId: json["EventId"],
      uniquekey: json["Uniquekey"],
      type: json["Type"],
      title: json["Title"],
      date: DateTime.parse(json["Date"]),
      time: DateTime.parse(json["Time"]),
      employeeId: json["EmployeeId"],
      employeeFullName: json["EmployeeFullName"],
      room: json["Room"],
      documentUrl: json["DocumentURL"],
      remarks: json["Remarks"],
      createdById: json["CreatedById"],
      createdBy: json["CreatedBy"],
      createdDate: DateTime.parse(json["CreatedDate"]),
      modifiedById: json["ModifiedById"],
      modifiedBy: json["ModifiedBy"],
      modifiedDate: json["ModifiedDate"],
    );
  }

  Map<String, dynamic> toJson() => {
    "EventId": eventId,
    "Uniquekey": uniquekey,
    "Type": type,
    "Title": title,
    "Date": date.toIso8601String(),
    "Time": time.toIso8601String(),
    "EmployeeId": employeeId,
    "EmployeeFullName": employeeFullName,
    "Room": room,
    "DocumentURL": documentUrl,
    "Remarks": remarks,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}

Color eventTypeColor(CalendarEventType type) {
  switch (type) {
    case CalendarEventType.task:
      return AppColor.error;
    case CalendarEventType.meeting:
      return AppColor.primary;
    case CalendarEventType.conferenceRoom:
      return AppColor.yellow;
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
      case 'conferenceroom':
      case 'conference_room':
      case 'conference room':
        return CalendarEventType.conferenceRoom;
      default:
        return CalendarEventType.task;
    }
  }
}

