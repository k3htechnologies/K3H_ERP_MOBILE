import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

class CustomAppBarWithBackButton extends StatelessWidget
    implements PreferredSizeWidget {
  final String screenTitle;
  final AuthorizationModel authorization;
  final bool showNotification;
  final Function? onAddCallback;
  final Function(String)? onExportCallback;

  const CustomAppBarWithBackButton({
    super.key,
    required this.screenTitle,
    required this.authorization,
    this.showNotification = false,
    this.onAddCallback,
    this.onExportCallback,
  });

  @override
  Size get preferredSize => Size.fromHeight(50);

  Widget _buildAction({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: CustomIconButton(
        icon: Icon(icon, size: 16, color: iconColor),
        onPressed: onTap,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: AppColor.lightGreyBackground,
      centerTitle: false,
      leading: GestureDetector(
        onTap: () {
          if (goRouter.canPop()) {
            goRouter.pop();
          }
        },
        child: Icon(Icons.arrow_back),
      ),
      title: Text(
        screenTitle,
        style: AppTextStyle.ts16SB(color: AppColor.black),
      ),
      actions:
          authorization.isAction
              ? [
                if (onAddCallback != null)
                  _buildAction(
                    icon: Icons.add,
                    onTap: () {
                      onAddCallback!();
                    },
                    backgroundColor: AppColor.lightGreen,
                    iconColor: AppColor.darkGreen,
                  ),

                if (onExportCallback != null)
                  _buildAction(
                    icon: Icons.file_download,
                    onTap: () {
                      final box = context.findRenderObject() as RenderBox;
                      final position = box.localToGlobal(Offset.zero);
                      CustomOverlayMenu.show(
                        width: 180,
                        context: context,
                        position: Offset(position.dx + 10, position.dy + (115)),
                        items: [
                          AddImportExportOverlayMenuItem(
                            icon: Icons.file_download_outlined,
                            label: 'Export Excel',
                            value: 'EXCEL',
                            onTap: onExportCallback!,
                            iconColor: AppColor.primary,
                          ),
                          AddImportExportOverlayMenuItem(
                            icon: Icons.file_download_outlined,
                            label: 'Export PDF',
                            value: 'PDF',
                            onTap: onExportCallback!,
                            iconColor: AppColor.primary,
                          ),
                        ],
                      );
                    },
                    backgroundColor: AppColor.lightBlue,
                    iconColor: AppColor.primary,
                  ),

                if (showNotification)
                  _buildAction(
                    icon: Icons.notifications_none,
                    onTap: () {},
                    backgroundColor: AppColor.lightBlue,
                    iconColor: AppColor.primary,
                  ),
                /*
        if (authorization.canDelete)
          _buildAction(
            icon: Icons.delete,
            onTap: onDeleteCallback!,
          ),*/
              ]
              : [],
    );
  }
}
