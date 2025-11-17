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
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DialogHelper{

  // <----PROCESSING DIALOG ---->
  static void showProcessingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
        child: Container(
          width: 150.0,
          height: 150.0,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                verticalSpacing(height: 20.0),
                Row(
                  children: [
                    Image.asset(
                      AppAssets.appLogo,
                      width: 50.0,
                      height: 50.0,
                    ),
                    const SizedBox(width: 10.0),
                    Text("K3H ERP", style: AppTextStyle.ts14B()),
                  ],
                ),
                const Divider(),
                const Spacer(),
                CircularProgressIndicator(
                  color: AppColor.primary,
                  strokeWidth: 2.0,
                ),
                verticalSpacing(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // <---- SUCCESS DIALOG ---->
  static Future successDialog(BuildContext context, {String? title}) async {
    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: 400,
            height: 200,
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border.all(color: AppColor.green, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppAssets.successLogo),
                Text(
                  title ?? "Success!",
                  style: AppTextStyle.ts16R(color: AppColor.green),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // <---- ERROR DIALOG ---->
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
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
                spacing: 18,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 100,
                    color: AppColor.yellow,
                  ),
                  Text(
                    title,
                    style: AppTextStyle.ts20R(color: AppColor.yellow),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(
                    child: Text(
                      message,
                      style: AppTextStyle.ts16R(color: AppColor.grey),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                  Icon(Icons.warning_rounded, size: 80, color: AppColor.red),
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
            horizontal: 40.0,
            vertical: 80.0,
          ),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.error, width: 1),
                color: AppColor.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  verticalSpacing(height: 25),
                  Icon(Icons.delete, color: AppColor.error, size: 52),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomButton(
                          backgroundColor: AppColor.lightGrey,
                          textColor: AppColor.black,
                          onPressed: () => goRouter.pop(false),
                          text: "Cancel",
                        ),
                        horizontalSpacing(),
                        CustomButton(
                          backgroundColor: AppColor.error,
                          textColor: AppColor.white,
                          onPressed: () => goRouter.pop(true),
                          text: "Delete",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
          (BuildContext context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        width: getActualWidth(context),
        height: getActualHeight(context) * 0.90,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    goRouter.pop();
                  },
                  child: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: AppColor.black,
                    size: 32.0,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Align(
                alignment: Alignment.center,
                child: Text(title, style: AppTextStyle.ts16R()),
              ),
            ),

            Expanded(
              child: ColoredBox(
                color: AppColor.greyBackground,
                child: contentWidget,
              ),
            ),
            verticalSpacing(height: 10.0),
          ],
        ),
      ),
    );
  }

}