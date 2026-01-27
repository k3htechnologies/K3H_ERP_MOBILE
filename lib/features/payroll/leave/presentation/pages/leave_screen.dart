import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/cubit/leave_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  // CUBIT
  late LeaveCubit _leaveCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _leaveCubit = context.read<LeaveCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.leave]!;
    _initializeTextEditingController();
    _onScroll();
    _leaveCubit.getLeaveList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    scrollController.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_leaveCubit.state.isLoading! &&
          _leaveCubit.state.leaveList.length <
              _leaveCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _leaveCubit.getLeaveList(context, _leaveCubit.state.currentPage + 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Leave",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {},
        onExportCallback: (value) {},
        secondaryBuilder:
            (_) => CustomButton(
              text: "Apply",
              onPressed: () async {
                await goRouter.pushNamed(AppRoutes.applyLeave);
                if (context.mounted) {
                  _leaveCubit.getLeaveList(context, 1);
                }
              },
              backgroundColor: AppColor.primary,
              leading: Icon(Icons.add, size: 16, color: AppColor.white),
            ),
      ),
      body: BlocBuilder<LeaveCubit, LeaveState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.leaveList.isEmpty) {
            return Center(child: loader());
          }
          if (state.leaveList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _leaveCubit.state.leaveList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.leaveList.length) {
                return state.leaveList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var leave = state.leaveList[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 5,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            goRouter.pushNamed(AppRoutes.viewLeave);
                          },
                          child: Container(
                            padding: EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColor.primary),
                              ),
                            ),
                            child: Text(
                              leave.leaveType,
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        _statusWidget("Pending"),
                      ],
                    ),
                    buildRowTitleValue(
                      title: "Dates",
                      value:
                          "${formatDateTimeAsDDMMMYYYY(leave.startDate)}-${formatDateTimeAsDDMMMYYYY(leave.endDate)}",
                    ),
                    buildRowTitleValue(
                      title: "No. Of Days",
                      value: leave.noOfDays.toString(),
                    ),
                    buildRowTitleValue(title: "Reason", value: leave.reason),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // STATUS WIDGET
  Widget _statusWidget(String status) {
    final statusConfig = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusConfig.label,
        style: AppTextStyle.ts12M().copyWith(color: statusConfig.textColor),
      ),
    );
  }

  // HELPER METHOD TO GET STATUS CONFIG
  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return _StatusConfig(
          label: "Pending",
          textColor: AppColor.white,
          backgroundColor: AppColor.darkBlue,
        );

      case "approved":
        return _StatusConfig(
          label: "Approved",
          textColor: AppColor.white,
          backgroundColor: AppColor.green,
        );

      case "upcoming":
        return _StatusConfig(
          label: "Upcoming",
          textColor: AppColor.white,
          backgroundColor: AppColor.warning,
        );

      case "rejected":
        return _StatusConfig(
          label: "Rejected",
          textColor: AppColor.white,
          backgroundColor: AppColor.error,
        );

      default:
        return _StatusConfig(
          label: status,
          textColor: AppColor.grey,
          backgroundColor: AppColor.grey.withValues(alpha: 0.1),
        );
    }
  }
}

// HELPER CLASS TO STORE STATUS CONFIG
class _StatusConfig {
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const _StatusConfig({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });
}
