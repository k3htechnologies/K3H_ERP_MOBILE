import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';

enum CalendarEventType { task, meeting, conferenceRoom }

class CalendarEvent {
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final CalendarEventType type;

  const CalendarEvent({
    required this.title,
    required this.date,
    required this.time,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'type': type.name,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['date'] ?? '') ?? DateTime.now();
    final timeString = json['time'] as String? ?? '0:0';
    final timeParts = timeString.split(':');
    final hour = int.tryParse(timeParts.elementAt(0)) ?? 0;
    final minute = int.tryParse(timeParts.elementAt(1)) ?? 0;
    final typeName = (json['type'] as String? ?? '').toLowerCase();
    final type = CalendarEventType.values.firstWhere(
      (t) => t.name.toLowerCase() == typeName,
      orElse: () => CalendarEventType.task,
    );

    return CalendarEvent(
      title: json['title'] as String? ?? '',
      date: date,
      time: TimeOfDay(hour: hour, minute: minute),
      type: type,
    );
  }
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

