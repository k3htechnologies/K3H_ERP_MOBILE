// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'dart:ui';

import 'package:country_flags/country_flags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_snack_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../core/country_code.dart';

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
                  Icon(Icons.info_outline, size: 50, color: AppColor.primary),
                  Text(
                    "Menu Changed",
                    style: AppTextStyle.ts20R(color: AppColor.primary),
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
                    onPressed: () async {
                      LocalStorageManager().remove(StorageKey.menu);
                      await Authorization.reset();
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
                          text: "Delete",
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
                          text: "Logout",
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

  // BOTTOM SHEE
  static Future showCustomBottomSheet(
    BuildContext context,
    String title, {
    required Widget contentWidget,
    Widget? bottomActions,
  }) async {
    final scrollController = ScrollController();

    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            width: getActualWidth(context),
            height: getActualHeight(context) * 0.50,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // DRAG HANDLE
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

                // TITLE
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.only(bottom: 10, left: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(title, style: AppTextStyle.ts16SB()),
                  ),
                ),

                Divider(color: AppColor.grey, thickness: .3),

                // CONTENT WITH SCROLLBAR
                Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16.h),
                      child: contentWidget,
                    ),
                  ),
                ),

                // FIXED BUTTON
                if (bottomActions != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: bottomActions,
                  ),
              ],
            ),
          ),
        );
      },
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

  static Future<CountryCode?> showCountryPickerBottomSheet(
    BuildContext context, {
    required List<CountryCode> countries,
    CountryCode? selectedCountry,
  }) async {
    CountryCode? tempSelected = selectedCountry;

    final TextEditingController searchC = TextEditingController();

    List<CountryCode> filteredCountries = List.from(countries);

    return await showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        final double bottomSheetHeight = (screenHeight * 0.52);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: bottomSheetHeight,

              decoration: const BoxDecoration(
                color: AppColor.white,

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),

                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Select Country",
                            style: AppTextStyle.ts20M(),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },

                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: 1.0,

                    decoration: const BoxDecoration(color: AppColor.grey),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    child: SearchWidget(
                      isFilterOn: false,
                      hintText: "Search By Country Name",
                      textController: searchC,
                      onSubmit: (value) async {
                        setModalState(() {
                          filteredCountries =
                              countries.where((e) {
                                final search = value.toLowerCase();

                                return e.name.toLowerCase().contains(search) ||
                                    e.code.contains(search);
                              }).toList();
                        });
                      },
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),

                      child: ListView.builder(
                        itemCount: filteredCountries.length,

                        itemBuilder: (context, index) {
                          final country = filteredCountries[index];

                          final isSelected =
                              tempSelected?.countryCode == country.countryCode;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,

                            children: [
                              InkWell(
                                onTap: () {
                                  setModalState(() {
                                    tempSelected = country;
                                  });
                                },

                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),

                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),

                                        child:
                                            isSelected
                                                ? Icon(
                                                  Icons.radio_button_checked,

                                                  color: AppColor.primary,

                                                  size: 20,
                                                )
                                                : Icon(
                                                  Icons.radio_button_unchecked,

                                                  color: AppColor.black,

                                                  size: 20,
                                                ),
                                      ),
                                      CountryFlag.fromCountryCode(
                                        country.countryCode,
                                        theme: ImageTheme(
                                          width: 30.w,
                                          height: 20.h,
                                          shape: RoundedRectangle(6),
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Flexible(
                                        child: Text(
                                          "${country.name} (${country.code})",

                                          style: AppTextStyle.ts14R(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Container(height: 1, color: AppColor.grey30),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),

                      child: ElevatedButton(
                        style: ButtonStyle(
                          fixedSize: WidgetStateProperty.all(
                            const Size(30, 40),
                          ),

                          backgroundColor: WidgetStateProperty.all(
                            AppColor.primary,
                          ),
                        ),

                        onPressed: () {
                          Navigator.pop(context, tempSelected);
                        },

                        child: Text(
                          'Select',

                          style: AppTextStyle.ts14M(color: AppColor.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // CUSTOM DIALOG
  static Future showCustomDialogue(
    BuildContext context, {
    required Widget childContent,
    String? title,
    Widget? icon,
    Widget? bottomSection, // optional
    bool barrierDismissible = true,
    void Function()? onDismiss,
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
                    if (icon != null) ...[icon, horizontalSpacing()],
                    if (title != null)
                      Expanded(child: Text(title, style: AppTextStyle.ts14M())),
                    GestureDetector(
                      onTap: () {
                        goRouter.pop();
                        onDismiss?.call();
                      },
                      child: Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
                verticalSpacing(),

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

  // <--- IMPORT  DIALOG ---->
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
                              "Upload Excel",
                              style: AppTextStyle.ts20R(
                                color: AppColor.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
                              "Do you want to upload the file with existing record?",
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
                                        bulletRichText([
                                          const TextSpan(text: "If "),
                                          TextSpan(
                                            text: "Yes",
                                            style: AppTextStyle.ts14SB(),
                                          ),
                                          const TextSpan(
                                            text:
                                                " is selected, existing records will be kept and new data will be merged.",
                                          ),
                                        ]),

                                        bulletRichText([
                                          const TextSpan(text: "If "),
                                          TextSpan(
                                            text: "No",
                                            style: AppTextStyle.ts14R(
                                              color: AppColor.error,
                                            ),
                                          ),
                                          const TextSpan(
                                            text:
                                                " is selected, all existing records will be permanently deleted before uploading new data.",
                                          ),
                                        ]),

                                        bulletRichText([
                                          const TextSpan(
                                            text:
                                                "Only .xlsx, .xls, or .csv files are allowed.",
                                          ),
                                        ]),

                                        bulletRichText([
                                          const TextSpan(text: "Do "),
                                          TextSpan(
                                            text:
                                                "not change the column header names",
                                            style: AppTextStyle.ts14SB(),
                                          ),
                                          const TextSpan(
                                            text:
                                                " in the downloaded sample Excel file.",
                                          ),
                                        ]),

                                        bulletRichText([
                                          const TextSpan(text: "Do "),
                                          TextSpan(
                                            text:
                                                "not modify, remove, or add extra columns.",
                                            style: AppTextStyle.ts14SB(),
                                          ),
                                        ]),

                                        bulletRichText([
                                          const TextSpan(text: "Do "),
                                          TextSpan(
                                            text:
                                                "not write data outside the provided column boundaries.",
                                            style: AppTextStyle.ts14SB(),
                                          ),
                                        ]),

                                        bulletRichText([
                                          const TextSpan(
                                            text:
                                                "Blank rows or completely empty columns should not be added.",
                                          ),
                                        ]),
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
