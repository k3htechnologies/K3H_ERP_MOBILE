import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

// BUILD QUICK ACTIONS WIDGET
Widget buildQuickActionsWidget(BuildContext context) {
  final actions = [
    QuickActionItem(
      icon: SvgPicture.asset(AppAssets.applyLeaveIcon),
      text: "Apply Leave",
      backgroundColor: AppColor.lightBlue,
      onTap: () {
        goRouter.pushNamed(AppRoutes.applyLeave);
      },
    ),
    QuickActionItem(
      icon: SvgPicture.asset(AppAssets.raiseTaskIcon),
      text: "Raise Task",
      backgroundColor: AppColor.purple20.withValues(alpha: .08),
      onTap: () => showComingSoonDialog(context),
    ),
    QuickActionItem(
      icon: SvgPicture.asset(AppAssets.applyAdvanceIcon),
      text: "Apply Advance",
      backgroundColor: AppColor.lightYellow.withValues(alpha: .5),
      onTap: () => showComingSoonDialog(context),
    ),
    QuickActionItem(
      icon: SvgPicture.asset(AppAssets.regularizeIcon),
      text: "Regularize",
      backgroundColor: AppColor.lightGreen.withValues(alpha: .5),
      onTap: () {
        goRouter.pushNamed(AppRoutes.attendance);
      },
    ),
    QuickActionItem(
      icon: SvgPicture.asset(AppAssets.requestAssetIcon),
      text: "Request Asset",
      backgroundColor: AppColor.lightOrangeBg.withValues(alpha: .5),
      onTap: () => showComingSoonDialog(context),
    ),
    QuickActionItem(
      icon: SvgPicture.asset(AppAssets.payslipIcon),
      text: "Payslip",
      backgroundColor: AppColor.red.withValues(alpha: .08),
      onTap: () => showComingSoonDialog(context),
    ),
  ];

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: commonCardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: AppTextStyle.ts14M(
            color: AppColor.black.withValues(alpha: 0.50),
          ),
        ),

        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.h,
            childAspectRatio: 1.25,
            mainAxisExtent: 90.h,
          ),
          itemBuilder: (context, index) {
            final item = actions[index];

            return _quickActionCard(
              icon: item.icon,
              text: item.text,
              backgroundColor: item.backgroundColor,
              onTap: item.onTap,
            );
          },
        ),
      ],
    ),
  );
}

// QUICK ACTION CARD
Widget _quickActionCard({
  required Widget icon,
  required String text,
  required VoidCallback onTap,
  Color? backgroundColor,
}) {
  return Column(
    spacing: 10,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CustomIconButton(
        onPressed: onTap,
        icon: icon,
        size: 24,
        backgroundColor: backgroundColor ?? AppColor.lightBlue,
      ),
      Text(text, style: AppTextStyle.ts12M(), textAlign: TextAlign.center),
    ],
  );
}

class QuickActionItem {
  final Widget icon;
  final String text;
  final Color backgroundColor;
  final VoidCallback onTap;
  QuickActionItem({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.onTap,
  });
}

void showComingSoonDialog(BuildContext context) {
  DialogHelper.showCustomDialogue(
    context,
    icon: CustomIconButton(
      onPressed: () {},
      icon: Icon(
        Icons.warning_amber_outlined,
        color: AppColor.yellow,
        size: 16,
      ),
      backgroundColor: AppColor.yellow.withValues(alpha: .2),
    ),
    title: "COMING SOON",
    childContent: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColor.black.withValues(alpha: 0.50), thickness: 0.5),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            "This feature is currently under development and will be available soon.",
            style: AppTextStyle.ts14SB(),
          ),
        ),
      ],
    ),
  );
}
