import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MyApprovalScreen extends StatefulWidget {
  const MyApprovalScreen({super.key});

  @override
  State<MyApprovalScreen> createState() => _MyApprovalScreenState();
}

class _MyApprovalScreenState extends State<MyApprovalScreen> {
  late DashboardCubit _dashboardCubit;
  @override
  void initState() {
    super.initState();
    _dashboardCubit = context.read<DashboardCubit>();
    _dashboardCubit.getModuleApprovalList(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "My Approvals",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final approvals = state.moduleApprovalList;

          if (state.isLoading == true && approvals.isEmpty) {
            return Center(child: loader());
          }

          if (approvals.isEmpty) {
            return Center(child: noDataWidget(message: 'No approvals found'));
          }

          final Map<String, int> moduleCounts = {};

          for (final approval in approvals) {
            final module = approval.moduleName.trim();

            if (module.isNotEmpty) {
              moduleCounts[module] = (moduleCounts[module] ?? 0) + 1;
            }
          }

          final modules = moduleCounts.keys.toList();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                        modules.isEmpty
                            ? Center(
                              child: noDataWidget(
                                message: 'No approval modules found',
                              ),
                            )
                            : ListView.builder(
                              itemCount: modules.length,
                              itemBuilder: (context, index) {
                                final module = modules[index];

                                return _buildModuleApprovalCard(
                                  title: module,
                                  totalCount: moduleCounts[module]!,
                                  onTap: () {
                                    final selectedModuleApprovals =
                                        approvals
                                            .where(
                                              (approval) =>
                                                  approval.moduleName.trim() ==
                                                  module,
                                            )
                                            .toList();

                                    final encryptedData =
                                        EncryptionManager.encryptData(
                                          jsonEncode(
                                            selectedModuleApprovals.map((
                                              document,
                                            ) {
                                              return document.toJson();
                                            }).toList(),
                                          ),
                                        );

                                    goRouter.pushNamed(
                                      AppRoutes.myApprovalOverallScreen,
                                      queryParameters: {
                                        "moduleApprovalModel":
                                            Uri.encodeQueryComponent(
                                              encryptedData,
                                            ),
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModuleApprovalCard({
    required String title,
    required int totalCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: AppColor.primary, width: 4)),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: AppColor.white.withValues(alpha: 0.5),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyle.ts14M(
                      color: AppColor.greyTitleAndValueColor,
                    ),
                  ),
                ),
                horizontalSpacing(width: 20),
                Container(
                  constraints: const BoxConstraints(minWidth: 32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xffF0DEFF),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    '$totalCount',
                    style: AppTextStyle.ts12SB(color: const Color(0xff7E22CE)),
                  ),
                ),

                horizontalSpacing(),
                Icon(LucideIcons.chevronRight, size: 20, color: AppColor.black),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
