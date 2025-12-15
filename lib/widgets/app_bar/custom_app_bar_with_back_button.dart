import 'package:flutter/material.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomAppBarWithBackButton extends StatelessWidget
    implements PreferredSizeWidget {
  final String screenTitle;

  const CustomAppBarWithBackButton({super.key, required this.screenTitle});

  @override
  Size get preferredSize => Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: AppColor.white,
      centerTitle: true,
      elevation: 0.5,
      leading: IconButton(
        onPressed: () {
          goRouter.pop();
        },
        icon: Icon(Icons.arrow_back),
      ),
      title: Text(
        screenTitle,
        style: AppTextStyle.ts16SB(color: AppColor.black),
      ),
    );
  }
}
