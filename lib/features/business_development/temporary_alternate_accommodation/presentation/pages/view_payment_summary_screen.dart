import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/payment_ledger.model.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/temporary_alternate_accommodation.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/pages/widget/custom_expansion_tile.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/presentation/cubit/temporary_alternate_accommodation_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewPaymentSummaryScreen extends StatefulWidget {
  final TemporaryAlternativeAccommodationModel rentModel;
  final double totalAmount;
  const ViewPaymentSummaryScreen({
    super.key,
    required this.rentModel,
    required this.totalAmount,
  });
  @override
  State<ViewPaymentSummaryScreen> createState() =>
      _ViewPaymentSummaryScreenState();
}

class _ViewPaymentSummaryScreenState extends State<ViewPaymentSummaryScreen> {
  late TemporaryAlternateAccommodationCubit
  _temporaryAlternateAccommodationCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _searchC;
  final ValueNotifier<bool> _fullyAmountPaid = ValueNotifier(false);
  final ValueNotifier<bool> _canExport = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _temporaryAlternateAccommodationCubit =
        context.read<TemporaryAlternateAccommodationCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.rent] ??
        AuthorizationModel();
    _searchC = TextEditingController();
    _loadPaymentLedger();
  }

  void _loadPaymentLedger() async {
    await _temporaryAlternateAccommodationCubit.clearPaymentLedger();
    if (mounted) {
      _temporaryAlternateAccommodationCubit.getPayTrackRentLedgerList(
        context,
        widget.rentModel.tenantId,
        widget.rentModel.tenantApplicantId,
        widget.rentModel.buildingId,
        widget.rentModel.projectId,
      );
    }
  }

  Future<void> _showPopupToDeletePayTrackRent(
    BuildContext context,
    PaymentLedgerModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'Delete Pay Track Ledger',
      'Are you sure you want to delete this Pay Track Ledger record?',
    );
    if (result && context.mounted) {
      _temporaryAlternateAccommodationCubit.deletePayTrackRentLedger(
        context: context,
        payTrackRentId: obj.payTrackRentId,
        uniqueKey: obj.uniquekey,
        projectId: obj.projectId,
        tenantId: obj.tenantId,
        tenantApplicantId: obj.tenantApplicantId,
        buildingId: widget.rentModel.buildingId,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      TemporaryAlternateAccommodationCubit,
      TemporaryAlternateAccommodationState
    >(
      listener: (context, state) {
        _fullyAmountPaid.value =
            widget.totalAmount ==
            _temporaryAlternateAccommodationCubit.paidAmountForSummary;
        _canExport.value =
            state.paymentLedgerList != null &&
            state.paymentLedgerList!.isNotEmpty;
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_canExport, _fullyAmountPaid]),
        builder: (context, _) {
          return Scaffold(
            appBar: CustomAppBar(
              screenTitle: "Temporary Alternate\nAccommodation",
              authorization: _routeAuthorizationModel,
              extraHeight: 20,
              showMenuIcon: false,
              searchHintText: 'Search by Account Holder Name',
              textController: _searchC,
              onSearchSubmit: (value) {
                _temporaryAlternateAccommodationCubit.onPaymentLedgerSearch(
                  context: context,
                  value: value,
                  tenantId: widget.rentModel.tenantId,
                  tenantApplicantId: widget.rentModel.tenantApplicantId,
                  buildingId: widget.rentModel.buildingId,
                  projectId: widget.rentModel.projectId,
                );
              },
              onAddCallback:
                  _fullyAmountPaid.value
                      ? null
                      : () {
                        goRouter.pushNamed(
                          AppRoutes.addPayment,
                          queryParameters: {
                            'rent': Uri.encodeComponent(
                              EncryptionManager.encryptData(
                                jsonEncode(widget.rentModel.toJson()),
                              ),
                            ),
                            'totalAmount': widget.totalAmount.toString(),
                            'paidAmount':
                                _temporaryAlternateAccommodationCubit
                                    .paidAmountForSummary
                                    ?.toString(),
                            'previousRoute': AppRoutes.viewSummary,
                          },
                        );
                      },
              onExportCallback:
                  !_canExport.value
                      ? null
                      : (value) {
                        _temporaryAlternateAccommodationCubit
                            .exportExcelPdfForPaymentLedger(
                              context,
                              value,
                              projectId: widget.rentModel.projectId,
                              buildingId: widget.rentModel.buildingId,
                              tenantId: widget.rentModel.tenantId,
                              tenantApplicantId:
                                  widget.rentModel.tenantApplicantId,
                            );
                      },
            ),
            body: BlocBuilder<
              TemporaryAlternateAccommodationCubit,
              TemporaryAlternateAccommodationState
            >(
              builder: (context, state) {
                if (state.isLoading == true &&
                    (state.paymentLedgerList ?? []).isEmpty) {
                  return Center(child: loader());
                }
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    spacing: 12,
                    children: [
                      infoCard([
                        {
                          "title": "Flat Number",
                          "value": widget.rentModel.flatNumber,
                        },
                        {
                          "title": "Applicant Name",
                          "value": widget.rentModel.applicantName,
                        },
                        {"title": "Tenure", "value": widget.rentModel.tenure},
                        {
                          "title": "Charge Type",
                          "value":
                              context
                                  .read<TemporaryAlternateAccommodationCubit>()
                                  .state
                                  .chargeType,
                        },
                        {
                          "title": "Carpet Area (SqFt)",
                          "value":
                              '${widget.rentModel.flatCarpetAreaSqFt.addCommas()} SqFt',
                        },
                        {
                          "title": "Unit Type",
                          "value": widget.rentModel.flatType,
                        },
                        {
                          "title": "Total Amount",
                          "value": widget.totalAmount.toIndianCurrency(),
                        },
                        {
                          "title": "Paid Total Amount",
                          "value":
                              _temporaryAlternateAccommodationCubit
                                  .paidAmountForSummary
                                  ?.toIndianCurrency(),
                        },
                      ]),
                      Expanded(
                        child: BlocBuilder<
                          TemporaryAlternateAccommodationCubit,
                          TemporaryAlternateAccommodationState
                        >(
                          bloc: _temporaryAlternateAccommodationCubit,
                          buildWhen:
                              (previous, current) =>
                                  previous.paymentLedgerList !=
                                      current.paymentLedgerList ||
                                  previous.isLoading != current.isLoading,
                          builder: (context, state) {
                            final list = state.paymentLedgerList ?? [];
                            if (list.isEmpty) {
                              return Container(
                                decoration: commonCardDecoration(),
                                child: Center(child: noDataWidget()),
                              );
                            }
                            return RefreshIndicator(
                              onRefresh: () async => _loadPaymentLedger(),
                              child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  return _paymentLedgerCard(
                                    list[index],
                                    state,
                                    index,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _paymentLedgerCard(
    PaymentLedgerModel paymentLedger,
    TemporaryAlternateAccommodationState state,
    int? index,
  ) {
    return CustomExpandableCard(
      margin: EdgeInsets.only(bottom: 16),
      header: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              paymentModeStatusWidget(paymentLedger.paymentMode),
              Row(
                spacing: 10,
                children: [
                  CustomIconButton.edit(
                    isDisabled: !_routeAuthorizationModel.isAction,
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addPayment,
                        queryParameters: {
                          'rent': Uri.encodeComponent(
                            EncryptionManager.encryptData(
                              jsonEncode(widget.rentModel.toJson()),
                            ),
                          ),
                          'paymentLedger': Uri.encodeComponent(
                            EncryptionManager.encryptData(
                              jsonEncode(paymentLedger.toJson()),
                            ),
                          ),
                          'totalAmount': widget.totalAmount.toString(),
                          'paymentLedgerIndex': (index ?? 0).toString(),
                        },
                      );
                    },
                  ),
                  CustomIconButton.delete(
                    isDisabled: !_routeAuthorizationModel.isAction,
                    onPressed: () {
                      _showPopupToDeletePayTrackRent(
                        context,
                        paymentLedger,
                        state.currentPage,
                        index ?? 0,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Amount Type",
                value: paymentLedger.amountType,
              ),
              buildColumnTitleValue(
                title: "Amount (₹)",
                value: paymentLedger.payAmount.toIndianCurrency(),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        spacing: 12,
        children: [
          _detailsCard(
            title: 'Payee Details',
            childrens: [
              buildColumnTitleValue(
                title: 'Bank',
                value: paymentLedger.bankName,
                removeExpanded: true,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: 'Account Holder Name',
                    value: paymentLedger.accountHolderName,
                  ),
                  buildColumnTitleValue(
                    title: 'Account Number',
                    value: paymentLedger.accountNumber,
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: 'IFSC Code',
                    value: paymentLedger.ifscCode,
                  ),
                  buildColumnTitleValue(
                    title: 'Transaction / Cheque / DD Date',
                    value: formatDateTimeAsDDMMMYYYY(
                      paymentLedger.transactionChequeDemandDraftDate,
                    ),
                  ),
                ],
              ),
              buildColumnTitleValue(
                title: 'Transaction / Cheque / DD No.',
                value: paymentLedger.transactionChequeDemandDraftNumber,
                removeExpanded: true,
              ),
              buildColumnTitleValue(
                title: "Transaction /Cheque/DD Document",
                removeExpanded: true,
                value: paymentLedger.transactionChequeDemandDraftUrl,
                customValueWidget: Row(
                  children: [
                    CustomButton.documentOutline(
                      onPressed: () {
                        if (paymentLedger
                            .transactionChequeDemandDraftUrl
                            .isNotEmpty) {
                          showFilePreviewDialog(
                            title: "Transaction /Cheque/DD Document",
                            context,
                            paymentLedger.transactionChequeDemandDraftUrl.split(
                              ",",
                            ),
                          );
                        }
                      },
                      isDisable:
                          paymentLedger.transactionChequeDemandDraftUrl.isEmpty,
                    ),
                    Spacer(),
                  ],
                ),
              ),
              buildColumnTitleValue(
                title: "Payment Receipt",
                removeExpanded: true,
                value: paymentLedger.paymentReceiptUrl,
                customValueWidget: Row(
                  children: [
                    CustomButton.documentOutline(
                      onPressed: () {
                        if (paymentLedger.paymentReceiptUrl.isNotEmpty) {
                          showFilePreviewDialog(
                            title: "Payment Receipt",
                            context,
                            paymentLedger.paymentReceiptUrl.split(","),
                          );
                        }
                      },
                      isDisable: paymentLedger.paymentReceiptUrl.isEmpty,
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ],
          ),
          _detailsCard(
            title: "Developer Details",
            childrens: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: 'Project Account Holder',
                    value: paymentLedger.projectBankAccountHolderName,
                  ),
                  buildColumnTitleValue(
                    title: 'Project Account Number',
                    value: paymentLedger.projectBankAccountNumber,
                  ),
                ],
              ),
              buildColumnTitleValue(
                title: 'Bank Name',
                value: paymentLedger.projectBankName,
                removeExpanded: true,
              ),
              buildColumnTitleValue(
                title: 'Project IFSC Code',
                value: paymentLedger.projectBankIfscCode,
                removeExpanded: true,
              ),
            ],
          ),
          _detailsCard(
            title: "Action Details",
            childrens: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: 'Approval Status',
                    value: paymentLedger.approvalStatus,
                  ),
                  buildColumnTitleValue(
                    title: 'Created By',
                    value: paymentLedger.createdBy,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Created Date",
                    value: formatDate(paymentLedger.createdDate),
                  ),
                  buildColumnTitleValue(
                    title: 'Modified By',
                    value: paymentLedger.modifiedBy,
                  ),
                ],
              ),
              buildColumnTitleValue(
                title: "Modified Date",
                value: formatDate(paymentLedger.modifiedDate),
                removeExpanded: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _detailsCard({required String title, required List<Widget> childrens}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColor.grey10.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColor.grey10),
    ),
    padding: EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(title, style: AppTextStyle.ts14SB(color: AppColor.black)),
        ...childrens,
      ],
    ),
  );
}
