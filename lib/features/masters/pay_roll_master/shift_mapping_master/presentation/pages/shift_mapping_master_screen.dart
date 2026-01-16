import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/cubit/shift_master_mapping_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/cubit/shift_master_mapping_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ShiftMappingMasterScreen extends StatefulWidget {
  const ShiftMappingMasterScreen({super.key});

  @override
  State<ShiftMappingMasterScreen> createState() =>
      _ShiftMappingMasterScreenState();
}

class _ShiftMappingMasterScreenState extends State<ShiftMappingMasterScreen> {
  //CUBIT
  late ShiftMappingMasterCubit _shiftMappingMasterCubit;

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
    _shiftMappingMasterCubit = context.read<ShiftMappingMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.shiftMappingMaster] ??
        AuthorizationModel();
    _onScroll();
    _initializeTextEditingController();
    _shiftMappingMasterCubit.getShiftMappingList(
      context: context,
      pageNumber: 1,
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
          !(_shiftMappingMasterCubit.state.isLoading ?? false) &&
          _shiftMappingMasterCubit.state.shiftMappingList.length <
              _shiftMappingMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _shiftMappingMasterCubit.getShiftMappingList(
            context: context,
            pageNumber: _shiftMappingMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteShiftMappingMaster(
    BuildContext context,
    ShiftMappingModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Shift?',
      'Deleting this Shift will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _shiftMappingMasterCubit.deleteShiftMapping(index, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Shift Mapping Master",
        authorization: _routeAuthorizationModel,
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addShiftMappingMaster);
        },
        textController: _searchC,
        onExportCallback: (value) {
          _shiftMappingMasterCubit.exportExcelPdf(context, value);
        },
        onSearchSubmit: (value) {
          _shiftMappingMasterCubit.searchShiftMapping(value, context);
        },
      ),
      body: BlocBuilder<ShiftMappingMasterCubit, ShiftMappingMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.shiftMappingList.isEmpty) {
            return Center(child: loader());
          }
          if (state.shiftMappingList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.shiftMappingList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.shiftMappingList.length) {
                return state.shiftMappingList.length < state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var shiftMappingMaster = state.shiftMappingList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              goRouter.pushNamed(
                                AppRoutes.viewShiftMappingMaster,
                                queryParameters: {
                                  "shiftMapping": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(shiftMappingMaster.toJson()),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColor.primary),
                                ),
                              ),
                              child: Text(
                                shiftMappingMaster.shiftName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addShiftMappingMaster,
                                  queryParameters: {
                                    "shiftMapping": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(shiftMappingMaster.toJson()),
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
                                _showPopupToDeleteShiftMappingMaster(
                                  context,
                                  shiftMappingMaster,
                                  state.currentPage,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 10),

                    _buildRowTitleValue(
                      title: "Deparment Code",
                      value: shiftMappingMaster.departmentName,
                    ),
                    _buildRowTitleValue(
                      title: "Employee Name",
                      value: shiftMappingMaster.employeeName,
                    ),
                    _buildRowTitleValue(
                      title: "Shift Code",
                      value: shiftMappingMaster.shiftCode,
                    ),
                    _buildRowTitleValue(
                      title: "Start Time",
                      value: shiftMappingMaster.shiftBeginTime,
                    ),

                    _buildRowTitleValue(
                      title: "End Time",
                      value: shiftMappingMaster.shiftEndTime,
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
