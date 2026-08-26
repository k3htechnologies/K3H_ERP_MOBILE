import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/finance/sweep_ratio/presentation/cubit/sweep_ratio_cubit.dart';
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

class SweepRatioScreen extends StatefulWidget {
  final TermSheetModel termSheetModel;
  final TermSheetDetailsView termSheetDetailsView;
  const SweepRatioScreen({
    super.key,
    required this.termSheetDetailsView,
    required this.termSheetModel,
  });

  @override
  State<SweepRatioScreen> createState() => _SweepRatioScreenState();
}

class _SweepRatioScreenState extends State<SweepRatioScreen> {
  late SweepRatioCubit _sweepRatioCubit;

  @override
  void initState() {
    _sweepRatioCubit = context.read<SweepRatioCubit>();

    _sweepRatioCubit.getTermSheetView(
      context,
      widget.termSheetDetailsView.projectId,
      widget.termSheetDetailsView.termSheetId,
    );
    super.initState();
  }

  Future<void> _showPopupToDeleteTermSheetSweepRatioDetails(
    BuildContext context,
    TermSheetSweepRatioDetailsData sweepRatio,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Term Sheet Sweep Ratio ?',
      'Deleting this Term Sheet Sweep Ratio will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _sweepRatioCubit.deleteSweepRatioDetails(
        context: context,
        termSheetSweepRatioDetailsId: sweepRatio.termSheetSweepRatioDetailsId,
        termSheetId: sweepRatio.termSheetId,
        termSheetDetailsId: sweepRatio.termSheetDetailsId,
        projectId: sweepRatio.projectId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SweepRatioCubit, SweepRatioState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return Center(child: loader());
        }
        final termSheet =
            state.termSheetDetailsViewModel ?? widget.termSheetDetailsView;
        final sweepratioList = termSheet.termSheetSweepRatioDetailsData;

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
                  Text("Sweep Ratio Details", style: AppTextStyle.ts14SB()),
                  horizontalSpacing(),
                  CustomButton(
                    text: "Add",
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addSweepRatio,
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
                    sweepratioList.isEmpty
                        ? Center(
                          child: noDataWidget(
                            message: "No Sweep Ratio Details Found",
                            iconSize: 160.0,
                          ),
                        )
                        : ListView.builder(
                          itemCount: sweepratioList.length,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final sweepRatio = sweepratioList[index];
                            final bool isLatest =
                                index == sweepratioList.length - 1;
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
                                                AppRoutes.addSweepRatio,
                                                extra: {
                                                  "isEdit": true,
                                                  "termSheetDetailsView":
                                                      termSheet,
                                                  "sweepRatioData": sweepRatio,
                                                },
                                              );
                                            },
                                          ),

                                          horizontalSpacing(),

                                          CustomIconButton.delete(
                                            onPressed: () {
                                              _showPopupToDeleteTermSheetSweepRatioDetails(
                                                context,
                                                sweepRatio,
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                      : SizedBox.shrink(),

                                  buildRowTitleValue(
                                    title: "Own (%)",
                                    value:
                                        sweepRatio.ownSweepRatioInPercentage
                                            .toString(),
                                  ),

                                  buildRowTitleValue(
                                    title: "Lender (%)",
                                    value:
                                        sweepRatio.lenderSweepRatioInPercentage
                                            .toString(),
                                  ),
                                  buildRowTitleValue(
                                    title: "Date",
                                    value: formatDateTimeAsDDMMMYYYY(
                                      sweepRatio.date,
                                    ),
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Remark",
                                    value: sweepRatio.remark,
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Last Modified By",
                                    value: sweepRatio.createdBy,
                                    singleLine: false,
                                  ),

                                  buildRowTitleValue(
                                    title: "Last Modified Date",
                                    value: formatDate(sweepRatio.createdDate),
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
