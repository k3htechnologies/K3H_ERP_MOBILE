import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/dashboard/data/model/user_dashboard.model.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _ApprovalModuleConfig {
  final String title;
  final String keyword;
  final String? icon;
  final IconData? iconData;
  final Color iconBg;
  final Color iconColor;
  final String onViewRoute;
  final List<Map<String, String?>> Function(Table13 e) fieldsBuilder;

  const _ApprovalModuleConfig({
    required this.title,
    required this.keyword,
    this.icon,
    this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.onViewRoute,
    required this.fieldsBuilder,
  });
}

/// ---- Shared field builders (reused across several modules) ----
List<Map<String, String?>> _inventoryFields(Table13 e) => [
  {"title": "Project", "value": e.projectName},
  {"title": "Building", "value": e.buildingNumber},
  {"title": "Wing", "value": e.wing},
];

List<Map<String, String?>> _parkingFields(Table13 e) => [
  {"title": "Project", "value": e.projectName},
  {"title": "Building", "value": e.buildingNumber},
  {"title": "Wing", "value": e.wing},
  {"title": "Floor", "value": e.floor},
];

List<Map<String, String?>> _bookingLikeFields(Table13 e) => [
  {"title": "Project", "value": e.projectName},
  {"title": "Flat", "value": e.flat},
  {"title": "Applicant", "value": e.applicantName},
];

/// ---- Single source of truth for all modules (order == render order) ----
final List<_ApprovalModuleConfig> _approvalModuleConfigs = [
  _ApprovalModuleConfig(
    title: "Inventory",
    keyword: "inventory",
    icon: AppAssets.boxIcon,
    iconBg: AppColor.lightBluebg,
    iconColor: AppColor.primary,
    onViewRoute: AppRoutes.inventory,
    fieldsBuilder: _inventoryFields,
  ),
  _ApprovalModuleConfig(
    title: "Parking",
    keyword: "parking",
    icon: AppAssets.car,
    iconBg: AppColor.lightGreen.withValues(alpha: 0.3),
    iconColor: AppColor.darkGreen,
    onViewRoute: AppRoutes.parking,
    fieldsBuilder: _parkingFields,
  ),
  _ApprovalModuleConfig(
    title: "Booking",
    keyword: "booking",
    iconData: LucideIcons.clipboardCheck,
    iconBg: AppColor.lightOrange,
    iconColor: AppColor.rustOrange,
    onViewRoute: AppRoutes.booking,
    fieldsBuilder: _bookingLikeFields,
  ),
  _ApprovalModuleConfig(
    title: "CRM Payment Ledger",
    keyword: "crm payment ledger",
    iconData: LucideIcons.wallet,
    iconBg: AppColor.lightBlue,
    iconColor: AppColor.primary,
    onViewRoute: AppRoutes.payTrackMaster,
    fieldsBuilder: _bookingLikeFields,
  ),
  _ApprovalModuleConfig(
    title: "Booking Applicant Modification",
    keyword: "booking applicant modification",
    iconData: LucideIcons.userCog,
    iconBg: AppColor.lightGreen.withValues(alpha: 0.3),
    iconColor: AppColor.darkGreen,
    onViewRoute: AppRoutes.payTrackMaster,
    fieldsBuilder: _bookingLikeFields,
  ),
  _ApprovalModuleConfig(
    title: "Flat Alteration",
    keyword: "flat alteration",
    iconData: Icons.home_work_outlined,
    iconBg: AppColor.lightOrange,
    iconColor: AppColor.rustOrange,
    onViewRoute: AppRoutes.payTrackMaster,
    fieldsBuilder: _bookingLikeFields,
  ),
  _ApprovalModuleConfig(
    title: "Parking Modification",
    keyword: "parking modification",
    iconData: LucideIcons.car,
    iconBg: AppColor.purple700.withValues(alpha: 0.1),
    iconColor: AppColor.purple700,
    onViewRoute: AppRoutes.payTrackMaster,
    fieldsBuilder: _bookingLikeFields,
  ),
  _ApprovalModuleConfig(
    title: "Refund Payment Ledger",
    keyword: "refund payment ledger",
    iconData: LucideIcons.receiptIndianRupee,
    iconBg: AppColor.lightRed,
    iconColor: AppColor.red.withValues(alpha: 0.8),
    onViewRoute: AppRoutes.payTrackMaster,
    fieldsBuilder: _bookingLikeFields,
  ),
  _ApprovalModuleConfig(
    title: "Flat Handover",
    keyword: "flat handover",
    iconData: LucideIcons.keyRound,
    iconBg: AppColor.lightBlue,
    iconColor: AppColor.mediumBlue,
    onViewRoute: AppRoutes.payTrackMaster,
    fieldsBuilder: _bookingLikeFields,
  ),
  _ApprovalModuleConfig(
    title: "Cancel Booking",
    keyword: "cancel booking",
    iconData: LucideIcons.clipboardCheck,
    iconBg: AppColor.purple700.withValues(alpha: 0.1),
    iconColor: AppColor.purple700,
    onViewRoute: AppRoutes.payTrackMaster,
    fieldsBuilder: _bookingLikeFields,
  ),
];

Widget pendingApprovalWidget() {
  return BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      final table13 = state.userData?.table13 ?? [];

      final visibleModules =
          _approvalModuleConfigs
              .map((config) {
                final items =
                    table13
                        .where(
                          (i) =>
                              i.moduleName.trim().toLowerCase() ==
                              config.keyword.trim().toLowerCase(),
                        )
                        .toList();
                return (config: config, items: items);
              })
              .where((entry) => entry.items.isNotEmpty)
              .toList();

      return Container(
        decoration: commonCardDecoration(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pending Approvals",
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.50),
              ),
            ),
            verticalSpacing(height: 12),

            if (visibleModules.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Expanded(child: Text("Type", style: AppTextStyle.ts12R())),
                    Text("Count", style: AppTextStyle.ts12R()),
                  ],
                ),
              ),
              for (final (index, entry) in visibleModules.indexed)
                _approvalTile(
                  title: entry.config.title,
                  count: entry.items.length,
                  icon: entry.config.icon,
                  iconData: entry.config.iconData,
                  iconBg: entry.config.iconBg,
                  iconColor: entry.config.iconColor,
                  // Dynamic: only the last *visible* tile has no bottom border,
                  // regardless of which module ends up last.
                  removeBorder: index == visibleModules.length - 1,
                  onTap: () {
                    final data =
                        entry.items.map(entry.config.fieldsBuilder).toList();

                    goRouter.pushNamed(
                      AppRoutes.pendingApprovalScreen,
                      queryParameters: {
                        "title": entry.config.title,
                        "onViewRoute": entry.config.onViewRoute,
                        "pendingApproval": Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(jsonEncode(data)),
                        ),
                      },
                    );
                  },
                ),
            ] else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  noDataWidget(
                    iconSize: 100,
                    message: "No module approval data",
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}

Widget _approvalTile({
  required String title,
  required int count,
  required VoidCallback onTap,
  required Color iconBg,
  required Color iconColor,
  bool removeBorder = false,
  String? icon,
  IconData? iconData,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border:
            !removeBorder
                ? Border(bottom: BorderSide(color: AppColor.grey30))
                : null,
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child:
                icon != null
                    ? SvgPicture.asset(
                      icon,
                      height: 20,
                      width: 20,
                      // ignore: deprecated_member_use
                      color: iconColor,
                    )
                    : Icon(iconData, size: 20, color: iconColor),
          ),

          horizontalSpacing(width: 14),

          Expanded(child: Text(title, style: AppTextStyle.ts14M())),

          Text(count.toString(), style: AppTextStyle.ts14M()),

          horizontalSpacing(width: 14),
          Container(
            height: 24.h,
            width: 24.w,
            decoration: BoxDecoration(
              color: AppColor.lightBluebg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.chevron_right, size: 18),
          ),
        ],
      ),
    ),
  );
}
