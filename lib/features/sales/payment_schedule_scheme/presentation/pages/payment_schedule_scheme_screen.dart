import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/presentation/cubit/payment_schedule_scheme_cubit.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/presentation/cubit/payment_schedule_scheme_state.dart';
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

class PaymentScheduleSchemeScreen extends StatefulWidget {
  const PaymentScheduleSchemeScreen({super.key});

  @override
  State<PaymentScheduleSchemeScreen> createState() =>
      _PaymentScheduleSchemeScreenState();
}

class _PaymentScheduleSchemeScreenState
    extends State<PaymentScheduleSchemeScreen> {
  // CUBIT
  late PaymentScheduleSchemeCubit _cubit;

  // AUTHORIZATION MODEL
  late AuthorizationModel _routeAuthorizationModel;

  // SCROLL CONTROLLER
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLER
  late TextEditingController _searchC;

  // PROJECT
  late ProjectModel _project;

  @override
  void initState() {
    super.initState();

    _cubit = context.read<PaymentScheduleSchemeCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.paymentScheduleScheme]!;
    _searchC = TextEditingController();
    _project = getProject();
    _onScroll();
    _cubit.getPaymentScheduleSchemeList(context, 1, _project.projectId);
  }

  @override
  void dispose() {
    _searchC.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_cubit.state.isLoading! &&
          _cubit.state.paymentScheduleSchemeList.length <
              _cubit.state.totalNumberOfRecord) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();

        _debounce = Timer(const Duration(milliseconds: 300), () {
          _cubit.getPaymentScheduleSchemeList(
            context,
            _cubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  // DELETE
  Future<void> _showPaymentScheduleSchemeDeletePopup(
    BuildContext context,
    PaymentScheduleSchemeModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Payment Schedule Scheme ?',
      'Deleting this Payment Schedule Scheme will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _cubit.deletePaymentScheduleScheme(index, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBar(
        screenTitle: 'Payment Schedule Scheme',
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        onProjectChangeCallback: (value) {
          _project = value;
          _searchC.clear();
          _cubit.searchPaymentScheduleScheme(context, "", _project.projectId);
        },
        onExportCallback: (value) {
          if (_project.projectId == 0) {
            showErrorMessage(context, "Error", "Please select a project");
            return;
          }
          if (_cubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _cubit.exportExcelPdf(context, value);
        },
        onAddCallback: () async {
          if (_project.projectId == 0) {
            showErrorMessage(context, "Error", "Please select a project");
            return;
          }
          await goRouter.pushNamed(AppRoutes.addPaymentScheduleScheme);
        },
        searchHintText: "Search by Scheme Name",
        onSearchSubmit: (value) {
          _cubit.searchPaymentScheduleScheme(
            context,
            value,
            _project.projectId,
          );
        },
      ),
      body: BlocBuilder<PaymentScheduleSchemeCubit, PaymentScheduleSchemeState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) &&
              state.paymentScheduleSchemeList.isEmpty) {
            return Center(child: loader());
          }

          if (state.paymentScheduleSchemeList.isEmpty) {
            return Center(child: noDataWidget());
          }

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.paymentScheduleSchemeList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.paymentScheduleSchemeList.length) {
                return state.paymentScheduleSchemeList.length <
                        state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }

              var scheme = state.paymentScheduleSchemeList[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scheme.paymentScheduleSchemeName,
                            style: AppTextStyle.ts16M(color: AppColor.primary),
                          ),
                        ),
                        if (_routeAuthorizationModel.isAction) ...[
                          Row(
                            children: [
                              CustomIconButton.edit(
                                onPressed: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.addPaymentScheduleScheme,
                                    queryParameters: {
                                      'scheme': Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(scheme.toJson()),
                                        ),
                                      ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                              horizontalSpacing(),
                              CustomIconButton.delete(
                                isDisabled:
                                    scheme.isExistsPaymentScheduleScheme,
                                onPressed: () async {
                                  _showPaymentScheduleSchemeDeletePopup(
                                    context,
                                    scheme,
                                    index,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    verticalSpacing(),
                    buildRowTitleValue(
                      title: "Building",
                      value: scheme.buildingNumber,
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "Wing",
                      value: scheme.wing,
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "Created By",
                      value: scheme.createdBy,
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "Created Date",
                      value:
                          scheme.createdDate == null
                              ? "-"
                              : formatDate(scheme.createdDate!),
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "Modified By",
                      value:
                          scheme.modifiedBy.isEmpty ? "-" : scheme.modifiedBy,
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "Modified Date",
                      value:
                          scheme.modifiedDate == null
                              ? "-"
                              : formatDate(scheme.modifiedDate!),
                      singleLine: false,
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
