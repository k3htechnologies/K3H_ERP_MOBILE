// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_snack_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DialogHelper {
  // <----PROCESSING DIALOG ---->
  static void showProcessingOverlay(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "",
      barrierColor: Colors.transparent, // important!
      pageBuilder: (context, _, __) {
        return SizedBox.expand(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: Stack(
            children: [
              child,
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/appLogo.png",
                      width: 100,
                      height: 100,
                    ),
                    verticalSpacing(),
                    CircularProgressIndicator(strokeWidth: 3),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // SUCCESS
  static void showSuccessMessage(BuildContext context, {String? title}) {
    CustomSnackBar.showTopSnackBar(
      context,
      title: title ?? "Success!",
      isError: false,
    );
  }

  // ERROR
  static void showErrorMessage({
    required BuildContext context,
    String? title,
    required String message,
  }) {
    CustomSnackBar.showTopSnackBar(context, title: message, isError: true);
  }

  // <--- MENU CHANGED ERROR DIALOG ---->
  static Future<void> showMenuChangedErrorDialog({
    required BuildContext context,
  }) async {
    return await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 300,
            width: 500,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.yellow, width: 1),
              color: AppColor.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Icon(Icons.info_outline, size: 50, color: AppColor.red),
                  Text(
                    "Authorization Changed",
                    style: AppTextStyle.ts20R(color: AppColor.red),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(
                    child: Text(
                      "Your access has been modified, please restart to use the application.",
                      style: AppTextStyle.ts16R(color: AppColor.grey),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  CustomButton(
                    onPressed: () {
                      LocalStorageManager().remove(StorageKey.menu);
                      goRouter.go(AppRoutes.splashScreen);
                    },
                    text: "Restart",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // <---- DELETE DIALOG ---->
  static Future<bool> deleteDialog(
    BuildContext context,
    String title,
    String subTitle,
  ) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 40.0,
          ),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.error, width: 0.5),
                color: AppColor.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.delete, color: AppColor.error, size: 32),
                  verticalSpacing(height: 15),
                  Text(
                    title,
                    style: AppTextStyle.ts20R(color: AppColor.error),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpacing(height: 8),
                  Text(
                    subTitle,
                    style: AppTextStyle.ts16R(color: AppColor.grey),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpacing(height: 24),
                  Row(
                    spacing: 2,
                    children: [
                      Expanded(
                        child: CustomButton.cancelOutline(
                          onPressed: () => goRouter.pop(false),
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: CustomButton(
                          backgroundColor: AppColor.error,
                          textColor: AppColor.white,
                          onPressed: () => goRouter.pop(true),
                          text: "Confirm",
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<bool> logoutDialog(
    BuildContext context,
    String title,
    String subTitle,
  ) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 40.0,
          ),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.error, width: 0.5),
                color: AppColor.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: AppColor.error, size: 32),
                  verticalSpacing(height: 15),

                  Text(
                    title,
                    style: AppTextStyle.ts20R(color: AppColor.error),
                    textAlign: TextAlign.center,
                  ),

                  verticalSpacing(height: 8),

                  Text(
                    subTitle,
                    style: AppTextStyle.ts16R(color: AppColor.grey),
                    textAlign: TextAlign.center,
                  ),

                  verticalSpacing(height: 24),

                  Row(
                    spacing: 2,
                    children: [
                      Expanded(
                        child: CustomButton.cancelOutline(
                          onPressed: () => goRouter.pop(false),
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: CustomButton(
                          backgroundColor: AppColor.error,
                          textColor: AppColor.white,
                          onPressed: () => goRouter.pop(true),
                          text: "Log out",
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = "Confirm",
    String cancelText = "Cancel",
    Color confirmColor = AppColor.primary,
    IconData icon = CupertinoIcons.question_circle,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: confirmColor, width: 0.5),
                color: AppColor.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: confirmColor, size: 32),
                  verticalSpacing(height: 15),

                  Text(
                    title,
                    style: AppTextStyle.ts20R(color: confirmColor),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpacing(height: 8),

                  Text(
                    message,
                    style: AppTextStyle.ts16R(color: AppColor.grey),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpacing(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: CustomButton.cancelOutline(
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: CustomButton(
                          text: confirmText,
                          backgroundColor: confirmColor,
                          textColor: AppColor.white,
                          onPressed: () => Navigator.pop(context, true),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  // BOTTOM SHEET
  static Future showCustomBottomSheet(
    BuildContext context,
    String title,
    Widget contentWidget,
  ) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (BuildContext context) => SafeArea(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              width: getActualWidth(context),
              height: getActualHeight(context) * 0.50,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Column(
                children: [
                  /// DRAG HANDLE
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    height: 5,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColor.grey,
                    ),
                  ),

                  /// TITLE
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.only(bottom: 16, left: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(title, style: AppTextStyle.ts16SB()),
                    ),
                  ),

                  Divider(color: AppColor.grey, thickness: .3),

                  /// CONTENT (let child handle scrolling)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: contentWidget,
                    ),
                  ),

                  verticalSpacing(height: 10.0),
                ],
              ),
            ),
          ),
    );
  }

  // FILTER BOTTOM SHEET
  static Future showCustomFilterBottomSheet(
    BuildContext context, {
    required String title,
    required Widget contentWidget,
    required VoidCallback onClear,
    required VoidCallback onApply,
    bool isApplyEnabled = true,
    ValueNotifier<bool>? applyEnabledNotifier,
  }) async {
    final ScrollController scrollController = ScrollController();

    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (BuildContext context) => SizedBox(
            height: getActualHeight(context) * 0.60,
            width: getActualWidth(context),
            child: SafeArea(
              child: Column(
                children: [
                  // DRAG HANDLE
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 5,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColor.grey,
                    ),
                  ),

                  // TITLE
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 12, left: 16),
                    child: Text(title, style: AppTextStyle.ts16SB()),
                  ),

                  Divider(color: AppColor.grey, thickness: .3),

                  // CONTENT WITH SCROLLBAR
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RawScrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        thickness: 6,
                        radius: const Radius.circular(10),
                        thumbColor: AppColor.mediumBlue.withValues(alpha: .8),
                        trackColor: AppColor.lightGrey,
                        trackVisibility: true,
                        minThumbLength: 10,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: contentWidget,
                        ),
                      ),
                    ),
                  ),

                  // FIXED BOTTOM BUTTONS
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.black.withValues(alpha: .3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // CLEAR
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: CustomButton.clearOutline(
                              onPressed: () {
                                goRouter.pop();
                                onClear();
                              },
                            ),
                          ),
                        ),

                        horizontalSpacing(width: 12),

                        // APPLY
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child:
                                applyEnabledNotifier == null
                                    ? CustomButton(
                                      text: "Apply",
                                      isDisable: !isApplyEnabled,
                                      onPressed:
                                          isApplyEnabled
                                              ? () {
                                                goRouter.pop();
                                                onApply();
                                              }
                                              : null,
                                    )
                                    : ValueListenableBuilder<bool>(
                                      valueListenable: applyEnabledNotifier,
                                      builder: (context, enabled, _) {
                                        return CustomButton(
                                          text: "Apply",
                                          isDisable: !enabled,
                                          onPressed:
                                              enabled
                                                  ? () {
                                                    goRouter.pop();
                                                    onApply();
                                                  }
                                                  : null,
                                        );
                                      },
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // CUSTOM DIALOG
  static Future showCustomDialogue(
    BuildContext context, {
    required Widget childContent,
    String? title,
    Widget? bottomSection, // optional
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (title != null) Text(title, style: AppTextStyle.ts14M()),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        goRouter.pop();
                      },
                      icon: Icon(Icons.close, size: 18),
                    ),
                  ],
                ),

                // CONTENT
                childContent,

                // OPTIONAL BOTTOM SECTION
                if (bottomSection != null) ...[
                  const SizedBox(height: 16),
                  bottomSection,
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // <--- IMPORT - DELETE CONFIRMATION DIALOG ---->
  static Future<Map<String, dynamic>?> showDeleteAllConfirmationDialog({
    required BuildContext context,
  }) async {
    Uint8List? fileBytes;
    String? fileName;
    String uploadChoice = "yes";

    final ScrollController expansionScrollController = ScrollController();

    return await showDialog<Map<String, dynamic>>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.primary, width: .5),
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.file_upload_outlined,
                              size: 24,
                              color: AppColor.primary,
                            ),
                            horizontalSpacing(),
                            Text(
                              "Import Excel",
                              style: AppTextStyle.ts20R(
                                color: AppColor.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        verticalSpacing(),

                        Text(
                          "Upload Excel file and choose how existing records should be handled.",
                          style: AppTextStyle.ts16R(color: AppColor.grey),
                          textAlign: TextAlign.start,
                        ),

                        verticalSpacing(),

                        // FILE PICKER
                        GestureDetector(
                          onTap: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['xlsx', 'xls', 'csv'],
                                  withData: true,
                                );

                            if (result != null && result.files.isNotEmpty) {
                              final file = result.files.first;

                              setState(() {
                                fileBytes = file.bytes;
                                fileName = file.name;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColor.grey.withValues(alpha: .4),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColor.white,
                            ),
                            child: Row(
                              children: [
                                /// ICON
                                Icon(
                                  fileName == null
                                      ? Icons.attach_file
                                      : Icons.description_outlined,
                                  color: AppColor.primary,
                                ),

                                horizontalSpacing(),

                                // FILE NAME OR PLACEHOLDER
                                Expanded(
                                  child: Text(
                                    fileName ?? "Attach Excel File",
                                    style: AppTextStyle.ts14R(
                                      color:
                                          fileName == null
                                              ? AppColor.grey
                                              : AppColor.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // DELETE BUTTON
                                if (fileName != null)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        fileBytes = null;
                                        fileName = null;
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 20,
                                      color: AppColor.red,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        verticalSpacing(),

                        // RADIO BUTTONS
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Upload with existing records?",
                              style: AppTextStyle.ts14SB(),
                            ),
                            verticalSpacing(),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: "yes",
                                      groupValue: uploadChoice,
                                      onChanged: (value) {
                                        setState(() {
                                          uploadChoice = value!;
                                        });
                                      },
                                    ),
                                    const Text("Yes"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: "no",
                                      groupValue: uploadChoice,
                                      onChanged: (value) {
                                        setState(() {
                                          uploadChoice = value!;
                                        });
                                      },
                                    ),
                                    const Text("No"),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        verticalSpacing(),

                        // EXPANSION TILE
                        Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            iconColor: AppColor.primary,
                            collapsedIconColor: AppColor.grey,
                            backgroundColor: AppColor.lightBlue.withValues(
                              alpha: .08,
                            ),
                            collapsedBackgroundColor: Colors.transparent,
                            title: Text("Notes", style: AppTextStyle.ts14SB()),
                            children: [
                              SizedBox(
                                height: 200,
                                child: Scrollbar(
                                  controller: expansionScrollController,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: expansionScrollController,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: Column(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        bulletText(
                                          "If Yes is selected, existing records will be kept and new data will be merged.",
                                        ),
                                        bulletText(
                                          "If No is selected, all existing records will be permanently deleted before uploading new data.",
                                        ),
                                        bulletText(
                                          "Only .xlsx, .xls, or .csv files are allowed.",
                                        ),
                                        bulletText(
                                          "Do not change the column header names in the downloaded sample Excel file.",
                                        ),
                                        bulletText(
                                          "Do not modify, remove, or add extra columns.",
                                        ),
                                        bulletText(
                                          "Do not write data outside the provided column boundaries.",
                                        ),
                                        bulletText(
                                          "Blank rows or completely empty columns should not be added.",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        verticalSpacing(height: 20),

                        /// MAIN BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton.cancelOutline(
                                onPressed: () {
                                  Navigator.pop(context, null);
                                },
                              ),
                            ),

                            horizontalSpacing(),

                            Expanded(
                              child: CustomButton(
                                backgroundColor:
                                    fileBytes == null
                                        ? AppColor.grey
                                        : AppColor.green,
                                text: "Import",
                                onPressed:
                                    fileBytes == null
                                        ? null
                                        : () {
                                          Navigator.pop(context, {
                                            "deleteAll": uploadChoice == "no",
                                            "fileBytes": fileBytes,
                                            "fileName": fileName,
                                          });
                                        },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<bool?> showUploadExcelDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Upload Excel Sheet", style: AppTextStyle.ts14M()),
                      InkWell(
                        onTap: () => goRouter.pop(),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                ),
                Container(color: AppColor.grey30, height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => goRouter.pop(true),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColor.slightDarkBlue.withValues(
                                  alpha: .05,
                                ),
                                border: Border.all(
                                  color: AppColor.slightDarkBlue.withValues(
                                    alpha: 0.8,
                                  ),
                                  style: BorderStyle.solid,
                                  strokeAlign: BorderSide.strokeAlignInside,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    AppAssets.excel,
                                    height: 47,
                                    width: 47,
                                  ),
                                  verticalSpacing(height: 8),
                                  Text(
                                    "Upload Excel",
                                    style: AppTextStyle.ts14M(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        horizontalSpacing(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => goRouter.pop(false),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColor.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColor.grey30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.grey.withValues(alpha: 0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                  BoxShadow(
                                    color: AppColor.grey.withValues(
                                      alpha: 0.09,
                                    ),
                                    blurRadius: 3,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    AppAssets.excel,
                                    height: 24,
                                    width: 24,
                                  ),
                                  verticalSpacing(height: 8),
                                  Text(
                                    "Download sample Excel Formate",
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.slightDarkBlue,
                                    ).copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColor.slightDarkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
