// GET DEFAULT VALUE AS PER TYPE FOR THE PARSER
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/custom_file_preview_dialogue_content.dart';
import 'package:k3h_erp_app/widgets/custom_snack_bar.dart';
import 'package:open_file/open_file.dart';
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

// <---- UPDATE ROUTE AUTHORIZATION ---->

Future<void> updateRouteAuthorization(List<ModuleModel> moduleData) async {
  // UPDATE THE MAP IN ISOLATE
  final updatedRouteMap = await compute(
    _processRouteAuthorizationModules,
    moduleData,
  );

  // UPDATE THE GLOBAL ROUTE AUTHORIZATION MAP
  Authorization.routeAuthorizationMap.addAll(updatedRouteMap);
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

// LOGOUT
Future logOutUser() async {
  await LocalStorageManager().removeAll();
  goRouter.replace(AppRoutes.splashScreen);
}

// SHOW SUCCESS MESSAGE
Future showSuccessMessage(BuildContext context, {String? subTitle}) async {
  bool isPop = false;
  Future.delayed(Duration(seconds: 3), () {
    if (!isPop) goRouter.pop();
  });
  CustomSnackBar.showTopSnackBar(
    context,
    title: "Success",
    subtitle: subTitle,
    isError: false,
  );
  isPop = true;
}

// SHOW ERROR MESSAGE
Future showErrorMessage(
  BuildContext context,
  String title,
  String message, {
  bool isMenuChanged = false,
}) async {
  // Check for menu/authorization changes
  final lowerMessage = message.toLowerCase();
  if (isMenuChanged ||
      lowerMessage.contains("menu") ||
      lowerMessage.contains("authorization") ||
      lowerMessage.contains("access has been modified") ||
      lowerMessage.contains("access modified")) {
    DialogHelper.showMenuChangedErrorDialog(context: context);
  } else {
    CustomSnackBar.showTopSnackBar(
      context,
      title: title,
      subtitle: message,
      isError: true,
    );

    await Future.delayed(const Duration(seconds: 3));
  }
}

bool isValidMobileNumber(String value) {
  final RegExp regex = RegExp(r'^[6-9]\d{9}$');
  return regex.hasMatch(value);
}

// DATE FORMATTERS
String formatDateTimeAsDDMMMYYYY(DateTime d, {String? separator}) {
  return DateFormat(
    'dd${separator ?? '-'}MMM${separator ?? '-'}yyyy',
  ).format(d);
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
    await OpenFile.open(filePath);
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
