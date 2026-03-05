import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
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
  late PaymentScheduleSchemeCubit _cubit;
  late AuthorizationModel _routeAuthorizationModel;

  late ScrollController scrollController;
  Timer? _debounce;

  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();

    _cubit = context.read<PaymentScheduleSchemeCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.paymentScheduleScheme]!;

    _searchC = TextEditingController();

    _onScroll();
    _cubit.getPaymentScheduleSchemeList(context, 1);
  }

  @override
  void dispose() {
    _searchC.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // PAGINATION
  // ----------------------------------------------------------

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
          );
        });
      }
    });
  }

  // ----------------------------------------------------------
  // DELETE
  // ----------------------------------------------------------

  Future<void> _showPaymentScheduleSchemeDeletePopup(
    BuildContext context,
    PaymentScheduleSchemeModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete this scheme?',
      'Deleting this scheme will permanently remove it.',
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
        onProjectChangeCallback: (value) {
          _cubit.getPaymentScheduleSchemeList(context, 1);
        },
        onExportCallback: (value) {
          if (_cubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _cubit.exportExcelPdf(context, value);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addPaymentScheduleScheme);
        },
        searchHintText: "Search by Scheme Name",
        onSearchSubmit: (value) {
          _cubit.searchPaymentScheduleScheme(context, value);
        },
        textController: _searchC,
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
                            style: AppTextStyle.ts16M(),
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
