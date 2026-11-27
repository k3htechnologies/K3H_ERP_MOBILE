import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/cubit/tax_tracker_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewTaxTrackerMainScreen extends StatefulWidget {
  const ViewTaxTrackerMainScreen({super.key});

  @override
  State<ViewTaxTrackerMainScreen> createState() =>
      _ViewTaxTrackerMainScreenState();
}

class _ViewTaxTrackerMainScreenState extends State<ViewTaxTrackerMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Tax Tracker",
        authorization: AuthorizationModel(),
        isMenuButton: false,
      ),
      body: BlocBuilder<TaxTrackerCubit, TaxTrackerState>(
        builder: (context, state) {
          if (state.isLoading == true && state.taxTrackerList.isEmpty) {
            return Center(child: loader());
          }
          if (state.taxTrackerList.isEmpty) {
            return Center(
              child: noDataWidget(message: "No Tax Tracker Data Found"),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.taxTrackerList.first.noticeSection,
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                verticalSpacing(),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildRowTitleValue(
                        title: "Company Name",
                        value: state.taxTrackerList.first.companyName,
                        singleLine: false,
                      ),
                      buildRowTitleValue(
                        title: "Financial Year",
                        value: state.taxTrackerList.first.financialYear,
                        singleLine: false,
                      ),
                      buildRowTitleValue(
                        title: "Notice Status",
                        value: state.taxTrackerList.first.noticeStatus,
                        customValueWidget: taxTrackerNoticeStatusWidget(
                          state.taxTrackerList.first.noticeStatus,
                        ),
                        singleLine: false,
                      ),
                      buildRowTitleValue(
                        title: "Authority Type",
                        value: state.taxTrackerList.first.authority,
                        singleLine: false,
                      ),
                      buildRowTitleValue(
                        title: "Responsible Person",
                        value: state.taxTrackerList.first.responsiblePerson,
                        singleLine: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
