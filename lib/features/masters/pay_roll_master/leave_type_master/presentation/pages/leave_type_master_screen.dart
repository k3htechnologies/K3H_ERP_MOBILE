import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/cubit/leave_type_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/cubit/leave_type_master_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LeaveTypeMasterScreen extends StatefulWidget {
  const LeaveTypeMasterScreen({super.key});

  @override
  State<LeaveTypeMasterScreen> createState() => _LeaveTypeMasterScreenState();
}

class _LeaveTypeMasterScreenState extends State<LeaveTypeMasterScreen> {
  //CUBIT
  late LeaveTypeMasterCubit _leaveTypeMasterCubit;

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
    _leaveTypeMasterCubit = context.read<LeaveTypeMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.leaveTypeMaster] ??
        AuthorizationModel();

    _onScroll();
    _initializeTextEditingController();
    _leaveTypeMasterCubit.getLeaveTypeList(
      context: context,
      pageNumber: 1,
      pageSize: 10,
    );
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_leaveTypeMasterCubit.state.isLoading ?? false) &&
          _leaveTypeMasterCubit.state.leaveTypeList.length <
              _leaveTypeMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _leaveTypeMasterCubit.getLeaveTypeList(
            context: context,
            pageNumber: _leaveTypeMasterCubit.state.currentPage + 1,
            pageSize: 10,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteLeaveTypeMaster(
    BuildContext context,
    LeaveTypeModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Leave Type?',
      'Deleting this Leave Type will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _leaveTypeMasterCubit.deleteLeaveType(index, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Leave Type Master",
        authorization: _routeAuthorizationModel,
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addLeaveTypeMaster);
        },
        textController: _searchC,
        onExportCallback: (value) {
          _leaveTypeMasterCubit.exportExcelPdf(context, value);
        },
        onSearchSubmit: (value) {
          _leaveTypeMasterCubit.searchLeaveType(value, context);
        },
      ),
      body: BlocBuilder<LeaveTypeMasterCubit, LeaveTypeMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.leaveTypeList.isEmpty) {
            return Center(child: loader());
          }
          if (state.leaveTypeList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.leaveTypeList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.leaveTypeList.length) {
                return state.leaveTypeList.length < state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var leaveType = state.leaveTypeList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomIconButton.edit(
                          onPressed: () async {
                            await goRouter.pushNamed(
                              AppRoutes.addLeaveTypeMaster,
                              queryParameters: {
                                "leaveType": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(leaveType.toJson()),
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
                            _showPopupToDeleteLeaveTypeMaster(
                              context,
                              leaveType,
                              state.currentPage,
                              index,
                            );
                          },
                        ),
                      ],
                    ),
                    verticalSpacing(height: 10),
                    _buildRowTitleValue(
                      title: "Leave Type",
                      value: leaveType.leaveType,
                    ),
                    _buildRowTitleValue(
                      title: "Leave Type Code",
                      value: leaveType.leaveTypeCode,
                    ),
                    _buildRowTitleValue(
                      title: "Carry Forward",
                      value: leaveType.isCarryForward == true ? "Yes" : "No",
                    ),
                    _buildRowTitleValue(
                      title: "Max Carry Forward",
                      value: leaveType.maxCarryForward.toString(),
                    ),
                    _buildRowTitleValue(
                      title: "Encashable",
                      value: leaveType.isEncashable == true ? "Yes" : "No",
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // BUILD ROW TITLE VALUE
  Widget _buildRowTitleValue({required String title, required String value}) {
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
