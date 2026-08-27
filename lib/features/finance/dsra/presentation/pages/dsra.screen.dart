import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/finance/dsra/presentation/cubit/dsra_cubit.dart';
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

class DSRAScreen extends StatefulWidget {
  final TermSheetModel termSheetModel;
  final TermSheetDetailsView termSheetDetailsView;
  const DSRAScreen({
    super.key,
    required this.termSheetDetailsView,
    required this.termSheetModel,
  });

  @override
  State<DSRAScreen> createState() => _DSRAScreenState();
}

class _DSRAScreenState extends State<DSRAScreen> {
  late DsraCubit _dsraCubit;

  @override
  void initState() {
    _dsraCubit = context.read<DsraCubit>();

    _dsraCubit.getTermSheetView(
      context,
      widget.termSheetDetailsView.projectId,
      widget.termSheetDetailsView.termSheetId,
    );
    super.initState();
  }

  Future<void> _showPopupToDeeleteTermSheetDSRA(
    BuildContext context,
    TermSheetDebtServiceReserveAccountData dsra,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Term Sheet Direct Selling Agent ?',
      'Deleting this Term Sheet Direct Selling Agent will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _dsraCubit.deleteDsra(
        context: context,
        termSheetDebtServiceReserveAccountId:
            dsra.termSheetDebtServiceReserveAccountId,
        termSheetId: dsra.termSheetId,
        termSheetDetailsId: dsra.termSheetDetailsId,
        projectId: dsra.projectId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DsraCubit, DsraState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return Center(child: loader());
        }
        final termSheet =
            state.termSheetDetailsViewModel ?? widget.termSheetDetailsView;
        final dsraList = termSheet.termSheetDebtServiceReserveAccountData;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Debt Service Reserve Account (DSRA) Details",
                      style: AppTextStyle.ts14SB(),
                    ),
                  ),
                  horizontalSpacing(),
                  CustomButton(
                    text: "Add",
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addDsra,
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
                    dsraList.isEmpty
                        ? Center(
                          child: noDataWidget(
                            message:
                                "No Debt Service Reserve Account Details Found",
                            iconSize: 160.0,
                          ),
                        )
                        : ListView.builder(
                          itemCount: dsraList.length,
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final dsra = dsraList[index];
                            final bool isLatest = index == dsraList.length - 1;
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
                                                AppRoutes.addDsra,
                                                extra: {
                                                  "isEdit": true,
                                                  "termSheetDetailsView":
                                                      termSheet,
                                                  "dsraData": dsra,
                                                },
                                              );
                                            },
                                          ),

                                          horizontalSpacing(),

                                          CustomIconButton.delete(
                                            onPressed: () {
                                              _showPopupToDeeleteTermSheetDSRA(
                                                context,
                                                dsra,
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                      : SizedBox.shrink(),
                                  buildRowTitleValue(
                                    title: "Term",
                                    value: dsra.term,
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Term",
                                    value: dsra.amount.toIndianCurrency(),
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Date",
                                    value: formatDateTimeAsDDMMMYYYY(dsra.date),
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Rate Of Interest",
                                    value:
                                        " ${dsra.rateOfInterestInPercentage.toString()} %",
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Redemption Value",
                                    value:
                                        dsra.redemptionValue.toIndianCurrency(),
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Maturity Period",
                                    value: dsra.maturityPeriod.toString(),
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Withdraw Amount",
                                    value:
                                        dsra.withdrawAmount.toIndianCurrency(),
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Withdraw Date",
                                    value: formatDateTimeAsDDMMMYYYY(
                                      dsra.withdrawDate,
                                    ),
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Remark",
                                    value: dsra.remark,
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Last Modified By",
                                    value: dsra.createdBy,
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Last Modified Date",
                                    value: formatDate(dsra.createdDate),
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
