import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule/data/model/payment_schedule.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule/presentation/cubit/payment_schedule_cubit.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule/presentation/cubit/payment_schedule_state.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/repository/payment_schedule_scheme.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PaymentScheduleScreen extends StatefulWidget {
  const PaymentScheduleScreen({super.key});

  @override
  State<PaymentScheduleScreen> createState() => _PaymentScheduleScreenState();
}

class _PaymentScheduleScreenState extends State<PaymentScheduleScreen> {
  /// CUBIT
  late PaymentScheduleCubit _paymentScheduleCubit;
  // ROUTE AUTHORIZATION MODEL
  late AuthorizationModel _routeAuthorizationModel;

  // SCROLL CONTROLLER FOR PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // REPOSITORY
  final PaymentScheduleSchemeRepository _paymentScheduleSchemeRepository =
      serviceLocator<PaymentScheduleSchemeRepository>();

  // SELECTED SCHEME
  final ValueNotifier<PaymentScheduleSchemeModel?> selectedSchemeNotifier =
      ValueNotifier(null);
  // PROJECT
  late ProjectModel _project;

  @override
  void initState() {
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.paymentSchedule]!;
    _paymentScheduleCubit = context.read<PaymentScheduleCubit>();
    super.initState();
    _onScroll();
    _project = getProject();
    if (_project.projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      _paymentScheduleCubit.reset();
    }
  }

  // ---------------- FETCH SCHEME ----------------
  Future<Map<String, dynamic>> _fetchPaymentScheduleScheme(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _paymentScheduleSchemeRepository
        .getPaymentScheduleSchemeList(
          pageNumber: pageNumber,
          pageSize: 15,
          projectId: getProject().projectId,
          queryParams:
              value != null && value.isNotEmpty
                  ? {"PaymentScheduleScheme": value}
                  : {},
        );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final paymentScheduleSchemes =
            response['data'] as List<PaymentScheduleSchemeModel>;

        return {
          "itemList":
              paymentScheduleSchemes.map((scheme) {
                return {
                  "zAttributesId": scheme.paymentScheduleSchemeMasterId,
                  "DisplayName": scheme.paymentScheduleSchemeName,
                  "paymentScheduleScheme": scheme,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // ---------------- DELETE PAYMENT SCHEDULE ----------------
  Future<void> _showPopupToDeletePaymentScheduleMaster(
    BuildContext context,
    PaymentScheduleMasterModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Payment Schedule ?',
      'Deleting this Payment Schedule will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _paymentScheduleCubit.deletePaymentSchedule(index, obj, context);
    }
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (_paymentScheduleCubit.state.selectedScheme == null) return;
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_paymentScheduleCubit.state.isLoading! &&
          _paymentScheduleCubit.state.paymentScheduleMasterList.length <
              _paymentScheduleCubit.state.totalNumberOfRecord) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();

        _debounce = Timer(const Duration(milliseconds: 300), () {
          _paymentScheduleCubit.getPaymentScheduleMasterList(
            context,
            _paymentScheduleCubit.state.currentPage + 1,
            scheme: _paymentScheduleCubit.state.selectedScheme!,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        isMenuButton: true,
        screenTitle: 'Payment Schedule',
        authorization: _routeAuthorizationModel,
        onProjectChangeCallback: (value) {
          _paymentScheduleCubit.clearSelectedScheme();
          selectedSchemeNotifier.value = null;
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: BlocBuilder<PaymentScheduleCubit, PaymentScheduleMasterState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomMultipleSelectPopup(
                  key: ValueKey(
                    state.selectedScheme?.paymentScheduleSchemeMasterId ?? 0,
                  ),
                  title: "Payment Schedule Scheme",
                  hintText: "Select Payment Schedule Scheme",
                  isRequired: true,
                  isMultiSelect: false,
                  initialValue:
                      state.selectedScheme == null
                          ? []
                          : [
                            {
                              "zAttributesId":
                                  state
                                      .selectedScheme!
                                      .paymentScheduleSchemeMasterId,
                              "DisplayName":
                                  state
                                      .selectedScheme!
                                      .paymentScheduleSchemeName,
                              "paymentScheduleScheme": state.selectedScheme,
                            },
                          ],
                  dataFetchCallBack: _fetchPaymentScheduleScheme,
                  onSelected: (value) async {
                    if (value.isNotEmpty) {
                      final schemeModel =
                          value.first["paymentScheduleScheme"]
                              as PaymentScheduleSchemeModel;

                      _paymentScheduleCubit.selectScheme(schemeModel);

                      selectedSchemeNotifier.value = schemeModel;

                      await _paymentScheduleCubit.getPaymentScheduleMasterList(
                        context,
                        1,
                        scheme: schemeModel,
                      );
                    }
                  },
                  onClear: () {
                    selectedSchemeNotifier.value = null;
                    _paymentScheduleCubit.clearSelectedScheme();
                  },
                ),
                ValueListenableBuilder<PaymentScheduleSchemeModel?>(
                  valueListenable: selectedSchemeNotifier,
                  builder: (context, scheme, _) {
                    if (scheme == null) return SizedBox();

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColor.primary, width: .5),
                        color: AppColor.lightBlue,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Building",
                                value:
                                    selectedSchemeNotifier
                                        .value!
                                        .buildingNumber,
                              ),
                              buildColumnTitleValue(
                                title: "Wing",
                                value: selectedSchemeNotifier.value!.wing,
                              ),
                            ],
                          ),
                          verticalSpacing(height: 5),
                          Row(
                            children: [
                              buildColumnTitleValue(
                                title: "Total",
                                value: "${state.totalCumulativePercentage}%",
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                verticalSpacing(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Payment Schedule List", style: AppTextStyle.ts16M()),
                    Visibility(
                      visible:
                          state.selectedScheme != null &&
                          state.totalCumulativePercentage < 100,
                      child: CustomIconButton(
                        onPressed: () async {
                          await goRouter.pushNamed(
                            AppRoutes.addPaymentSchedule,
                          );
                        },
                        icon: Icon(
                          Icons.add,
                          size: 16,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),

                Expanded(
                  child:
                      state.isLoading == true
                          ? const Center(child: CircularProgressIndicator())
                          : state.paymentScheduleMasterList.isEmpty
                          ? Center(
                            child: noDataWidget(
                              message: "No Payment Schedule Data Found",
                            ),
                          )
                          : ListView.builder(
                            controller: scrollController,
                            itemCount:
                                state.paymentScheduleMasterList.length + 1,
                            itemBuilder: (context, index) {
                              if (index ==
                                  state.paymentScheduleMasterList.length) {
                                return state.paymentScheduleMasterList.length <
                                        state.totalNumberOfRecord
                                    ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                    : const SizedBox.shrink();
                              }

                              var item = state.paymentScheduleMasterList[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: commonCardDecoration(),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.stage,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyle.ts16M(
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                        if (_routeAuthorizationModel
                                            .isAction) ...[
                                          Row(
                                            children: [
                                              CustomIconButton.edit(
                                                onPressed: () async {
                                                  await goRouter.pushNamed(
                                                    AppRoutes
                                                        .addPaymentSchedule,
                                                    queryParameters: {
                                                      "paymentSchedule":
                                                          Uri.encodeQueryComponent(
                                                            EncryptionManager.encryptData(
                                                              jsonEncode(
                                                                item.toJson(),
                                                              ),
                                                            ),
                                                          ),
                                                      "index": index.toString(),
                                                    },
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              CustomIconButton.delete(
                                                onPressed: () {
                                                  _showPopupToDeletePaymentScheduleMaster(
                                                    context,
                                                    item,
                                                    index,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                    buildRowTitleValue(
                                      title: "Percentage",
                                      value:
                                          item.paymentSchedulePercentage
                                              .toString(),
                                    ),
                                    buildRowTitleValue(
                                      title: "Cumulative Percentage",
                                      value:
                                          item.paymentCummulativePercentage
                                              .toString(),
                                    ),
                                    buildRowTitleValue(
                                      title: "Created By",
                                      value: item.createdBy,
                                      singleLine: false,
                                    ),
                                    buildRowTitleValue(
                                      title: "Created Date",
                                      value:
                                          item.createdDate == null
                                              ? "-"
                                              : formatDate(item.createdDate!),
                                      singleLine: false,
                                    ),
                                    buildRowTitleValue(
                                      title: "Modified By",
                                      value:
                                          item.modifiedBy.isEmpty
                                              ? "-"
                                              : item.modifiedBy,
                                      singleLine: false,
                                    ),
                                    buildRowTitleValue(
                                      title: "Modified Date",
                                      value:
                                          item.modifiedDate == null
                                              ? "-"
                                              : formatDate(item.modifiedDate!),
                                      singleLine: false,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
