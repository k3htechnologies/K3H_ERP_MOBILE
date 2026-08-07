import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/model/leave_encashment_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/cubit/leave_encashment_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/cubit/leave_encashment_master_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LeaveEncashmentScreen extends StatefulWidget {
  const LeaveEncashmentScreen({super.key});

  @override
  State<LeaveEncashmentScreen> createState() => _LeaveEncashmentScreenState();
}

class _LeaveEncashmentScreenState extends State<LeaveEncashmentScreen> {
  //CUBIT
  late LeaveEncashmentMasterCubit _leaveEncashmentMasterCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _leaveEncashmentMasterCubit = context.read<LeaveEncashmentMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.leaveEncashmentMaster] ??
        AuthorizationModel();
    _searchC = TextEditingController();
    _onScroll();
    _leaveEncashmentMasterCubit.getLeaveEncashmentList(
      context: context,
      pageNumber: 1,
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _searchC.dispose();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_leaveEncashmentMasterCubit.state.isLoading ?? false) &&
          _leaveEncashmentMasterCubit.state.leaveEncashmentList.length <
              _leaveEncashmentMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _leaveEncashmentMasterCubit.getLeaveEncashmentList(
            context: context,
            pageNumber: _leaveEncashmentMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // DELETE LEAVE ENCASHMENT
  Future<void> _showPopupToDeleteLeaveEncashmentMaster(
    BuildContext context,
    LeaveEncashmentMasterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Leave Encashment?',
      'Deleting this Leave Encashment will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _leaveEncashmentMasterCubit.deleteLeaveEncashment(index, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Leave Encashment Master",
        authorization: _routeAuthorizationModel,
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addLeaveEncashmentMaster);
        },
        onExportCallback: (value) {
          if (_leaveEncashmentMasterCubit.state.totalNumberOfRecord == 0) {
            return showErrorMessage(context, "", "No Data Found");
          }
          _leaveEncashmentMasterCubit.exportExcelPdf(context, value);
        },
        textController: _searchC,
        searchHintText: "Search by Earning Name",
        onSearchSubmit: (value) {
          _leaveEncashmentMasterCubit.searchLeaveEnhancement(context, value);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _leaveEncashmentMasterCubit.searchLeaveEnhancement(context, "");
        },
        child: Column(
          children: [
            BlocBuilder<LeaveEncashmentMasterCubit, LeaveEncashmentMasterState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) &&
                    state.leaveEncashmentList.isEmpty) {
                  return Expanded(child: Center(child: loader()));
                }
                if (state.leaveEncashmentList.isEmpty) {
                  return Expanded(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: getActualHeight(context) * .7,
                          child: Center(
                            child: noDataWidget(
                              message: "No Leave Encashment Found",
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: state.leaveEncashmentList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.leaveEncashmentList.length) {
                        return state.leaveEncashmentList.length <
                                state.totalNumberOfRecord
                            ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      var leaveEncashment = state.leaveEncashmentList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: commonCardDecoration(),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    leaveEncashment.earningMasterName,
                                    style: AppTextStyle.ts16M(),
                                  ),
                                ),
                                horizontalSpacing(),
                                CustomIconButton.edit(
                                  onPressed: () async {
                                    await goRouter.pushNamed(
                                      AppRoutes.addLeaveEncashmentMaster,
                                      queryParameters: {
                                        "leaveEncashment":
                                            Uri.encodeQueryComponent(
                                              EncryptionManager.encryptData(
                                                jsonEncode(
                                                  leaveEncashment.toJson(),
                                                ),
                                              ),
                                            ),
                                        'index': index.toString(),
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                CustomIconButton.delete(
                                  onPressed: () {
                                    _showPopupToDeleteLeaveEncashmentMaster(
                                      context,
                                      leaveEncashment,
                                      state.currentPage,
                                      index,
                                    );
                                  },
                                ),
                              ],
                            ),
                            verticalSpacing(height: 10),
                            buildRowTitleValue(
                              title: "Minimum Salary",
                              value:
                                  leaveEncashment.minSalary.toIndianCurrency(),
                            ),
                            buildRowTitleValue(
                              title: "Maximum Salary",
                              value:
                                  leaveEncashment.maxSalary.toIndianCurrency(),
                            ),
                            buildRowTitleValue(
                              title: "Encashment Rate",
                              value: "${leaveEncashment.encashmentRate} %",
                            ),
                            buildRowTitleValue(
                              title: "Created By",
                              value: leaveEncashment.createdBy,
                            ),
                            buildRowTitleValue(
                              title: "Created Date",
                              value: formatDate(leaveEncashment.createdDate),
                            ),
                            buildRowTitleValue(
                              title: "Modified By",
                              value: leaveEncashment.modifiedBy,
                            ),
                            buildRowTitleValue(
                              title: "Modified Date",
                              value:
                                  leaveEncashment.modifiedDate != null
                                      ? formatDate(
                                        leaveEncashment.modifiedDate!,
                                      )
                                      : "",
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // BUILD ROW TITLE VALUE
  Widget buildRowTitleValue({required String title, required String value}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          SizedBox(
            width: 160,
            child: Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
          ),

          // COLON
          SizedBox(
            width: 20,
            child: Text(
              ":",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.grey),
            ),
          ),

          // VALUE
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.ts14R(),
            ),
          ),
        ],
      ),
    );
  }
}
