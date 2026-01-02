import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/model/holiday_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/cubit/holiday_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class HolidayMasterScreen extends StatefulWidget {
  const HolidayMasterScreen({super.key});

  @override
  State<HolidayMasterScreen> createState() => _HolidayMasterScreenState();
}

class _HolidayMasterScreenState extends State<HolidayMasterScreen> {
  // CUBIT
  late HolidayMasterCubit holidayMasterCubit;

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
    holidayMasterCubit = context.read<HolidayMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.holidayMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    holidayMasterCubit.getHolidayList(
      context: context,
      pageNumber: 1,
      pageSize: 15,
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _searchC.dispose();
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
          !(holidayMasterCubit.state.isLoading ?? false) &&
          holidayMasterCubit.state.holidays.length <
              holidayMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          holidayMasterCubit.getHolidayList(
            context: context,
            pageNumber: holidayMasterCubit.state.currentPage + 1,
            pageSize: 15,
          );
        });
      }
    });
  }

  // <---- DELETE HOLIDAY ---->
  Future<void> _showPopupToDeleteHolidayMaster(
    BuildContext context,
    HolidayMasterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Holiday?',
      'Deleting this Holiday will permanently remove its contents.',
    );
    if (result && context.mounted) {
      holidayMasterCubit.deleteHoliday(currentPage, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Holidays",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          holidayMasterCubit.searchHolidays(value, context);
        },
        textController: _searchC,
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addHolidayMaster);
        },
        onExportCallback: (value) {},
      ),
      body: BlocBuilder<HolidayMasterCubit, HolidayMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.holidays.isEmpty) {
            return Center(child: loader());
          }
          if (state.holidays.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.holidays.length + 1,
            itemBuilder: (context, index) {
              if (index == state.holidays.length) {
                return state.holidays.length < state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var holiday = state.holidays[index];
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
                              holiday.holidayName,
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addHolidayMaster,
                                  queryParameters: {
                                    "holiday": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(holiday.toJson()),
                                      ),
                                    ),
                                    'index': index.toString(),
                                  },
                                );
                                if (context.mounted) {
                                  holidayMasterCubit.getHolidayList(
                                    context: context,
                                    pageNumber: state.currentPage,
                                    pageSize: 15,
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeleteHolidayMaster(
                                  context,
                                  holiday,
                                  state.currentPage,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
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
