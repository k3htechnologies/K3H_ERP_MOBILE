import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/finance/repayment/presentation/cubit/repayment_cubit.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RepaymentScreen extends StatefulWidget {
  final TermSheetModel termSheetModel;
  final TermSheetDetailsView termSheetDetailsView;
  const RepaymentScreen({
    super.key,
    required this.termSheetDetailsView,
    required this.termSheetModel,
  });

  @override
  State<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends State<RepaymentScreen> {
  late RepaymentCubit _repaymentCubit;

  @override
  void initState() {
    _repaymentCubit = context.read<RepaymentCubit>();

    _repaymentCubit.getTermSheetView(
      context,
      widget.termSheetDetailsView.projectId,
      widget.termSheetDetailsView.termSheetId,
    );
    super.initState();
  }

  Future<void> _showPopupToDeleteTermSheetRepayment(
    BuildContext context,
    TermSheetRepayLedgerData repayment,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Term Sheet Repayment ?',
      'Deleting this Term Sheet Repayment will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _repaymentCubit.deleteRepayment(
        context: context,
        termSheetRepayLedgerId: repayment.termSheetRepayLedgerId,
        termSheetId: repayment.termSheetId,
        termSheetDetailsId: repayment.termSheetDetailsId,
        projectId: repayment.projectId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepaymentCubit, RepaymentState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return Center(child: loader());
        }
        final termSheet =
            state.termSheetDetailsViewModel ?? widget.termSheetDetailsView;
        final repaymentList = termSheet.termSheetRepayLedgerData;
        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.termSheetModel.projectName,
                      style: AppTextStyle.ts14M(),
                    ),
                    TextSpan(
                      text: " > ",
                      style: AppTextStyle.ts14M(
                        color: AppColor.greyTitleAndValueColor,
                      ),
                    ),
                    TextSpan(
                      text:
                          widget
                                  .termSheetModel
                                  .nameOfInstitutionBankNbfc
                                  .isEmpty
                              ? "-"
                              : widget.termSheetModel.nameOfInstitutionBankNbfc,
                      style: AppTextStyle.ts14SB(color: AppColor.primary),
                    ),
                    TextSpan(
                      text: " > ",
                      style: AppTextStyle.ts14M(
                        color: AppColor.greyTitleAndValueColor,
                      ),
                    ),
                    TextSpan(
                      text: widget.termSheetModel.approvalStatus,
                      style: AppTextStyle.ts14M(),
                    ),
                  ],
                ),
              ),
              verticalSpacing(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Disbursed Amount Details",
                        style: AppTextStyle.ts14SB(),
                      ),
                      verticalSpacing(),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Total Disbursed Amount: ",
                              style: AppTextStyle.ts12M(),
                            ),
                            TextSpan(
                              text:
                                  termSheet.totalRepayLedgerAmount
                                      .toIndianCurrency(),
                              style: AppTextStyle.ts12SB(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  horizontalSpacing(),
                  CustomButton(
                    text: "Add",
                    isDisable:
                        termSheet.totalDisbursedAmount > 0 &&
                        termSheet.totalDisbursedAmount ==
                            termSheet.totalRepayLedgerAmount,
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addRepayment,
                        extra: {
                          "isEdit": false,
                          "termSheetDetailsView": termSheet,
                        },
                      );
                    },
                  ),
                ],
              ),
              verticalSpacing(),
              Expanded(
                child:
                    repaymentList.isEmpty
                        ? Center(
                          child: Center(
                            child: noDataWidget(
                              message: "No Repay Ledger Details Found",
                              iconSize: 160.0,
                            ),
                          ),
                        )
                        : ListView.builder(
                          itemCount: repaymentList.length,
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final repayment = repaymentList[index];
                            final bool isLatest =
                                index == repaymentList.length - 1;
                            return Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              decoration: commonCardDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isLatest
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          CustomIconButton.edit(
                                            onPressed: () {
                                              goRouter.pushNamed(
                                                AppRoutes.addRepayment,
                                                extra: {
                                                  "isEdit": true,
                                                  "termSheetDetailsView":
                                                      termSheet,
                                                  "repaymentData": repayment,
                                                },
                                              );
                                            },
                                          ),

                                          horizontalSpacing(),

                                          CustomIconButton.delete(
                                            onPressed: () {
                                              _showPopupToDeleteTermSheetRepayment(
                                                context,
                                                repayment,
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                      : SizedBox.shrink(),
                                  buildRowTitleValue(
                                    title: "Amount",
                                    value: repayment.amount.toIndianCurrency(),
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Payment Date",
                                    value: formatDateTimeAsDDMMMYYYY(
                                      repayment.paymentDate,
                                    ),
                                  ),
                                  buildRowTitleValue(
                                    title: "Remark",
                                    value: repayment.remark,
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Last Modified By",
                                    value: repayment.createdBy,
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Last Modified Date",
                                    value: formatDate(repayment.createdDate),
                                    singleLine: false,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
