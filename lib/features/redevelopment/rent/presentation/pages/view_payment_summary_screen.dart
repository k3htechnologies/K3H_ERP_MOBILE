import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/rent_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/model/payment_ledger.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/model/rent.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/presentation/cubit/rent_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewPaymentSummaryScreen extends StatefulWidget {
  final RentModel rentModel;

  const ViewPaymentSummaryScreen({super.key, required this.rentModel});

  @override
  State<ViewPaymentSummaryScreen> createState() =>
      _ViewPaymentSummaryScreenState();
}

class _ViewPaymentSummaryScreenState extends State<ViewPaymentSummaryScreen> {
  late RentCubit _rentCubit;

  @override
  void initState() {
    super.initState();
    _rentCubit = context.read<RentCubit>();
    _loadPaymentLedger();
  }

  void _loadPaymentLedger() {
    _rentCubit.getPayTrackRentList(
      context,
      widget.rentModel.tenantId,
      widget.rentModel.tenantApplicantId,
      widget.rentModel.buildingId,
      widget.rentModel.projectId,
    );
  }

  // <---- DELETE DEPARTMENT ---->
  Future<void> _showPopupToDeletePayTrackRent(
    BuildContext context,
    PaymentLedgerModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a payment?',
      'Deleting this payment will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _rentCubit.deletePayTrackRent(
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
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Pay Track Rent - ${widget.rentModel.applicantName}',
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<RentCubit, RentState>(
        bloc: _rentCubit,
        buildWhen:
            (previous, current) =>
                previous.paymentLedgerList != current.paymentLedgerList ||
                previous.isLoading != current.isLoading,
        builder: (context, state) {
          if (state.isLoading == true &&
              (state.paymentLedgerList ?? []).isEmpty) {
            return Center(child: loader());
          }
          final list = state.paymentLedgerList ?? [];
          if (list.isEmpty) {
            return Center(child: noDataWidget());
          }
          return RefreshIndicator(
            onRefresh: () async => _loadPaymentLedger(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return _paymentLedgerCard(list[index], state, index);
              },
            ),
          );
        },
      ),
    );
  }

  // PAYMENT LEDGER CARD
  Widget _paymentLedgerCard(
    PaymentLedgerModel item,
    RentState state,
    int? index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    addCommasToInteger(item.payAmount),
                    style: AppTextStyle.ts18M(color: AppColor.slightDarkBlue),
                  ),
                  Text(
                    formatDateTimeAsDDMMMYYYY(
                      item.transactionChequeDemandDraftDate,
                    ),
                    style: AppTextStyle.ts12R(color: AppColor.grey),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  CustomIconButton.edit(
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addPayment,
                        extra: {
                          'rentModel': widget.rentModel,
                          'buildingId': widget.rentModel.buildingId,
                          'rentDetails': <RentDetailsModel>[],
                          'totalAmount': 0.0,
                          'paidAmount': 0.0,
                          'paymentLedger': item,
                          'paymentLedgerIndex': index ?? 0,
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
          const SizedBox(height: 12),
          buildRowTitleValue(title: 'Payment Mode', value: item.paymentMode),
          buildRowTitleValue(title: 'Amount Type', value: item.amountType),
          buildRowTitleValue(title: 'Payment Type', value: item.paymentType),
          buildRowTitleValue(title: 'Bank', value: item.bankName),
          buildRowTitleValue(title: 'Account', value: item.accountNumber),
          buildRowTitleValue(title: 'IFSC Code', value: item.ifscCode),
          buildRowTitleValue(
            title: 'Account Holder',
            value: item.applicantName,
          ),
          buildRowTitleValue(
            title: 'Transaction / Cheque / DD No.',
            value: item.transactionChequeDemandDraftNumber,
          ),
        ],
      ),
    );
  }
}
