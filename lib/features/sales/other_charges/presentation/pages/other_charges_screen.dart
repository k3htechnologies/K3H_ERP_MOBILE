import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/other_charges/presentation/cubit/other_charges_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class OtherChargesScreen extends StatefulWidget {
  const OtherChargesScreen({super.key});

  @override
  State<OtherChargesScreen> createState() => _OtherChargesScreenState();
}

class _OtherChargesScreenState extends State<OtherChargesScreen> {
  // CUBIT
  late OtherChargesCubit _otherChargesCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // PROJECT
  late ProjectModel _project;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
    _otherChargesCubit = context.read<OtherChargesCubit>();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.otherCharges]!;
    _onScroll();
    _otherChargesCubit.getOtherChargesList(context, 1, _project.projectId);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_otherChargesCubit.state.isLoading! &&
          _otherChargesCubit.state.otherChargesList.length <
              _otherChargesCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _otherChargesCubit.getOtherChargesList(
            context,
            _otherChargesCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  // <---- DELETE DEPARTMENT ---->
  Future<void> _showPopupToDeleteOtherCharges(
    BuildContext context,
    int projectId,
    int otherChargesId,
    String uniqueKey,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Other Charges ?',
      'Deleting this Other Charges will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _otherChargesCubit.deleteOtherCharges(
        context: context,
        projectId: projectId,
        otherChargesId: otherChargesId,
        uniqueKey: uniqueKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Other Charges",
        searchHintText: "Search by Charges",
        authorization: _routeAuthorizationModel,
        onAddCallback: () async {
          if(_project.projectId==0){
            showErrorMessage(context, 'Error', "Please select a project");
            return;
          }
          await goRouter.pushNamed(
            AppRoutes.addOtherCharges,
            queryParameters: {'projectId': _project.projectId.toString()},
          );
          if (context.mounted) {
            _otherChargesCubit.getOtherChargesList(
              context,
              _otherChargesCubit.state.currentPage,
              _project.projectId,
            );
          }
        },
        onExportCallback: (value) {
          if(_project.projectId==0){
            showErrorMessage(context, 'Error', "Please select a project");
            return;
          }
          if (_otherChargesCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, 'Error', "No Data Found");
            return;
          }
          _otherChargesCubit.exportExcelPdf(context, value, _project.projectId);
        },
        textController: _searchC,
        onSearchSubmit: (value) {
          _otherChargesCubit.searchOtherCharges(
            context,
            value,
            _project.projectId,
          );
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _otherChargesCubit.searchOtherCharges(context, "", value.projectId);
        },
      ),
      body: BlocBuilder<OtherChargesCubit, OtherChargesState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.otherChargesList.isEmpty) {
            return Center(child: loader());
          }
          if (state.otherChargesList.isEmpty) {
            return Center(
              child: noDataWidget(message: "No Other Charges Data found"),
            );
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _otherChargesCubit.state.otherChargesList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.otherChargesList.length) {
                return state.otherChargesList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var otherCharges = state.otherChargesList[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            otherCharges.chargeName,
                            style: AppTextStyle.ts14SB(
                              color: AppColor.primary,
                            )
                          ),
                        ),
                        horizontalSpacing(),
                        if(_routeAuthorizationModel.isAction)
                        Row(
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addOtherCharges,
                                  queryParameters: {
                                    'otherCharges': Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(otherCharges.toJson()),
                                      ),
                                    ),
                                    'index': index.toString(),
                                    'projectId': _project.projectId.toString(),
                                  },
                                );
                              },
                            ),
                            horizontalSpacing(),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeleteOtherCharges(
                                  context,
                                  _project.projectId,
                                  otherCharges.otherChargesId,
                                  otherCharges.uniquekey,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    buildRowTitleValue(
                      title: "Value",
                      value: "₹ ${otherCharges.value.displayFormatedAmount()}",
                      fixesWidth: 180
                    ),
                    buildRowTitleValue(
                      title: "Calculated On",
                      value: otherCharges.calculatedOn,
                        fixesWidth: 180
                    ),
                    buildRowTitleValue(
                      title: "GST Percentage",
                      value: "${otherCharges.gstPercentage} %",
                        fixesWidth: 180
                    ),
                    buildRowTitleValue(
                      title: "GST Value",
                      value: "₹ ${otherCharges.gstValue.displayFormatedAmount()}",
                        fixesWidth: 180
                    ),
                    buildRowTitleValue(
                      title: "Value + GST Value (₹)",
                      value: "₹ ${(otherCharges.value + otherCharges.gstValue).displayFormatedAmount()}",
                        fixesWidth: 180
                    ),
                    buildRowTitleValue(
                      title: "Created By",
                      value: otherCharges.createdBy,
                        fixesWidth: 180,
                        singleLine: false
                    ),
                    buildRowTitleValue(
                      title: "Created Date",
                      value: formatDate(otherCharges.createdDate),
                        fixesWidth: 180,
                        singleLine: false
                    ),
                    buildRowTitleValue(
                        title: "Modified By",
                        value: otherCharges.modifiedBy.isNotEmpty?otherCharges.modifiedBy:"-",
                        fixesWidth: 180,
                      singleLine: false
                    ),
                    buildRowTitleValue(
                        title: "Modified Date",
                        value: otherCharges.modifiedDate!=null? formatDate(otherCharges.modifiedDate):"-",
                        fixesWidth: 180,
                        singleLine: false
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
