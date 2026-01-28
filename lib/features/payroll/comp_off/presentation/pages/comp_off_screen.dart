import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/presentation/cubit/comp_off_cubit.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/pages/leave_screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CompOffScreen extends StatefulWidget {
  const CompOffScreen({super.key});

  @override
  State<CompOffScreen> createState() => _CompOffScreenState();
}

class _CompOffScreenState extends State<CompOffScreen> {
  // CUBIT
  late CompOffCubit _compOffCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _compOffCubit = context.read<CompOffCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.compOff]!;
    _onScroll();
    _compOffCubit.getCompOffList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_compOffCubit.state.isLoading! &&
          _compOffCubit.state.compOffList.length <
              _compOffCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _compOffCubit.getCompOffList(
            context,
            _compOffCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Comp Off',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {},
        onAddCallback: () {},
        onFilterTap: () {},
      ),
      body: BlocBuilder<CompOffCubit, CompOffState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.compOffList.isEmpty) {
            return Center(child: loader());
          }
          if (state.compOffList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _compOffCubit.state.compOffList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.compOffList.length) {
                return state.compOffList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var compOff = state.compOffList[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          buildRowTitleValue(
                            title: "Comp-Off Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              compOff.compOffDate,
                            ),
                            customValueWidget: GestureDetector(
                              onTap: () {
                                goRouter.pushNamed(
                                  AppRoutes.viewCompOff,
                                  queryParameters: {
                                    "compOff": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(compOff),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Text(
                                formatDateTimeAsDDMMMYYYY(compOff.compOffDate),
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Working Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              compOff.workingDate,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Reason",
                            value: compOff.reason,
                          ),
                        ],
                      ),
                    ),
                    horizontalSpacing(),
                    _statusWidget("Pending"),
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
      margin: EdgeInsets.only(top: 10),
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
  StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return StatusConfig(
          label: "Pending",
          textColor: AppColor.white,
          backgroundColor: AppColor.darkBlue,
        );

      case "approved":
        return StatusConfig(
          label: "Approved",
          textColor: AppColor.white,
          backgroundColor: AppColor.green,
        );

      case "upcoming":
        return StatusConfig(
          label: "Upcoming",
          textColor: AppColor.white,
          backgroundColor: AppColor.warning,
        );

      case "rejected":
        return StatusConfig(
          label: "Rejected",
          textColor: AppColor.white,
          backgroundColor: AppColor.error,
        );

      default:
        return StatusConfig(
          label: status,
          textColor: AppColor.grey,
          backgroundColor: AppColor.grey.withValues(alpha: 0.1),
        );
    }
  }
}
