import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsa/presentation/cubit/dsa_cubit.dart';
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

class DSAScreen extends StatefulWidget {
  final TermSheetModel termSheetModel;
  final TermSheetDetailsView termSheetDetailsView;
  const DSAScreen({
    super.key,
    required this.termSheetDetailsView,
    required this.termSheetModel,
  });

  @override
  State<DSAScreen> createState() => _DSAScreenState();
}

class _DSAScreenState extends State<DSAScreen> {
  late DsaCubit _dsaCubit;

  @override
  void initState() {
    _dsaCubit = context.read<DsaCubit>();

    _dsaCubit.getTermSheetView(
      context,
      widget.termSheetDetailsView.projectId,
      widget.termSheetDetailsView.termSheetId,
    );
    super.initState();
  }

  Future<void> _showPopupToDeeleteTermSheetDirectSellingAgent(
    BuildContext context,
    TermSheetDirectSellingAgentData dsa,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Term Sheet Direct Selling Agent ?',
      'Deleting this Term Sheet Direct Selling Agent will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _dsaCubit.deleteDsa(
        context: context,
        termSheetDirectSellingAgentId: dsa.termSheetDirectSellingAgentId,
        termSheetId: dsa.termSheetId,
        termSheetDetailsId: dsa.termSheetDetailsId,
        projectId: dsa.projectId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DsaCubit, DsaState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return Center(child: loader());
        }
        final termSheet =
            state.termSheetDetailsViewModel ?? widget.termSheetDetailsView;
        final dsaList = termSheet.termSheetDirectSellingAgentData;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Direct Selling Agent (DSA) Details",
                    style: AppTextStyle.ts14SB(),
                  ),
                  horizontalSpacing(),
                  CustomButton(
                    text: "Add",
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addDsa,
                        extra: {"termSheetDetailsView": termSheet},
                      );
                    },
                  ),
                ],
              ),
              verticalSpacing(),
              Expanded(
                child:
                    dsaList.isEmpty
                        ? Center(
                          child: noDataWidget(
                            message:
                                "No Direct Selling Agent (DSA) Details Found",
                            iconSize: 160.0,
                          ),
                        )
                        : ListView.builder(
                          itemCount: dsaList.length,
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final dsa = dsaList[index];
                            final bool isLatest = index == dsaList.length - 1;
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
                                                AppRoutes.addDsa,
                                                extra: {
                                                  "termSheetDetailsView":
                                                      termSheet,
                                                  "dsaData": dsa,
                                                },
                                              );
                                            },
                                          ),

                                          horizontalSpacing(),

                                          CustomIconButton.delete(
                                            onPressed: () {
                                              _showPopupToDeeleteTermSheetDirectSellingAgent(
                                                context,
                                                dsa,
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                      : SizedBox.shrink(),
                                  buildRowTitleValue(
                                    title: "Name Of Consultant",
                                    value: dsa.nameOfConsultant,
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Commission",
                                    value:
                                        "${dsa.commissionInPercentage.toString()} %",
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Amount (₹)",
                                    value: dsa.amount.toIndianCurrency(),
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Payment Date",
                                    value: formatDateTimeAsDDMMMYYYY(
                                      dsa.paymentDate,
                                    ),
                                  ),
                                  buildRowTitleValue(
                                    title: "Remark",
                                    value: dsa.remark,
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Last Modified By",
                                    value: dsa.createdBy,
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Last Modified Date",
                                    value: formatDate(dsa.createdDate),
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
