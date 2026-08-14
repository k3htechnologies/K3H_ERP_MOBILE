// GET DEFAULT VALUE AS PER TYPE FOR THE PARSER
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/custom_file_preview_dialogue_content.dart';
import 'package:k3h_erp_app/widgets/custom_snack_bar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
export 'common_date_function.dart';
export 'common_extension_helpers.dart';

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

// LOCATION PERMISSION
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

// <---- EXPORT AND DOWNLOAD FILE FOR MOBILE
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
  String? title,
  List<Uint8List>? fileBytes,
  String? downloadSuccessMessage,
}) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.white,
          child: CommonFileViewer(
            urls: urls,
            fileBytes: fileBytes,
            title: title ?? "View File",
            downloadSuccessMessage: downloadSuccessMessage,
          ),
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

// <---- IMPORT SAMPLE FILE FOR WEB
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

// <---- IMPORT FILE FOR WEB
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

String formattedAmount(num value, {bool showRupeeSymbol = true}) {
  final symbol = showRupeeSymbol ? "₹ " : "";

  if (value >= 10000000) {
    return "$symbol${(value / 10000000).toStringAsFixed(1)} CR";
  } else if (value >= 100000) {
    return "$symbol${(value / 100000).toStringAsFixed(1)} L";
  } else if (value >= 1000) {
    return "$symbol${(value / 1000).toStringAsFixed(1)} K";
  } else {
    return "$symbol${value.toStringAsFixed(0)}";
  }
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

// HELPER: Find item in list by DisplayName
Map<String, dynamic>? findItem(List<Map<String, dynamic>> list, String value) {
  if (value.isEmpty) {
    return null;
  }
  return list.firstWhere(
    (e) =>
        e["DisplayName"].toString().toLowerCase().trim() ==
        value.toLowerCase().trim(),
    orElse: () => list.first,
  );
}

String queryParamsFormatter({required Map<String, dynamic>? queryParams}) {
  String url = '';
  queryParams?.forEach((key, value) {
    if (value != null && value.toString().trim().isNotEmpty) {
      url += "&$key=${Uri.encodeQueryComponent(value.toString())}";
    }
  });
  return url;
}

String toTitleCase(String columnName) {
  return columnName
      .toLowerCase()
      .split(' ')
      .map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');
}

int getActiveFilterCount(List<bool> filters) {
  return filters.where((e) => e).length;
}

String formatToKLCr(num value) {
  if (value >= 10000000) {
    final result = value / 10000000;
    return "₹${result.toStringAsFixed(value % 10000000 == 0 ? 0 : 1)} CR";
  }

  if (value >= 100000) {
    final result = value / 100000;
    return "₹${result.toStringAsFixed(value % 100000 == 0 ? 0 : 1)} L";
  }

  if (value >= 1000) {
    final result = value / 1000;
    return "₹${result.toStringAsFixed(value % 1000 == 0 ? 0 : 1)} K";
  }
  if (value == 0) {
    return "₹0";
  }
  return "₹$value";
}

String formatIndianAmount(num value, {bool showCurrency = true}) {
  final prefix = showCurrency ? "₹" : "";

  const double thousand = 1e3;
  const double lakh = 1e5;
  const double crore = 1e7;

  String format(double val) {
    String result = val.toStringAsFixed(2);
    result = result.replaceAll(RegExp(r'0+$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');
    return result;
  }

  if (value >= crore) {
    return "$prefix${format(value / crore)} CR";
  } else if (value >= lakh) {
    return "$prefix${format(value / lakh)} L";
  } else if (value >= thousand) {
    return "$prefix${format(value / thousand)} K";
  }

  return "$prefix${format(value.toDouble())}";
}

// FOR SEARCH INSIDE STATIC MULTISELECT DROPDOWN
Future<Map<String, dynamic>> filterDropdownList(
  int pageNumber, {
  String? value,
  required List<Map<String, dynamic>> list,
}) async {
  final filtered =
      value == null || value.trim().isEmpty
          ? list
          : list
              .where(
                (e) => (e['DisplayName'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()),
              )
              .toList();

  return {"itemList": filtered, "totalNumberOfRecord": filtered.length};
}

Future<Uint8List> compress(Uint8List bytes) async {
  return await FlutterImageCompress.compressWithList(bytes, quality: 50);
}

// FOR MERGING FILES IN APPLICANT FORM
MultiFilePickerModel mergeFile(
  MultiFilePickerModel updated,
  MultiFilePickerModel old,
) {
  return MultiFilePickerModel(
    fileBytesList:
        updated.fileBytesList.isNotEmpty
            ? updated.fileBytesList
            : old.fileBytesList,
    fileNameList:
        updated.fileNameList.isNotEmpty
            ? updated.fileNameList
            : old.fileNameList,
    deletedFileList: updated.deletedFileList,
  );
}

String getApiMobileNumber(String phoneNumber) {
  // Remove everything except digits
  String digits = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // Remove India country code if present
  if (digits.startsWith('91') && digits.length == 12) {
    digits = digits.substring(2);
  }

  // Keep only the last 10 digits as a safety measure
  if (digits.length > 10) {
    digits = digits.substring(digits.length - 10);
  }

  return digits;
}
