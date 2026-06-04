import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage_invoice.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/paid_brokerage_booking.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/cubit/brokerage_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_enums.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewBrokerageScreen extends StatefulWidget {
  final BrokerageModel brokerageModel;
  const ViewBrokerageScreen({super.key, required this.brokerageModel});

  @override
  State<ViewBrokerageScreen> createState() => _ViewBrokerageScreenState();
}

class _ViewBrokerageScreenState extends State<ViewBrokerageScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late UtilsCubit _utilsCubit;
  late BrokerageCubit _brokerageCubit;
  late TextEditingController _searchC;
  late AuthorizationModel _invoiceRouteAuthorizationModel,
      _makePaymentRouteAuthorizationModel;
  final List<ValueNotifier<bool>> _invoiceExpandList = [];
  final List<ValueNotifier<bool>> _paymentExpandList = [];
  late ScrollController _invoiceScrollController;
  Timer? _invoiceDebounce;
  late ScrollController _paymentScrollController;
  Timer? _paymentDebounce;
  late List<BrokerageTab> _tabs;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
    _brokerageCubit = context.read<BrokerageCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    _invoiceRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.brokerageInvoice]!;
    _makePaymentRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.brokerageMakePayment]!;
    _tabs = [
      if (_invoiceRouteAuthorizationModel.isView) BrokerageTab.invoice,
      if (_makePaymentRouteAuthorizationModel.isView) BrokerageTab.payment,
    ];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadInitialTabData();
    _tabController.addListener(_onTabChanged);
    _onScroll();
  }

  void _loadInitialTabData() {
    final initialTab = _tabs[_tabController.index];
    switch (initialTab) {
      case (BrokerageTab.invoice):
        _brokerageCubit.getBrokerageInvoiceList(
          context,
          1,
          widget.brokerageModel.projectId,
          widget.brokerageModel.bookingId,
        );

        break;
      case (BrokerageTab.payment):
        _brokerageCubit.getBrokeragePaidList(
          context,
          1,
          widget.brokerageModel.projectId,
          widget.brokerageModel.bookingId,
        );
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 0) {
      _brokerageCubit.getBrokerageInvoiceList(
        context,
        1,
        widget.brokerageModel.projectId,
        widget.brokerageModel.bookingId,
      );
    } else {
      _brokerageCubit.getBrokeragePaidList(
        context,
        1,
        widget.brokerageModel.projectId,
        widget.brokerageModel.bookingId,
      );
    }
  }

  void _onScroll() {
    // INVOICE PAGINATION
    _invoiceScrollController = ScrollController();
    _invoiceScrollController.addListener(() {
      if (_invoiceScrollController.position.pixels >=
              _invoiceScrollController.position.maxScrollExtent - 100 &&
          !_brokerageCubit.state.isLoading! &&
          _brokerageCubit.state.brokerageInvoiceList.length <
              _brokerageCubit.state.totalNumberOfRecordInvoice) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_invoiceDebounce?.isActive ?? false) _invoiceDebounce?.cancel();
        _invoiceDebounce = Timer(const Duration(milliseconds: 300), () {
          _brokerageCubit.getBrokerageInvoiceList(
            context,
            _brokerageCubit.state.currentPageInvoice + 1,
            widget.brokerageModel.projectId,
            widget.brokerageModel.bookingId,
          );
        });
      }
    });
    // PAYMENT PAGINATION
    _paymentScrollController = ScrollController();
    _paymentScrollController.addListener(() {
      if (_paymentScrollController.position.pixels >=
              _paymentScrollController.position.maxScrollExtent - 100 &&
          !_brokerageCubit.state.isLoading! &&
          _brokerageCubit.state.brokeragePaidList.length <
              _brokerageCubit.state.totalNumberOfRecordPaid) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_paymentDebounce?.isActive ?? false) _paymentDebounce?.cancel();
        _paymentDebounce = Timer(const Duration(milliseconds: 300), () {
          _brokerageCubit.getBrokerageInvoiceList(
            context,
            _brokerageCubit.state.currentPagePaid + 1,
            widget.brokerageModel.projectId,
            widget.brokerageModel.bookingId,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteInvoice(
    BuildContext context,
    BrokerageInvoiceModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Invoice ?',
      'Deleting this Invoice will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _brokerageCubit.deleteBrokerageInvoice(
        context: context,
        brokerage: obj,
        index: index,
      );
    }
  }

  Future<void> _showPopupToDeletePayment(
    BuildContext context,
    PaidBrokerageBookingModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Payment ?',
      'Deleting this Payment will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _brokerageCubit.deleteBrokeragePayment(
        context: context,
        payment: obj,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Brokerage",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          spacing: 10,
          children: [
            ChipStyleTabBar(
              margin: EdgeInsets.zero,
              controller: _tabController,
              tabs: _tabs.map((m) => m.title).toList(),
            ),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SearchWidget(
                    hintText: "Search By Invoice No.",
                    onSubmit: (val) {
                      _brokerageCubit.searchInvoice(
                        context,
                        val,
                        widget.brokerageModel.projectId,
                        widget.brokerageModel.bookingId,
                        _tabController.index,
                      );
                    },
                    textController: _searchC,
                  ),
                ),
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return (_tabController.index == 0)
                        ? CustomIconButton(
                          isDisable: !_invoiceRouteAuthorizationModel.isAction,
                          onPressed: () {
                            goRouter.pushNamed(
                              AppRoutes.addBrokerageInvoice,
                              queryParameters: {
                                "bookingId": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    widget.brokerageModel.bookingId.toString(),
                                  ),
                                ),
                                "projectId": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    widget.brokerageModel.projectId.toString(),
                                  ),
                                ),
                              },
                            );
                          },
                          icon: Icon(
                            Icons.add,
                            size: 16,
                            color:
                                _invoiceRouteAuthorizationModel.isAction
                                    ? AppColor.primary
                                    : AppColor.grey,
                          ),
                        )
                        : SizedBox.shrink();
                  },
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  if (_invoiceRouteAuthorizationModel.isView)
                    _buildInvoiceView(),
                  if (_makePaymentRouteAuthorizationModel.isView)
                    _buildPaymentView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceView() {
    return BlocBuilder<BrokerageCubit, BrokerageState>(
      builder: (context, state) {
        _invoiceExpandList.clear();
        _invoiceExpandList.addAll(
          List.generate(
            state.brokerageInvoiceList.length,
            (_) => ValueNotifier(false),
          ),
        );
        if (state.isLoading ?? true) {
          return Center(child: CircularProgressIndicator());
        }
        if (state.brokerageInvoiceList.isEmpty) {
          return Center(child: noDataWidget(message: 'No Invoice Data Found.'));
        }
        return ListView.builder(
          controller: _invoiceScrollController,
          itemCount: state.brokerageInvoiceList.length,
          itemBuilder: (context, index) {
            final invoice = state.brokerageInvoiceList[index];
            final notifier = _invoiceExpandList[index];
            final disabled =
                !_invoiceRouteAuthorizationModel.isAction ||
                invoice.approvalStatus.toLowerCase().contains('approved');
            final disableMakePayment =
                !_makePaymentRouteAuthorizationModel.isAction ||
                invoice.invoiceAmount == invoice.paymentAmount;
            if (index == state.brokerageInvoiceList.length) {
              return state.brokerageInvoiceList.length <
                      state.totalNumberOfRecordInvoice
                  ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }
            return ValueListenableBuilder<bool>(
              valueListenable: notifier,
              builder: (context, isExpanded, _) {
                final isActionAlreadyPerformed = !invoice.isApproval;
                return Container(
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      buildRowTitleValue(
                        title: "Invoice No.",
                        fixesWidth: 100.w,
                        value: invoice.invoiceNumber,
                        customValueWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              invoice.invoiceNumber,
                              style: AppTextStyle.ts14M(),
                            ),
                            Row(
                              spacing: 10,
                              children: [
                                CustomIconButton.edit(
                                  isDisabled: disabled,
                                  onPressed: () {
                                    goRouter.pushNamed(
                                      AppRoutes.addBrokerageInvoice,
                                      queryParameters: {
                                        "bookingId": Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            widget.brokerageModel.bookingId
                                                .toString(),
                                          ),
                                        ),
                                        "projectId": Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            widget.brokerageModel.projectId
                                                .toString(),
                                          ),
                                        ),
                                        "brokerageInvoice":
                                            Uri.encodeQueryComponent(
                                              EncryptionManager.encryptData(
                                                jsonEncode(invoice.toJson()),
                                              ),
                                            ),
                                        'index': index.toString(),
                                      },
                                    );
                                  },
                                ),
                                CustomIconButton.delete(
                                  isDisabled: disabled,
                                  onPressed: () {
                                    _showPopupToDeleteInvoice(
                                      context,
                                      invoice,
                                      index,
                                    );
                                  },
                                ),
                                GestureDetector(
                                  onTap: () => notifier.value = !isExpanded,
                                  child: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      buildRowTitleValue(
                        fixesWidth: 100.w,
                        title: "Invoice Date",
                        value: formatDateTimeAsDDMMMYYYY(invoice.invoiceDate),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 100.w,
                        title: "Invoice Amount",
                        value: (invoice.invoiceAmount).toIndianCurrency(),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 100.w,
                        title: "Paid Amount",
                        value: (invoice.paymentAmount).toIndianCurrency(),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 100.w,
                        title: "Outstanding Amount",
                        value:
                            (invoice.invoiceAmount - invoice.paymentAmount)
                                .toIndianCurrency(),
                      ),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child:
                            isExpanded
                                ? _invoiceDetailCard(invoice)
                                : invoice.approvalStatus.toLowerCase().contains(
                                  'approved',
                                )
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomButton(
                                      isDisable: disableMakePayment,
                                      backgroundColor: AppColor.green,
                                      text: "Make Payment",
                                      textColor: AppColor.white,
                                      onPressed: () {
                                        if (invoice.invoiceAmount !=
                                            invoice.paymentAmount) {
                                          goRouter.pushNamed(
                                            AppRoutes.addBrokeragePayment,
                                            queryParameters: {
                                              "brokerageInvoice":
                                                  Uri.encodeQueryComponent(
                                                    EncryptionManager.encryptData(
                                                      jsonEncode(
                                                        invoice.toJson(),
                                                      ),
                                                    ),
                                                  ),
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                )
                                : ApproveRejectWidget(
                                  isActionAlreadyPerformed:
                                      isActionAlreadyPerformed,
                                  actionTitle:
                                      invoice.isApproval
                                          ? "Approval"
                                          : "History",
                                  onApprove: (remark) async {
                                    final isSuccess = await _utilsCubit
                                        .updateModulesWorkflowApproval(
                                          context: context,
                                          moduleName:
                                              'BROKERAGE INVOICE APPROVAL',
                                          id: invoice.brokerageInvoiceId,
                                          projectId: invoice.projectId,
                                          isApproved: true,
                                          remark: remark.trim(),
                                        );

                                    if (context.mounted && isSuccess) {
                                      _brokerageCubit.getBrokerageInvoiceList(
                                        context,
                                        1,
                                        widget.brokerageModel.projectId,
                                        widget.brokerageModel.bookingId,
                                      );
                                    }
                                  },
                                  onReject: (remark) async {
                                    final isSuccess = await _utilsCubit
                                        .updateModulesWorkflowApproval(
                                          context: context,
                                          moduleName:
                                              'BROKERAGE INVOICE APPROVAL',
                                          id: invoice.brokerageInvoiceId,
                                          projectId: invoice.projectId,
                                          isApproved: false,
                                          remark: remark.trim(),
                                        );

                                    if (context.mounted && isSuccess) {
                                      _brokerageCubit.getBrokerageInvoiceList(
                                        context,
                                        1,
                                        widget.brokerageModel.projectId,
                                        widget.brokerageModel.bookingId,
                                      );
                                    }
                                  },
                                  onThirdTap: () async {
                                    final approvalLogHistoryList =
                                        await _utilsCubit.getApprovalLogHistory(
                                          context: context,
                                          id: invoice.brokerageInvoiceId,
                                          projectId: invoice.projectId,
                                          moduleName:
                                              'BROKERAGE INVOICE APPROVAL',
                                        );
                                    if (context.mounted) {
                                      goRouter.pushNamed(
                                        AppRoutes.approvalLogHistory,
                                        queryParameters: {
                                          "title": Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              "Invoice Log History",
                                            ),
                                          ),
                                          "approvalList": Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(
                                                approvalLogHistoryList
                                                    .map((e) => e.toJson())
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        },
                                      );
                                    }
                                  },
                                  popupTitle: "Invoice Approval",
                                ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _invoiceDetailCard(BrokerageInvoiceModel invoice) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: ValueKey(true),
          decoration: BoxDecoration(
            color: AppColor.grey10.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.grey10),
          ),
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                "Invoice Details",
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
              buildRowTitleValue(
                title: "Amount",
                value: invoice.invoiceAmount.toIndianCurrency(),
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Bank Name",
                    value: invoice.bankName,
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Account Name",
                    value: invoice.accountName,
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Account Number",
                    value: invoice.accountNumber,
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "IFSC Code",
                    value: invoice.ifscCode,
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Due Date",
                    value: formatDateTimeAsDDMMMYYYY(invoice.dueDate),
                  ),
                ],
              ),
              Divider(height: 1, color: AppColor.grey50),
              Text("Action Details", style: AppTextStyle.ts14M()),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Created By",
                    value: invoice.createdBy,
                  ),
                  buildColumnTitleValue(
                    title: "Created Date",
                    value: formatDate(invoice.createdDate),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Modified By",
                    value: invoice.modifiedBy,
                  ),
                  buildColumnTitleValue(
                    title: "Modified Date",
                    value:
                        (invoice.modifiedDate == null)
                            ? "-"
                            : formatDate(invoice.modifiedDate),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (invoice.approvalStatus.toLowerCase().contains('approved'))
          ApproveRejectWidget(
            isActionAlreadyPerformed: true,
            actionTitle: invoice.isApproval ? "Approval" : "History",
            onApprove: (remark) async {
              final isSuccess = await _utilsCubit.updateModulesWorkflowApproval(
                context: context,
                moduleName: 'BROKERAGE INVOICE APPROVAL',
                id: invoice.brokerageInvoiceId,
                projectId: invoice.projectId,
                isApproved: true,
                remark: remark.trim(),
              );
              if (!mounted) return;
              if (isSuccess) {
                _brokerageCubit.getBrokerageInvoiceList(
                  context,
                  1,
                  widget.brokerageModel.projectId,
                  widget.brokerageModel.bookingId,
                );
              }
            },
            onReject: (remark) async {
              final isSuccess = await _utilsCubit.updateModulesWorkflowApproval(
                context: context,
                moduleName: 'BROKERAGE INVOICE APPROVAL',
                id: invoice.brokerageInvoiceId,
                projectId: invoice.projectId,
                isApproved: false,
                remark: remark.trim(),
              );
              if (!mounted) return;
              if (isSuccess) {
                _brokerageCubit.getBrokerageInvoiceList(
                  context,
                  1,
                  widget.brokerageModel.projectId,
                  widget.brokerageModel.bookingId,
                );
              }
            },
            onThirdTap: () async {
              final approvalLogHistoryList = await _utilsCubit
                  .getApprovalLogHistory(
                    context: context,
                    id: invoice.brokerageInvoiceId,
                    projectId: invoice.projectId,
                    moduleName: 'BROKERAGE INVOICE APPROVAL',
                  );
              if (context.mounted) {
                goRouter.pushNamed(
                  AppRoutes.approvalLogHistory,
                  queryParameters: {
                    "title": Uri.encodeComponent(
                      EncryptionManager.encryptData("Invoice Log History"),
                    ),
                    "approvalList": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        jsonEncode(
                          approvalLogHistoryList
                              .map((e) => e.toJson())
                              .toList(),
                        ),
                      ),
                    ),
                  },
                );
              }
            },
            popupTitle: "Invoice Approval",
          ),
      ],
    );
  }

  Widget _buildPaymentView() {
    return BlocBuilder<BrokerageCubit, BrokerageState>(
      builder: (context, state) {
        _paymentExpandList.clear();
        _paymentExpandList.addAll(
          List.generate(
            state.brokeragePaidList.length,
            (_) => ValueNotifier(false),
          ),
        );

        if (state.isLoading ?? true) {
          return Center(child: CircularProgressIndicator());
        }
        if (state.brokeragePaidList.isEmpty) {
          return Center(child: noDataWidget(message: 'No Invoice Data Found.'));
        }
        return ListView.builder(
          controller: _paymentScrollController,
          itemCount: state.brokeragePaidList.length,
          itemBuilder: (context, index) {
            final payment = state.brokeragePaidList[index];
            final notifier = _paymentExpandList[index];
            if (index == state.brokeragePaidList.length) {
              return state.brokeragePaidList.length <
                      state.totalNumberOfRecordPaid
                  ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            return ValueListenableBuilder<bool>(
              valueListenable: notifier,
              builder: (context, isExpanded, _) {
                return Container(
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      buildRowTitleValue(
                        title: "Invoice No.",
                        value: payment.invoiceNumber,
                        customValueWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              payment.invoiceNumber,
                              style: AppTextStyle.ts14M(),
                            ),
                            Row(
                              spacing: 10,
                              children: [
                                CustomIconButton.delete(
                                  isDisabled:
                                      !_makePaymentRouteAuthorizationModel
                                          .isAction,
                                  onPressed: () {
                                    _showPopupToDeletePayment(
                                      context,
                                      payment,
                                      index,
                                    );
                                  },
                                ),
                                GestureDetector(
                                  onTap: () => notifier.value = !isExpanded,
                                  child: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      buildRowTitleValue(
                        title: "Invoice Amount",
                        value: payment.invoiceAmount.toIndianCurrency(),
                      ),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child:
                            isExpanded
                                ? _paymentDetailCard(payment)
                                : SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _paymentDetailCard(PaidBrokerageBookingModel payment) {
    return Container(
      key: ValueKey(true),
      decoration: BoxDecoration(
        color: AppColor.grey10.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.grey10),
      ),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            "Payment Details",
            style: AppTextStyle.ts14M(color: AppColor.black),
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Bank Name",
                value: payment.bankName,
              ),
            ],
          ),
          buildRowTitleValue(title: "Payment Type", value: payment.paymentType),
          buildRowTitleValue(title: "Payment Mode", value: payment.paymentMode),

          Row(
            children: [
              buildColumnTitleValue(
                title: "Account Number",
                value: payment.accountNumber,
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "IFSC Code",
                value: payment.ifscCode,
              ),
            ],
          ),

          Row(
            children: [
              buildColumnTitleValue(
                title: "Amount Paid",
                value: payment.amountPaid.toIndianCurrency(),
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "TDS Amount",
                value: payment.tdsAmount.toIndianCurrency(),
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Transaction Number / Receipt",
                value: payment.transactionReceiptURL,
                customValueWidget: GestureDetector(
                  onTap: () {
                    if (payment.transactionReceiptURL.isNotEmpty) {
                      showFilePreviewDialog(
                        context,
                        payment.transactionReceiptURL.split(","),
                      );
                    }
                  },
                  child: Row(
                    spacing: 5,
                    children: [
                      Text(
                        payment.transactionNumber,
                        style: AppTextStyle.ts14M(color: AppColor.primary),
                      ),
                      Icon(
                        Icons.remove_red_eye_outlined,
                        color: AppColor.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 1, color: AppColor.grey50),
          Text("Action Details", style: AppTextStyle.ts14M()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Created By",
                value: payment.createdBy,
              ),
              buildColumnTitleValue(
                title: "Created Date",
                value: formatDate(payment.createdDate),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Modified By",
                value: payment.modifiedBy,
              ),
              buildColumnTitleValue(
                title: "Modified Date",
                value:
                    (payment.modifiedDate == null)
                        ? "-"
                        : formatDate(payment.modifiedDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
