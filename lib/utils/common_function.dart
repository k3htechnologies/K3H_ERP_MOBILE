// GET DEFAULT VALUE AS PER TYPE FOR THE PARSER
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/custom_file_preview_dialogue_content.dart';
import 'package:k3h_erp_app/widgets/custom_snack_bar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

// Function to return width
double getActualWidth(BuildContext context) {
  return MediaQuery.sizeOf(context).width;
}

// Function to return actual height
double getActualHeight(BuildContext context) {
  double height = MediaQuery.sizeOf(context).height;
  var padding = MediaQuery.of(context).viewPadding;
  height = height - padding.top - padding.bottom;
  return height;
}

T getDefaultValue<T>() {
  if (T == int) {
    return 0 as T;
  } else if (T == bool) {
    return false as T;
  } else if (T == String) {
    return "" as T;
  } else if (T == double) {
    return 0.0 as T;
  } else if (T == DateTime) {
    return DateTime(1970) as T;
  } else {
    throw UnsupportedError("Unsupported type $T");
  }
}

// PARSE VALUE
T parseValue<T>(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value == null) {
    return getDefaultValue<T>();
  }
  if (T == num) {
    if (value is num) return value as T;
    if (value is String) {
      final parsed = num.tryParse(value);
      return (parsed ?? getDefaultValue<num>()) as T;
    }
    return getDefaultValue<T>();
  }

  if (T == int) {
    if (value is int) return value as T;
    if (value is String) {
      final parsed = int.tryParse(value);
      return (parsed ?? getDefaultValue<int>()) as T;
    }
    return getDefaultValue<T>();
  } else if (T == double) {
    if (value is double) return value as T;
    if (value is String) {
      final parsed = double.tryParse(value);
      return (parsed ?? getDefaultValue<double>()) as T;
    }
    return getDefaultValue<T>();
  } else if (T == bool) {
    if (value is bool) return value as T;
    if (value is String) {
      return (value.toLowerCase() == 'true') as T;
    }
    return getDefaultValue<T>();
  } else if (T == String) {
    return value.toString() as T;
  } else if (T == DateTime) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return (parsed ?? getDefaultValue<DateTime>()) as T;
    }
    return getDefaultValue<T>();
  } else if (T == DateTime) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return (parsed ?? getDefaultValue<DateTime>()) as T;
    }
    return getDefaultValue<T>();
  } else {
    throw UnsupportedError("Unsupported type $T");
  }
}

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

// <---- UPDATE ROUTE AUTHORIZATION ---->
Future<void> updateRouteAuthorization(List<ModuleModel> moduleData) async {
  // UPDATE THE MAP IN ISOLATE
  final updatedRouteMap = await compute(
    _processRouteAuthorizationModules,
    moduleData,
  );

  final defaultMap = Authorization.routeAuthorizationMap;

  Authorization.routeAuthorizationMap = {...defaultMap, ...updatedRouteMap};
}

Map<String, AuthorizationModel> _processRouteAuthorizationModules(
  List<ModuleModel> modules,
) {
  final updatedMap = <String, AuthorizationModel>{};

  for (var module in modules) {
    for (var subModule in module.subModuleData) {
      updatedMap[subModule.path] = AuthorizationModel(
        isAccess: subModule.isAction || subModule.isExport || subModule.isView,
        isAction: subModule.isAction,
        isExport: subModule.isExport,
        isView: subModule.isView,
      );
      if (subModule.subSubModuleData.isNotEmpty) {
        for (var subSubModule in subModule.subSubModuleData) {
          updatedMap[subSubModule.path] = AuthorizationModel(
            isAccess:
                subSubModule.isAction ||
                subSubModule.isExport ||
                subSubModule.isView,
            isAction: subSubModule.isAction,
            isExport: subSubModule.isExport,
            isView: subSubModule.isView,
          );
        }
      }
    }
  }

  return updatedMap;
}

// <---- LOCATION PERMISSION ---->

Future<void> handleLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openAppSettings();
  }
}

// LOGOUT
Future<void> logOutUser(BuildContext context) async {
  final isConfirmed = await DialogHelper.logoutDialog(
    context,
    "Are you sure you want to logout?",
    "Are you sure you want to logout from the application? Please save all your work before confirming.",
  );

  if (isConfirmed == true) {
    if (context.mounted) {
      await showSuccessMessage(context, subTitle: "Logout successfully");
    }

    Future.delayed(Duration(seconds: 1), () async {
      await LocalStorageManager().removeAll();
      await Authorization.reset();

      if (context.mounted) {
        goRouter.go(AppRoutes.splashScreen);
      }
    });
  }
}

// SHOW SUCCESS MESSAGE
Future showSuccessMessage(BuildContext context, {String? subTitle}) async {
  bool isPop = false;
  Future.delayed(Duration(minutes: 3), () {
    if (!isPop) goRouter.pop();
  });
  CustomSnackBar.showTopSnackBar(
    context,
    title: subTitle ?? "Success",
    isError: false,
  );
  isPop = true;
}

Future showErrorMessage(
  BuildContext context,
  String title,
  String message, {
  bool isMenuChanged = false,
}) async {
  final lowerMessage = message.toLowerCase();

  if (isMenuChanged ||
      lowerMessage.contains("menu") ||
      lowerMessage.contains("authorization") ||
      lowerMessage.contains("access has been modified") ||
      lowerMessage.contains("access modified")) {
    DialogHelper.showMenuChangedErrorDialog(context: context);
  } else {
    CustomSnackBar.showTopSnackBar(context, title: message, isError: true);

    await Future.delayed(const Duration(seconds: 3));
  }
}

bool isValidMobileNumber(String value) {
  final RegExp regex = RegExp(r'^[6-9]\d{9}$');
  return regex.hasMatch(value);
}

// DATE FORMATTERS (MOSTLY USED)
String formatDateTimeAsDDMMMYYYY(DateTime d, {String? separator}) {
  return DateFormat(
    'dd${separator ?? '-'}MMM${separator ?? '-'}yyyy',
  ).format(d);
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
  // 🔒 Null / empty safety (common in your API)
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

/// Converts API working hours string (H:mm or HH:mm) into Duration.
///
/// Examples:
/// "0:48"  -> 48 minutes
/// "4:22"  -> 4 hours 22 minutes
/// "" / {} / null -> Duration.zero (safe for bad ERP APIs)
Duration parseWorkingHoursToDuration(String? workingHours) {
  // Handle null / empty / {} (your API sends {})
  if (workingHours == null || workingHours.isEmpty || workingHours == "{}") {
    return Duration.zero;
  }

  try {
    final parts = workingHours.split(':');

    if (parts.length != 2) return Duration.zero;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    return Duration(hours: hours, minutes: minutes);
  } catch (e) {
    // 🛡 Prevent crash if backend sends invalid value
    return Duration.zero;
  }
}

/// Calculates target working duration from shift start & end time.
///
/// Example:
/// 09:00 -> 18:00 = 9:00 hours
///
/// Handles:
/// - null values
/// - invalid API times
/// - negative duration safety (overnight shifts)
Duration calculateShiftDuration(DateTime? shiftStart, DateTime? shiftEnd) {
  if (shiftStart == null || shiftEnd == null) {
    // Default ERP fallback (9 hours)
    return const Duration(hours: 9);
  }

  Duration diff = shiftEnd.difference(shiftStart);

  // Safety: if backend sends wrong order or midnight edge case
  if (diff.isNegative) {
    diff = const Duration(hours: 9);
  }

  return diff;
}

// <---- EXPORT AND DOWNLOAD FILE FOR MOBILE ---->
Future<void> exportExcelOrPdfMobile(String base64, String fileName) async {
  try {
    Uint8List bytes = base64Decode(base64);
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    }
    if (dir == null) throw Exception("Cannot find storage directory");
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    await OpenFilex.open(filePath);
  } catch (e) {
    developer.log("Error saving file: $e");
  }
}

void showFilePreviewDialog(
  BuildContext context,
  List<String> urls, {
  List<Uint8List>? fileBytes,
}) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.white,
          child: CommonFileViewer(urls: urls, fileBytes: fileBytes),
        ),
  );
}

// <--- COMMON STYLE --->

BoxDecoration commonCardDecoration() => BoxDecoration(
  color: AppColor.white,
  borderRadius: BorderRadius.circular(8),
  boxShadow: [
    BoxShadow(
      color: AppColor.black.withValues(alpha: 0.05),
      blurRadius: 2,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: AppColor.black.withValues(alpha: 0.0),
      blurRadius: 0,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: AppColor.black.withValues(alpha: 0.0),
      blurRadius: 0,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
  ],
);

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
  //  Safety check for null or empty API values
  if (timeString == null || timeString.isEmpty) {
    return "-";
  }

  try {
    // Split time string (e.g., "18:00:00")
    final parts = timeString.split(':');

    // Parse hour safely
    final hour = int.tryParse(parts[0]) ?? 0;

    // Create a dummy DateTime using today's date with API hour
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, hour);

    // Format to only hour with AM/PM and convert to lowercase (UI consistency)
    return DateFormat('hh a').format(dateTime).toLowerCase();
  } catch (e) {
    // Fallback in case API sends unexpected format like {}
    return "-";
  }
}

String formatDateToDayMonth(DateTime dt) {
  Map<int, String> weekMap = {
    1: "Mon",
    2: "Tue",
    3: "Wed",
    4: "Thu",
    5: "Fri",
    6: "Sat",
    7: "Sun",
  };
  Map<int, String> monthMap = {
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "Jun",
    7: "Jul",
    8: "Aug",
    9: "Sep",
    10: "Oct",
    11: "Nov",
    12: "Dec",
  };
  String ans = "";
  ans += weekMap[dt.weekday]!;
  ans += ", ";
  ans += dt.day.toString().padLeft(2, "0");
  ans += " ";
  ans += monthMap[dt.month]!;
  return ans;
}

// FOR AGE CALCULATION
String calculateAge(DateTime? dateOfBirth) {
  if (dateOfBirth == null) return '';

  final now = DateTime.now();
  int age = now.year - dateOfBirth.year;

  if (now.month < dateOfBirth.month ||
      (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
    age--;
  }

  return age.toString();
}

// <---- IMPORT SAMPLE FILE FOR WEB ---->
Future<bool> sampleExcelImport(BuildContext context, String tableName) async {
  final UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();
  try {
    DialogHelper.showProcessingOverlay(context);
    var result = await utilsRepository.pullExcelSample(tableName: tableName);
    goRouter.pop();
    return result.fold(
      (failure) {
        showErrorMessage(context, "Import Error", failure.message);
        return false;
      },
      (response) {
        exportExcelOrPdfMobile(
          response["data"],
          "${tableName}_sample_${DateTime.now()}.xlsx",
        );
        showSuccessMessage(context, subTitle: "Excel downloaded successfully");
        return true;
      },
    );
  } catch (e) {
    return false;
  }
}

// <---- IMPORT FILE FOR WEB ---->
Future<bool> importExcel(
  BuildContext context,
  Map<String, String> body,
  List<Map<String, dynamic>> fileList,
) async {
  final UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();
  try {
    DialogHelper.showProcessingOverlay(context);
    var result = await utilsRepository.excelImport(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    return result.fold(
      (failure) {
        showErrorMessage(context, "Import Error", failure.message);
        return false;
      },
      (response) {
        showSuccessMessage(context, subTitle: "Excel imported successfully");
        return true;
      },
    );
  } catch (e) {
    return false;
  }
}

String addCommasToInteger(double value, {bool withoutSign = false}) {
  // Check if decimal part is non-zero
  bool hasDecimal = value % 1 != 0;

  // Format number string
  String numberStr =
      hasDecimal ? value.toStringAsFixed(2) : value.toInt().toString();

  // Split integer and decimal parts
  List<String> parts = numberStr.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

  // If small number
  if (integerPart.length <= 3) {
    String result = integerPart + (hasDecimal ? decimalPart : '');
    return withoutSign ? result : '₹ $result';
  }

  // Last 3 digits
  String lastThreeDigits = integerPart.substring(integerPart.length - 3);

  // Remaining digits
  String remainingDigits = integerPart.substring(0, integerPart.length - 3);

  // Indian grouping (2 digits)
  String groupedDigits = remainingDigits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
    (match) => '${match[1]},',
  );

  String result =
      '$groupedDigits,$lastThreeDigits${hasDecimal ? decimalPart : ''}';

  return withoutSign ? result : '₹ $result';
}

String getInitials(String name) {
  if (name.trim().isEmpty) return '';

  final parts = name.trim().split(' ');

  if (parts.length == 1) {
    return parts.first[0].toUpperCase();
  }

  return (parts.first[0] + parts.last[0]).toUpperCase();
}

String formatDateTimeReadable(DateTime? date) {
  if (date == null) return "-";

  return DateFormat('dd MMMM yyyy h:mm a').format(date);
}

void copy({required BuildContext context, required String text}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    showSuccessMessage(context, subTitle: '$text is Copied');
  }
}

UserModel getCurrentUser() {
  var userJson = jsonDecode(
    LocalStorageManager().getString(StorageKey.currentUser) ?? "",
  );
  return UserModel.fromJson(userJson);
}

extension MaterialItemExtension on MaterialRequisitionQuotationDatum {
  double get amountValue {
    if (amount > 0) return amount;
    return materialQuantity * materialPerUnit;
  }

  double get taxPercent => cgst + sgst + ugst + tgst;

  double get taxAmount => amountValue * taxPercent / 100;

  double get grandTotal => amountValue + taxAmount;
}

extension FinalizeVendorExtension on FinalizeVendorForComparisonModel {
  List<MaterialRequisitionQuotationDatum> get allItems =>
      materialRequisitionQuotationTermsData
          .expand((t) => t.materialRequisitionQuotationData)
          .toList();

  double get baseTotal => allItems.fold(0.0, (sum, e) => sum + e.amountValue);

  double get taxTotal => allItems.fold(0.0, (sum, e) => sum + e.taxAmount);

  double get grandTotal => allItems.fold(0.0, (sum, e) => sum + e.grandTotal);

  double get paid => paidAmount ?? 0;

  double get pendingAmount => grandTotal - paid;
}

String queryParamsFormatter({required Map<String, dynamic>? queryParams}) {
  String url = '';
  queryParams?.forEach((key, value) {
    if (value != null && value.toString().trim().isNotEmpty) {
      url += "&$key=$value";
    }
  });
  return url;
}
