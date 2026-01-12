import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class WeekOffMappingMasterScreen extends StatefulWidget {
  const WeekOffMappingMasterScreen({super.key});

  @override
  State<WeekOffMappingMasterScreen> createState() =>
      _WeekOffMappingMasterScreenState();
}

class _WeekOffMappingMasterScreenState
    extends State<WeekOffMappingMasterScreen> {
  //CUBIT
  late WeekOffMappingMasterCubit _weekOffMappingMasterCubit;

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
    _weekOffMappingMasterCubit = context.read<WeekOffMappingMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.weekOffMappingMaster] ??
        AuthorizationModel();
    _onScroll();
    _initializeTextEditingController();
    _weekOffMappingMasterCubit.getWeekOffMappingList(
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
          !(_weekOffMappingMasterCubit.state.isLoading ?? false) &&
          _weekOffMappingMasterCubit.state.weekOffMappingList.length <
              _weekOffMappingMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _weekOffMappingMasterCubit.getWeekOffMappingList(
            context: context,
            pageNumber: _weekOffMappingMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteWeekOffMappingMaster(
    BuildContext context,
    WeekOffMappingModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a week off?',
      'Deleting this week off will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _weekOffMappingMasterCubit.deleteWeekOffMapping(
        currentPage,
        obj,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Week Off Mapping Master",
        authorization: _routeAuthorizationModel,
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addWeekOffMappingMaster);
        },
        textController: _searchC,
        onExportCallback: (value) {
          _weekOffMappingMasterCubit.exportExcelPdf(context, value);
        },
        onSearchSubmit: (value) {
          _weekOffMappingMasterCubit.searchWeekOffMapping(value, context);
        },
      ),
      body: BlocBuilder<WeekOffMappingMasterCubit, WeekOffMappingMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.weekOffMappingList.isEmpty) {
            return Center(child: loader());
          }
          if (state.weekOffMappingList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.weekOffMappingList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.weekOffMappingList.length) {
                return state.weekOffMappingList.length <
                        state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var weekOffMappingMaster = state.weekOffMappingList[index];
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
                                AppRoutes.viewWeekOffMappingMaster,
                                queryParameters: {
                                  "weekOffMapping": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(weekOffMappingMaster.toJson()),
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
                                weekOffMappingMaster.weekOffPolicyName,
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
                                  AppRoutes.addWeekOffMappingMaster,
                                  queryParameters: {
                                    "weekOffMapping": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(
                                          weekOffMappingMaster.toJson(),
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
                                _showPopupToDeleteWeekOffMappingMaster(
                                  context,
                                  weekOffMappingMaster,
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
                      value: weekOffMappingMaster.departmentName,
                    ),
                    _buildRowTitleValue(
                      title: "Employee Name",
                      value: weekOffMappingMaster.employeeName,
                    ),
                    _buildRowTitleValue(
                      title: "Week Off",
                      value: weekOffMappingMaster.weekOffPolicyCode,
                    ),
                    _buildRowTitleValue(
                      title: "Week Off 2",
                      value: weekOffMappingMaster.weeklyOff2,
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
