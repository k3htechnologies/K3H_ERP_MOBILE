import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/model/holiday_mapping_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/cubit/holiday_mapping_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class HolidayMappingMasterScreen extends StatefulWidget {
  const HolidayMappingMasterScreen({super.key});

  @override
  State<HolidayMappingMasterScreen> createState() =>
      _HolidayMappingMasterScreenState();
}

class _HolidayMappingMasterScreenState
    extends State<HolidayMappingMasterScreen> {
  // CUBIT
  late HolidayMappingMasterCubit _holidayMappingMasterCubit;

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
    _holidayMappingMasterCubit = context.read<HolidayMappingMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.holidayMappingMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _holidayMappingMasterCubit.getHolidayMappingList(
      context: context,
      pageNumber: 1,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    super.dispose();
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
          !(_holidayMappingMasterCubit.state.isLoading ?? false) &&
          _holidayMappingMasterCubit.state.holidayMappingList.length <
              _holidayMappingMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _holidayMappingMasterCubit.getHolidayMappingList(
            context: context,
            pageNumber: _holidayMappingMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE HOLIDAY MAPPING  ---->
  Future<void> _showPopupToDeleteHolidayMappingMaster(
    BuildContext context,
    HolidayMappingModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Holiday Mapping?',
      'Deleting this Holiday Mapping will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _holidayMappingMasterCubit.deleteHolidayMapping(index, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Holiday Mapping",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _holidayMappingMasterCubit.searchHolidayMapping(value, context);
        },
        textController: _searchC,
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addHolidayMappingMaster);
          if (context.mounted) {
            _holidayMappingMasterCubit.getHolidayMappingList(
              context: context,
              pageNumber: 1,
            );
          }
        },
        onExportCallback: (value) {
          _holidayMappingMasterCubit.exportExcelPdf(context, value);
        },
      ),
      body: BlocBuilder<HolidayMappingMasterCubit, HolidayMappingMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.holidayMappingList.isEmpty) {
            return Center(child: loader());
          }
          if (state.holidayMappingList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.holidayMappingList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.holidayMappingList.length) {
                return state.holidayMappingList.length <
                        state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var holidayMapping = state.holidayMappingList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              await goRouter.pushNamed(
                                AppRoutes.viewHolidayMappingMaster,
                                queryParameters: {
                                  "holidayMapping": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(holidayMapping.toJson()),
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
                                holidayMapping.holidayName,
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
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addHolidayMappingMaster,
                                  queryParameters: {
                                    "holidayMapping": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(holidayMapping.toJson()),
                                      ),
                                    ),
                                    'index': index.toString(),
                                  },
                                );
                              },
                            ),
                            horizontalSpacing(),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeleteHolidayMappingMaster(
                                  context,
                                  holidayMapping,
                                  state.currentPage,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 8),
                    buildRowTitleValue(
                      title: "Branch",
                      value: holidayMapping.branchName,
                    ),
                    verticalSpacing(height: 8),
                    buildRowTitleValue(
                      title: "Holiday Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        holidayMapping.holidayDate,
                      ),
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
}
