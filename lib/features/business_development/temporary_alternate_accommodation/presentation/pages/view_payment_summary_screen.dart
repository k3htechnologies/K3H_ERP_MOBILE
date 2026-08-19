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
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _temporaryAlternateAccommodationCubit =
        context.read<TemporaryAlternateAccommodationCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.rent] ??
        AuthorizationModel();
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

  // DELETE DEPARTMENT
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
      _temporaryAlternateAccommodationCubit.deletePayTrackRent(
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
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Temporary Alternate\nAccommodation",
        authorization: _routeAuthorizationModel,
        extraHeight: 20,
        showMenuIcon: false,
        searchHintText: 'Search byFlat Number or Applicant Name',
        textController: TextEditingController(),
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
        onAddCallback: () {
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
                  _temporaryAlternateAccommodationCubit.paidAmountForSummary
                      ?.toString(),
              'previousRoute': AppRoutes.viewSummary,
            },
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              spacing: 16,
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
                            .currentTabName,
                  },
                  {
                    "title": "Carpet Area (SqFt)",
                    "value":
                        '${widget.rentModel.flatCarpetAreaSqFt.addCommas()} SqFt',
                  },
                  {"title": "Unit Type", "value": widget.rentModel.flatType},
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
  }

  Widget _paymentLedgerCard(
    PaymentLedgerModel item,
    TemporaryAlternateAccommodationState state,
    int? index,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        children: [
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    goRouter.pushNamed(
                      AppRoutes.viewPaymentDetails,
                      queryParameters: <String, String>{
                        'rentModel': Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(
                            jsonEncode(widget.rentModel.toJson()),
                          ),
                        ),
                        'totalAmount': widget.totalAmount.toString(),
                        'paymentLedger': Uri.encodeComponent(
                          EncryptionManager.encryptData(
                            jsonEncode(item.toJson()),
                          ),
                        ),
                      },
                    );
                  },
                  child: Text(
                    item.payAmount.toIndianCurrency(),
                    style: AppTextStyle.ts18M(color: AppColor.slightDarkBlue),
                  ),
                ),
              ),
              Row(
                spacing: 10,
                children: [
                  CustomIconButton.edit(
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
                              jsonEncode(item.toJson()),
                            ),
                          ),
                          'totalAmount': widget.totalAmount.toString(),
                          'paymentLedgerIndex': (index ?? 0).toString(),
                          'previousRoute': AppRoutes.viewSummary,
                        },
                      );
                    },
                  ),
                  CustomIconButton.delete(
                    onPressed: () {
                      _showPopupToDeletePayTrackRent(
                        context,
                        item,
                        state.currentPage,
                        index ?? 0,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          buildRowTitleValue(title: 'Payment Mode', value: item.paymentMode),
          buildRowTitleValue(title: 'Amount Type', value: item.amountType),
          buildRowTitleValue(
            title: 'Amount (₹)',
            value: item.payAmount.toIndianCurrency(),
          ),
        ],
      ),
    );
  }
}
