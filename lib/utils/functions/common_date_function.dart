import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// DATE FORMATTERS (MOSTLY USED)
String formatDateTimeAsDDMMMYYYY(DateTime? date, {String? separator}) {
  if (date == null) return "-";

  if (date.year == 1970) return "-";

  return DateFormat(
    'dd${separator ?? '-'}MMM${separator ?? '-'}yyyy',
  ).format(date);
}

// DATE FORMATTERS
String formatDate(DateTime? date) {
  if (date == null) return "";
  if (date.year == 1970) return "-";
  return DateFormat("dd MMM yyyy, hh:mm a").format(date);
}

// TIME FORMATTERS
String formatTime(DateTime? date) {
  if (date == null) return "";
  return DateFormat("hh:mma").format(date);
}

/// Converts API time string (HH:mm:ss or HH:mm) to 12-hour format (h:mm am/pm).
///
/// Examples:
/// "10:31:32" -> "10:31 am"
/// "18:05:00" -> "6:05 pm"
/// "09:00:00" -> "9:00 am"
///
/// Handles:
/// - null
/// - empty string
/// - invalid formats
/// - API returning "{}" or unexpected values
String formatApiTimeToAmPm(String? timeString) {
  //  Null / empty safety (common in your API)
  if (timeString == null || timeString.isEmpty || timeString == "{}") {
    return "-";
  }

  try {
    // Split API time: "HH:mm:ss"
    final parts = timeString.split(':');

    if (parts.length < 2) return "-";

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    // Create DateTime using today's date + API time
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, hour, minute);

    // Format to: 9:12 am (NO leading zero on hour)
    return DateFormat('h:mm a').format(dateTime).toLowerCase();
  } catch (e) {
    // 🛡 Prevent UI crash if backend sends invalid value
    return "-";
  }
}

/// Converts decimal hours (double/int/num) from API into readable duration.
///
/// Examples:
/// 0.183333  -> "11m"
/// 1.5       -> "1h 30m"
/// 4.366666  -> "4h 22m"
/// 8.0       -> "8h"
/// 0         -> "0h"
///
/// Safe for mixed API types (int, double, null).
String formatDecimalHours(num? hours) {
  // Null or invalid safety (ERP APIs often send null/0)
  if (hours == null) return "-";

  // Convert hours to total minutes
  final totalMinutes = (hours * 60).round();

  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;

  // Only minutes (e.g. 0.18 hrs)
  if (h == 0 && m > 0) {
    return "${m}m";
  }

  // Only hours (e.g. 8.0 hrs)
  if (m == 0) {
    return "${h}h";
  }

  // Hours + minutes (e.g. 4.36 hrs)
  return "${h}h ${m}m";
}

// TimeOfDay -> "HH:mm"
String formatTimeOfDayHHmm(TimeOfDay? time) {
  if (time == null) return "HH:mm";

  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

// "HH:mm" -> TimeOfDay
TimeOfDay? parseTimeOfDayFromHHmm(String? value) {
  if (value == null || value.isEmpty) return null;

  try {
    final parts = value.split(':');

    if (parts.length < 2) return null;

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return TimeOfDay(hour: hour, minute: minute);
  } catch (_) {
    return null;
  }
}

int convertHHmmToMinutes(String? value) {
  if (value == null || value.isEmpty) return 0;

  final parts = value.split(':');
  if (parts.length < 2) return 0;

  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;

  return (hours * 60) + minutes;
}

String normalizeTime(String? time) {
  if (time == null || time.isEmpty) return "";
  return time.split(':').take(2).join(':');
}

int toMinutes(String? time) {
  final t = parseTimeOfDayFromHHmm(time);
  if (t == null) return 0;
  return t.hour * 60 + t.minute;
}

String toHHmm(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
}

int getDiffInMinutes(String? start, String? end) {
  if (start == null || end == null) return 0;

  int startMin = toMinutes(start);
  int endMin = toMinutes(end);

  int diff = endMin - startMin;
  if (diff < 0) diff += 24 * 60;

  return diff;
}

String dateFormatterDDMMYYYYDAY(
  DateTime date, {
  bool isDayNotRequired = false,
}) {
  try {
    if (isDayNotRequired) {
      return DateFormat('dd MMMM yyyy').format(date);
    }
    return DateFormat('dd MMMM yyyy, EEEE').format(date);
  } catch (_) {
    return '';
  }
}

String formatDateToDayMonthOnly(DateTime? date) {
  if (date == null) return '';

  return DateFormat('dd MMM').format(date);
}

String dateFormatterHhMmAm(DateTime dateTime) {
  return DateFormat('hh:mma').format(dateTime).toLowerCase();
}

String formatDateTimeForApi(DateTime d) {
  return DateFormat('yyyy-MM-dd').format(d);
}

/// Formats a time string (HH:mm:ss or HH:mm) into only hours with AM/PM.
///
/// Example:
/// "18:00:00" -> "06 pm"
/// "09:30:00" -> "09 am"
/// "10:31:32" -> "10 am"
///
/// This is API-safe because backend sometimes sends:
/// - "18:00:00"
/// - "09:00:00"
/// - null
/// - empty string
///
/// It prevents crashes and avoids showing "12 am" incorrectly.
String dateFormatterHourOnly(String? timeString) {
  if (timeString == null || timeString.isEmpty || timeString == "{}") {
    return "-";
  }

  try {
    final parts = timeString.split(':');

    if (parts.length < 2) return "-";

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final now = DateTime.now();

    final dateTime = DateTime(now.year, now.month, now.day, hour, minute);

    return DateFormat('hh:mm a').format(dateTime).toLowerCase();
  } catch (e) {
    return "-";
  }
}

String formatDateToDayMonth(DateTime date) {
  return DateFormat("dd MMM, EEEE").format(date);
}

bool isCurrentDay(String day) =>
    DateFormat("EEEE").format(DateTime.now()).toLowerCase() ==
    day.toLowerCase();

// FOR ATTENDANCE DATETIME
DateTime? parseApiDate(String? value) {
  if (value == null || value.isEmpty) return null;

  final dt = DateTime.parse(value);
  return DateTime(
    dt.year,
    dt.month,
    dt.day,
    dt.hour,
    dt.minute,
    dt.second,
    dt.millisecond,
  );
}


