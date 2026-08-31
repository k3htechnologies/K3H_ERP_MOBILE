import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/disbursement/presentation/cubit/disbursement_cubit.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
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

class DisbursementScreen extends StatefulWidget {
  final TermSheetModel termSheetModel;
  final TermSheetDetailsView termSheetDetailsView;
  const DisbursementScreen({
    super.key,
    required this.termSheetDetailsView,
    required this.termSheetModel,
  });

  @override
  State<DisbursementScreen> createState() => _DisbursementScreenState();
}

class _DisbursementScreenState extends State<DisbursementScreen> {
  late DisbursementCubit _disbursementCubit;

  @override
  void initState() {
    _disbursementCubit = context.read<DisbursementCubit>();

    _disbursementCubit.getTermSheetView(
      context,
      widget.termSheetDetailsView.projectId,
      widget.termSheetDetailsView.termSheetId,
    );
    super.initState();
  }

  Future<void> _showPopupToDeleteDisbursementAmountDetails(
    BuildContext context,
    TermSheetDisbursedAmountDetailsData disbursement,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Term Sheet Disbursed Amount?',
      'Deleting this Term Sheet Disbursed Amount will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _disbursementCubit.deleteDisbursement(
        context: context,
        termSheetDisbursedAmountDetailsId:
            disbursement.termSheetDisbursedAmountDetailsId,
        termSheetId: disbursement.termSheetId,
        termSheetDetailsId: disbursement.termSheetDetailsId,
        projectId: disbursement.projectId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DisbursementCubit, DisbursementState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return Center(child: loader());
        }
        final termSheet =
            state.termSheetDetailsViewModel ?? widget.termSheetDetailsView;
        final disbursementList = termSheet.termSheetDisbursedAmountDetailsData;

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
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: " > ",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text:
                          widget
                                  .termSheetModel
                                  .nameOfInstitutionBankNbfc
                                  .isEmpty
                              ? "-"
                              : widget.termSheetModel.nameOfInstitutionBankNbfc,
                      style: AppTextStyle.ts14SB(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: " > ",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: widget.termSheetModel.approvalStatus,
                      style: AppTextStyle.ts14M(color: AppColor.grey),
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
                                  termSheet.totalDisbursedAmount
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
                        termSheet.totalDisbursedAmount ==
                        termSheet.facilityAmount,
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addDisbursement,
                        extra: {"termSheetDetailsView": termSheet},
                      );
                    },
                  ),
                ],
              ),
              verticalSpacing(),
              Expanded(
                child:
                    disbursementList.isEmpty
                        ? Center(
                          child: noDataWidget(
                            message: "No Disbursed Amount Details Found",
                            iconSize: 160.0,
                          ),
                        )
                        : ListView.builder(
                          itemCount: disbursementList.length,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final disbursement = disbursementList[index];
                            final bool isLatest =
                                index == disbursementList.length - 1;
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
                                                AppRoutes.addDisbursement,
                                                extra: {
                                                  "index": index,
                                                  "termSheetDetailsView":
                                                      termSheet,
                                                  "disbursementData":
                                                      disbursement,
                                                },
                                              );
                                            },
                                          ),

                                          horizontalSpacing(),

                                          CustomIconButton.delete(
                                            onPressed: () {
                                              _showPopupToDeleteDisbursementAmountDetails(
                                                context,
                                                disbursement,
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                      : SizedBox.shrink(),

                                  buildRowTitleValue(
                                    title: "Disbursed Amount",
                                    value:
                                        disbursement.disbursedAmount
                                            .toIndianCurrency(),
                                  ),

                                  buildRowTitleValue(
                                    title: "Disbursed Date",
                                    value: formatDateTimeAsDDMMMYYYY(
                                      disbursement.disbursedDate,
                                    ),
                                  ),

                                  buildRowTitleValue(
                                    title: "Remark",
                                    value: disbursement.remark,
                                    singleLine: false,
                                  ),

                                  buildRowTitleValue(
                                    title: "Last Modified By",
                                    value: disbursement.createdBy,
                                  ),

                                  buildRowTitleValue(
                                    title: "Last Modified Date",
                                    value: formatDate(disbursement.createdDate),
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
