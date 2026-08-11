import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/dashboard/data/model/user_dashboard.model.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Widget buildReportingManagerWidget(BuildContext context) {
  return BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      if (state.isLoading == true) {
        return Center(child: loader());
      }

      final userData = state.userData;

      final table10List = userData?.table10;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: commonCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Reporting Manager",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpacing(height: 20),
            if (_hasValidManager(table10List)) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                isThreeLine: true,
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColor.primary,
                  child:
                      table10List!.first.profilePhotoURL.isNotEmpty
                          ? ClipOval(
                            child: NetworkImageWidget(
                              key: ValueKey(table10List.first.profilePhotoURL),
                              imageUrl: table10List.first.profilePhotoURL,
                              fit: BoxFit.fill,
                              width: 50.w,
                              height: 50.h,
                            ),
                          )
                          : Text(
                            table10List.first.managerName.isNotEmpty
                                ? getInitials(table10List.first.managerName)
                                : 'U',
                            style: AppTextStyle.ts24B(color: AppColor.white),
                          ),
                ),
                title: Text(
                  table10List.first.managerName,
                  style: AppTextStyle.ts14B(),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      table10List.first.managerDesignation,
                      style: AppTextStyle.ts14R(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                    Text(
                      table10List.first.managerDepartment,
                      style: AppTextStyle.ts14R(),
                    ),
                  ],
                ),
              ),
              verticalSpacing(),

              CustomClickToContactText(
                value: table10List.first.managerEmail,
                type: ContactType.email,
              ),
              verticalSpacing(),
              CustomClickToContactText(value: table10List.first.managerPhone),
            ] else ...[
              Center(
                child: Text(
                  "No Data Found",
                  style: AppTextStyle.ts12M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

bool _hasValidManager(List<Table10>? list) {
  if (list == null || list.isEmpty) return false;

  final m = list.first;

  return (m.managerName.trim().isNotEmpty) ||
      (m.managerEmail.trim().isNotEmpty) ||
      (m.managerPhone.trim().isNotEmpty);
}
