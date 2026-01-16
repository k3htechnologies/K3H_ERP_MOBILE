import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/cubit/week_off_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/cubit/week_off_master_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class WeekOffMasterScreen extends StatefulWidget {
  const WeekOffMasterScreen({super.key});

  @override
  State<WeekOffMasterScreen> createState() => _WeekOffMasterScreenState();
}

class _WeekOffMasterScreenState extends State<WeekOffMasterScreen> {
  //CUBIT
  late WeekOffMasterCubit _weekOffMasterCubit;

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
    _weekOffMasterCubit = context.read<WeekOffMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.weekOffMaster] ??
        AuthorizationModel();
    _onScroll();
    _initializeTextEditingController();
    _weekOffMasterCubit.getWeekOffList(context: context, pageNumber: 1);
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
          !(_weekOffMasterCubit.state.isLoading ?? false) &&
          _weekOffMasterCubit.state.weekOffMasterList.length <
              _weekOffMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _weekOffMasterCubit.getWeekOffList(
            context: context,
            pageNumber: _weekOffMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteWeekOffMaster(
    BuildContext context,
    WeekOffMasterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Week Off?',
      'Deleting this Week Off will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _weekOffMasterCubit.deleteWeekOff(index, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "WeekOff Master",
        authorization: _routeAuthorizationModel,
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addWeekOffMaster);
        },
        textController: _searchC,
        onExportCallback: (value) {
          _weekOffMasterCubit.exportExcelPdf(context, value);
        },
        onSearchSubmit: (value) {
          _weekOffMasterCubit.searchWeekOff(value, context);
        },
      ),
      body: BlocBuilder<WeekOffMasterCubit, WeekOffMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.weekOffMasterList.isEmpty) {
            return Center(child: loader());
          }
          if (state.weekOffMasterList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.weekOffMasterList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.weekOffMasterList.length) {
                return state.weekOffMasterList.length <
                        state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var weekOffMaster = state.weekOffMasterList[index];
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
                                AppRoutes.viewWeekOffMaster,
                                queryParameters: {
                                  "weekOff": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(weekOffMaster.toJson()),
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
                                weekOffMaster.weekOffPolicyName,
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
                                  AppRoutes.addWeekOffMaster,
                                  queryParameters: {
                                    "weekOff": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(weekOffMaster.toJson()),
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
                                _showPopupToDeleteWeekOffMaster(
                                  context,
                                  weekOffMaster,
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
                      title: "Week Off Code",
                      value: weekOffMaster.weekOffPolicyCode,
                    ),
                    _buildRowTitleValue(
                      title: "Week Days",
                      value: weekOffMaster.weekDays.toString(),
                    ),
                    _buildRowTitleValue(
                      title: "Week Days Starts On",
                      value: weekOffMaster.weekDaysStartsOn,
                    ),
                    _buildRowTitleValue(
                      title: "Weekly Off",
                      value: weekOffMaster.weeklyOff,
                    ),
                    _buildRowTitleValue(
                      title: "Weekly Off2",
                      value:
                          weekOffMaster.weeklyOff2.isEmpty
                              ? "N/A"
                              : weekOffMaster.weeklyOff2,
                    ),
                    _buildRowTitleValue(
                      title: "Weekly Off2 Type",
                      value:
                          weekOffMaster.weeklyOff2Type.isEmpty
                              ? "N/A"
                              : weekOffMaster.weeklyOff2Type,
                    ),
                    _buildRowTitleValue(
                      title: "Not Applicable For Months",
                      value: weekOffMaster.notApplicableForMonths,
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
