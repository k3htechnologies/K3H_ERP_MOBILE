import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/model/earning_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/cubit/earning_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class EarningMasterScreen extends StatefulWidget {
  const EarningMasterScreen({super.key});

  @override
  State<EarningMasterScreen> createState() => _EarningMasterScreenState();
}

class _EarningMasterScreenState extends State<EarningMasterScreen> {
  // CUBIT
  late EarningMasterCubit _earningMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeTextEditingController();
    _earningMasterCubit = context.read<EarningMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.earningMaster] ??
        AuthorizationModel();
    _onScroll();
    _earningMasterCubit.getEarningList(
      context: context,
      pageNumber: 1,
    );
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
          !(_earningMasterCubit.state.isLoading ?? false) &&
          _earningMasterCubit.state.earningList.length <
              _earningMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _earningMasterCubit.getEarningList(
            context: context,
            pageNumber: _earningMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE EARNING ---->
  Future<void> _showPopupToDeleteEarningMaster(
    BuildContext context,
    EarningMasterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Asset Mapping?',
      'Deleting this Asset Mapping will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _earningMasterCubit.deleteEarning(currentPage, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Earning",
        authorization: _routeAuthorizationModel,
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addEarningMaster);
        },
        onSearchSubmit: (value) {
          _earningMasterCubit.searchEarning(value, context);
        },
        textController: _searchC,
        onExportCallback: (value) {
          _earningMasterCubit.exportExcelPdf(context, value);
        },
      ),
      body: BlocBuilder<EarningMasterCubit, EarningMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.earningList.isEmpty) {
            return Center(child: loader());
          }
          if (state.earningList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.earningList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.earningList.length) {
                return state.earningList.length < state.totalNumberOfRecord
                    ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
                    : const SizedBox.shrink();
              }
              var earning = state.earningList[index];
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
                              earning.name,
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
                                  AppRoutes.addEarningMaster,
                                  queryParameters: {
                                    "earning": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(earning.toJson()),
                                      ),
                                    ),
                                    'index': index.toString(),
                                  },
                                );
                                if (context.mounted) {
                                  _earningMasterCubit.getEarningList(
                                    context: context,
                                    pageNumber: state.currentPage,
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeleteEarningMaster(
                                  context,
                                  earning,
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
                    _buildRowTitleValue(title: "Type", value: earning.type),
                    _buildRowTitleValue(
                      title: "Value",
                      value: "₹ ${earning.value}",
                    ),
                    _buildRowTitleValue(
                      title: "Branch Name",
                      value: earning.branchName,
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
