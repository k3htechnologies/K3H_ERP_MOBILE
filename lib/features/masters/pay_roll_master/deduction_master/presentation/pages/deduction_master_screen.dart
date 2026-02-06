import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/model/deduction_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/cubit/deduction_master_cubit.dart';
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

class DeductionMasterScreen extends StatefulWidget {
  const DeductionMasterScreen({super.key});

  @override
  State<DeductionMasterScreen> createState() => _DeductionMasterScreenState();
}

class _DeductionMasterScreenState extends State<DeductionMasterScreen> {
  // CUBIT
  late DeductionMasterCubit _deductionMasterCubit;

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
    _deductionMasterCubit = context.read<DeductionMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.deductionMaster] ??
        AuthorizationModel();
    _initializeTextEditingController();
    _onScroll();
    _deductionMasterCubit.getDeductionList(context: context, pageNumber: 1);
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
          !(_deductionMasterCubit.state.isLoading ?? false) &&
          _deductionMasterCubit.state.deductionList.length <
              _deductionMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _deductionMasterCubit.getDeductionList(
            context: context,
            pageNumber: _deductionMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE ASSET MAPPING ---->
  Future<void> _showPopupToDeleteAssetMappingMaster(
    BuildContext context,
    DeductionMasterModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Asset Mapping?',
      'Deleting this Asset Mapping will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _deductionMasterCubit.deleteDeduction(index, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Deduction",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _deductionMasterCubit.searchAssetMapping(value, context);
        },
        textController: _searchC,
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addDeductionMaster);
          if (context.mounted) {
            _deductionMasterCubit.getDeductionList(
              context: context,
              pageNumber: 1,
            );
          }
        },
        onExportCallback: (value) {
          if(_deductionMasterCubit.state.totalNumberOfRecord==0){
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _deductionMasterCubit.exportExcelPdf(context, value);
        },
      ),
      body: BlocBuilder<DeductionMasterCubit, DeductionMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.deductionList.isEmpty) {
            return Center(child: loader());
          }
          if (state.deductionList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.deductionList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.deductionList.length) {
                return state.deductionList.length < state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var deduction = state.deductionList[index];
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
                                AppRoutes.viewDeductionMaster,
                                queryParameters: {
                                  "deduction": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(deduction.toJson()),
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
                                deduction.name,
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
                                  AppRoutes.addDeductionMaster,
                                  queryParameters: {
                                    "deduction": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(deduction.toJson()),
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
                                _showPopupToDeleteAssetMappingMaster(
                                  context,
                                  deduction,
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
                      title: "Deduction Type",
                      value: deduction.type,
                    ),
                    buildRowTitleValue(
                      title: "Deduction Value",
                      value: "₹ ${deduction.value}",
                    ),
                    buildRowTitleValue(
                      title: "Branch Name",
                      value: deduction.branchName,
                    ),
                    buildRowTitleValue(
                      title: "Min Salary",
                      value: "₹ ${deduction.minSalary}",
                    ),
                    buildRowTitleValue(
                      title: "Max Salary",
                      value: "₹ ${deduction.maxSalary}",
                    ),
                    buildRowTitleValue(
                      title: "Gender",
                      value: deduction.gender,
                      customValueWidget: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          deduction.gender,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.ts14R(color: AppColor.primary),
                        ),
                      ),
                    ),
                    buildRowTitleValue(
                      title: "State Name",
                      value: deduction.stateName,
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
