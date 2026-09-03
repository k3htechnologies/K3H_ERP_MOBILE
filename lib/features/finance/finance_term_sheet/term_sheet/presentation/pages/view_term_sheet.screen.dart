import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/disbursement/presentation/pages/disbursement.screen.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsa/presentation/pages/dsa.screen.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsra/presentation/pages/dsra.screen.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/repayment/presentation/pages/repayment.screen.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/sweep_ratio/presentation/pages/sweep_ratio.screen.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/presentation/cubit/term_sheet_cubit.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/presentation/pages/widgets/amount_container.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet_document/presentation/pages/term_sheet_document.screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ViewTermSheetScreen extends StatefulWidget {
  final TermSheetModel? termSheetModel;
  final TermSheetDetailsView? termSheetDetailsView;
  const ViewTermSheetScreen({
    super.key,
    this.termSheetModel,
    this.termSheetDetailsView,
  });

  @override
  State<ViewTermSheetScreen> createState() => _ViewTermSheetScreenState();
}

class _ViewTermSheetScreenState extends State<ViewTermSheetScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;
  late TermSheetCubit _termSheetCubit;

  bool get isApproved =>
      widget.termSheetModel?.approvalStatus.trim().toLowerCase() ==
          "approved" ||
      widget.termSheetModel?.approvalStatus.trim().toLowerCase() == "closed";

  List<String> get tabs {
    if (isApproved) {
      return [
        "Overview",
        "Disbursement",
        "Sweep Ratio",
        "DSA",
        "Repayment",
        "DSRA",
        "Document",
      ];
    }

    return ["Overview"];
  }

  @override
  void initState() {
    _termSheetCubit = context.read<TermSheetCubit>();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    Future.wait([
      _termSheetCubit.getTermSheetView(
        context,
        widget.termSheetModel!.projectId,
        widget.termSheetModel!.termSheetId,
      ),
      _termSheetCubit.getProjectWithCompany(
        context: context,
        projectId: widget.termSheetModel!.projectId,
      ),
    ]);

    super.initState();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      onTabChanged(context, _tabController.index);
    }
  }

  void onTabChanged(BuildContext context, int index) {
    if (index == 1) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Term Sheet",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChipStyleTabBar(
            controller: _tabController,
            style: ChipTabBarStyle.underline,
            tabs: tabs,
          ),
          BlocBuilder<TermSheetCubit, TermSheetState>(
            builder: (context, state) {
              if (state.isLoading == true) {
                return Expanded(child: Center(child: loader()));
              }

              if (state.termSheetViewList.isEmpty) {
                return Expanded(
                  child: Center(
                    child: noDataWidget(
                      message: "No Data Found",
                      iconSize: 160.0,
                    ),
                  ),
                );
              }
              return Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children:
                      isApproved
                          ? [
                            _overviewTab(context, state),
                            DisbursementScreen(
                              termSheetDetailsView:
                                  state.termSheetDetailsViewModel!,
                              termSheetModel: widget.termSheetModel!,
                            ),
                            SweepRatioScreen(
                              termSheetDetailsView:
                                  state.termSheetDetailsViewModel!,
                              termSheetModel: widget.termSheetModel!,
                            ),
                            DSAScreen(
                              termSheetDetailsView:
                                  state.termSheetDetailsViewModel!,
                              termSheetModel: widget.termSheetModel!,
                            ),
                            RepaymentScreen(
                              termSheetDetailsView:
                                  state.termSheetDetailsViewModel!,
                              termSheetModel: widget.termSheetModel!,
                            ),
                            DSRAScreen(
                              termSheetDetailsView:
                                  state.termSheetDetailsViewModel!,
                              termSheetModel: widget.termSheetModel!,
                            ),
                            TermSheetDocumentScreen(
                              termSheetDetailsView:
                                  state.termSheetDetailsViewModel!,
                              termSheetModel: widget.termSheetModel!,
                            ),
                          ]
                          : [_overviewTab(context, state)],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _overviewTab(BuildContext context, TermSheetState state) {
    final termSheetView = state.termSheetViewList.first;
    final hasDetails = termSheetView.termSheetDetailsData.isNotEmpty;

    final details =
        hasDetails ? termSheetView.termSheetDetailsData.first : null;
    // Main Term Sheet status
    final mainApprovalStatus =
        widget.termSheetModel?.approvalStatus.trim().toLowerCase();

    // Details/overall status
    final detailsApprovalStatus =
        widget.termSheetDetailsView?.approvalStatus.trim().toLowerCase() ?? "";

    // At least one bank approved
    final hasAtLeastOneBankApproved = termSheetView.termSheetDetailsData.any(
      (bank) => bank.approvalStatus.trim().toLowerCase() == "approved",
    );

    // Main term sheet finalized
    final isMainTermSheetApproved = mainApprovalStatus == "approved";

    // Term sheet closed
    final isClosed = detailsApprovalStatus == "closed";

    final showFinalizeApproval =
        hasAtLeastOneBankApproved && !isMainTermSheetApproved && !isClosed;

    double parseAmount(dynamic value) {
      if (value == null) return 0.0;

      final cleanedValue =
          value
              .toString()
              .replaceAll('₹', '')
              .replaceAll(',', '')
              .replaceAll(' ', '')
              .trim();

      return double.tryParse(cleanedValue) ?? 0.0;
    }

    final disbursedAmount = parseAmount(details?.totalDisbursedAmount);
    final repaymentAmount = parseAmount(details?.totalRepayLedgerAmount);
    final facilityAmount = parseAmount(details?.facilityAmount);

    final bool areAmountsEqual =
        disbursedAmount == repaymentAmount && repaymentAmount == facilityAmount;
    final bool showCloseButton = isApproved && !isClosed && areAmountsEqual;

    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.termSheetModel?.projectName,
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        TextSpan(
                          text: " > ",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        TextSpan(
                          text:
                              widget
                                      .termSheetModel!
                                      .nameOfInstitutionBankNbfc
                                      .isEmpty
                                  ? "-"
                                  : widget
                                      .termSheetModel!
                                      .nameOfInstitutionBankNbfc,
                          style: AppTextStyle.ts14SB(color: AppColor.grey),
                        ),
                        TextSpan(
                          text: " > ",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        TextSpan(
                          text: widget.termSheetModel?.approvalStatus,
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(),
                  SectionCard(
                    margin: 0,
                    icon: LucideIcons.building2,
                    iconContainerColor: AppColor.white,
                    iconColor: AppColor.primary,
                    headerBackgroundColor: AppColor.white,
                    title: widget.termSheetModel!.companyName,
                    titleTextStyle: AppTextStyle.ts14M(
                      color: AppColor.greyTitleAndValueColor,
                    ),
                    children: [
                      Divider(
                        color: AppColor.greyTitleAndValueColor.withValues(
                          alpha: 0.2,
                        ),
                        thickness: 1,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: buildRowWrapper(
                              child: buildColumnTitleValue(
                                title: "Firm Type",
                                value: state.companyByProject.first.firmsType,
                              ),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: buildRowWrapper(
                              child: buildColumnTitleValue(
                                title: "Contact Person",
                                value:
                                    state.companyByProject.first.contactPerson,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: buildRowWrapper(
                              child: buildColumnTitleValue(
                                title: "Mobile No.",
                                value:
                                    state.companyByProject.first.mobileNumber,
                                customValueWidget: CustomClickToContactText(
                                  value:
                                      state.companyByProject.first.mobileNumber,
                                  type: ContactType.phone,
                                ),
                              ),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: buildRowWrapper(
                              child: buildColumnTitleValue(
                                title: "E-mail Id",
                                value: state.companyByProject.first.emailId,
                                customValueWidget: CustomClickToContactText(
                                  value: state.companyByProject.first.emailId,
                                  type: ContactType.email,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: buildRowWrapper(
                              child: buildColumnTitleValue(
                                title: "PAN Number.",
                                value: state.companyByProject.first.panNumber,
                                customValueWidget: DocumentPreviewText(
                                  title: "PAN Number",
                                  text: state.companyByProject.first.panNumber,
                                  fileUrl:
                                      state.companyByProject.first.panCardURL,
                                ),
                              ),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: buildRowWrapper(
                              child: buildColumnTitleValue(
                                title: "GST Number",
                                value: state.companyByProject.first.gstNumber,
                                customValueWidget: DocumentPreviewText(
                                  title: "GST Number",
                                  text: state.companyByProject.first.gstNumber,
                                  fileUrl:
                                      state
                                          .companyByProject
                                          .first
                                          .gstCertificateURL,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: buildRowWrapper(
                              child: buildColumnTitleValue(
                                title: "CIN Number",
                                value: state.companyByProject.first.cinNumber,
                                customValueWidget: DocumentPreviewText(
                                  title: "CIN Number",
                                  text: state.companyByProject.first.cinNumber,
                                  fileUrl: state.companyByProject.first.cinURL,
                                ),
                              ),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: buildRowWrapper(
                              child: buildColumnTitleValue(
                                title: "TAN Number",
                                value: state.companyByProject.first.tanNumber,
                                customValueWidget: DocumentPreviewText(
                                  title: "TAN Number",
                                  text: state.companyByProject.first.tanNumber,
                                  fileUrl: state.companyByProject.first.tanURL,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ListView.builder(
                    itemCount:
                        state
                            .termSheetViewList
                            .first
                            .termSheetDetailsData
                            .length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final termSheetView =
                          state
                              .termSheetViewList
                              .first
                              .termSheetDetailsData[index];
                      return SectionCard(
                        margin: 0,
                        title: termSheetView.nameOfInstitutionBankNbfc,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: buildAmountWidget(
                                      context,
                                      bgColor: AppColor.white,
                                      title: "Facility (₹)",
                                      titleColor:
                                          AppColor.greyTitleAndValueColor,
                                      value:
                                          termSheetView.facilityAmount
                                              .toIndianCurrency(),
                                      valueColor: AppColor.black,
                                      borderColor: AppColor.black.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  Expanded(
                                    child: buildAmountWidget(
                                      context,
                                      bgColor: AppColor.white,
                                      title: "Disbursed (₹)",
                                      titleColor:
                                          AppColor.greyTitleAndValueColor,
                                      value:
                                          termSheetView.totalDisbursedAmount
                                              .toIndianCurrency(),
                                      valueColor: AppColor.black,
                                      borderColor: AppColor.black.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              verticalSpacing(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: buildAmountWidget(
                                      context,
                                      bgColor: AppColor.white,
                                      title: "Repaid (₹)",
                                      titleColor:
                                          AppColor.greyTitleAndValueColor,
                                      value:
                                          termSheetView.totalRepayLedgerAmount
                                              .toIndianCurrency(),
                                      valueColor: AppColor.black,
                                      borderColor: AppColor.black.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  Expanded(
                                    child: buildAmountWidget(
                                      context,
                                      bgColor: AppColor.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      title: "Outstanding (₹)",
                                      titleColor: AppColor.primary,
                                      value:
                                          termSheetView.facilityAmount
                                              .toIndianCurrency(),
                                      valueColor: AppColor.primary,
                                      borderColor: AppColor.black.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              verticalSpacing(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: buildAmountWidget(
                                      context,
                                      bgColor: AppColor.white,
                                      title: "Rate Of Interest",
                                      titleColor:
                                          AppColor.greyTitleAndValueColor,
                                      value:
                                          "${termSheetView.rateOfInterestInPercentage.toString()} %",
                                      valueColor: AppColor.black,
                                      borderColor: AppColor.black.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  Expanded(
                                    child: buildAmountWidget(
                                      context,
                                      bgColor: AppColor.white,
                                      title: "Loan Tenure",
                                      titleColor:
                                          AppColor.greyTitleAndValueColor,
                                      value:
                                          "${termSheetView.loanTenureInMonth.toString()} months",
                                      valueColor: AppColor.black,
                                      borderColor: AppColor.black.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          buildRowTitleValue(
                            title: "Loan Taken By",
                            value: termSheetView.loanTakenBy,
                            customValueWidget: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    termSheetView.loanTakenBy.isEmpty
                                        ? AppColor.white
                                        : AppColor.lightBlue2,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                termSheetView.loanTakenBy.isEmpty
                                    ? "-"
                                    : termSheetView.loanTakenBy,
                                style: AppTextStyle.ts12SB(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Type",
                            value: termSheetView.type,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Term Sheet Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              termSheetView.termSheetDate,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Term Sheet Document",
                            value: "View",
                            customValueWidget: DocumentPreviewText(
                              title: "Term Sheet Document",
                              text: "View",
                              fileUrl: termSheetView.termSheetUrl,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Processing Fees (%)",
                            value:
                                "${termSheetView.processingFeesInPercentage.toString()} %",
                          ),
                          buildRowTitleValue(
                            title: "Legal & Documentation (₹)",
                            value:
                                termSheetView.legalAndDocumentationFees
                                    .toIndianCurrency(),
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Monotorium Period (Months)",
                            value:
                                termSheetView.monotoriumPeriodInMonth
                                    .toString(),
                          ),
                          buildRowTitleValue(
                            title: "Minimum Selling Price (MSP) (₹)",
                            value:
                                termSheetView.minimumSellingPrice
                                    .toIndianCurrency(),
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Sanction Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              termSheetView.sanctionDate,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Loan Start Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              termSheetView.loanStartDate,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Loan End Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              termSheetView.loanEndDate,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "EMI",
                            value: termSheetView.emiAmount.toIndianCurrency(),
                          ),
                          buildRowTitleValue(
                            title: "Other Important Terms If Any",
                            value: termSheetView.otherImportantTermsIfAny,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Remark",
                            value: termSheetView.remark,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Created By",
                            value: termSheetView.createdBy,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Created By",
                            value: formatDate(termSheetView.createdDate),
                            singleLine: false,
                          ),
                          ApproveRejectWidget(
                            showApproval: termSheetView.isApproval,
                            actionTitle:
                                termSheetView.approvalStatus.isEmpty
                                    ? "Pending"
                                    : termSheetView.approvalStatus,
                            onApprove: (onApprove) async {
                              final isSuccess = await context
                                  .read<UtilsCubit>()
                                  .updateModulesWorkflowApproval(
                                    context: context,
                                    moduleName: "TERM SHEET APPROVAL",
                                    id: termSheetView.termSheetDetailsId,
                                    projectId: termSheetView.projectId,
                                    isApproved: true,
                                    remark: onApprove.trim(),
                                  );
                              if (context.mounted && isSuccess) {
                                await _termSheetCubit.getTermSheetView(
                                  context,
                                  termSheetView.projectId,
                                  termSheetView.termSheetId,
                                );
                              }
                            },
                            onReject: (onReject) async {
                              final isSuccess = await context
                                  .read<UtilsCubit>()
                                  .updateModulesWorkflowApproval(
                                    context: context,
                                    isApproved: false,
                                    moduleName: "TERM SHEET APPROVAL",
                                    id: termSheetView.termSheetDetailsId,
                                    projectId: termSheetView.projectId,
                                    remark: onReject.trim(),
                                  );

                              if (context.mounted && isSuccess) {
                                await _termSheetCubit.getTermSheetView(
                                  context,
                                  termSheetView.projectId,
                                  termSheetView.termSheetId,
                                );
                              }
                            },
                            onThirdTap: () async {
                              final approvalLogHistoryList = await context
                                  .read<UtilsCubit>()
                                  .getApprovalLogHistory(
                                    context: context,
                                    projectId: termSheetView.projectId,
                                    id: termSheetView.termSheetDetailsId,
                                    moduleName: "TERM SHEET APPROVAL",
                                  );
                              if (context.mounted) {
                                goRouter.pushNamed(
                                  AppRoutes.approvalLogHistory,
                                  queryParameters: {
                                    "title": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        "TERM SHEET APPROVAL",
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
                            popupTitle: "TERM SHEET APPROVAL",
                          ),
                        ],
                      );
                    },
                  ),
                  if ((termSheetView.closingRemark.isNotEmpty) &&
                      (termSheetView.closingDate != null))
                    SectionCard(
                      margin: 0,
                      headerBackgroundColor: AppColor.grey30,
                      title: 'Closing Details',
                      titleTextColor: AppColor.black,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: buildRowWrapper(
                                child: buildColumnTitleValue(
                                  title: "Closing Remark",
                                  value: termSheetView.closingRemark,
                                ),
                              ),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: buildRowWrapper(
                                child: buildColumnTitleValue(
                                  title: "Closing Date",
                                  value: formatDate(termSheetView.closingDate),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  showFinalizeApproval
                      ? Container(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          bottom: 16.0,
                          top: 16.0,
                        ),
                        decoration: commonCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: AppColor.brownYellowText.withValues(
                                  alpha: 0.12,
                                ),
                                border: Border.all(
                                  width: 1,
                                  color: AppColor.brownYellowText,
                                ),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Final Approval Warning: ",
                                      style: AppTextStyle.ts14SB(
                                        color: AppColor.brownYellowText,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "If any one ",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.brownYellowText,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Name of Institution / Bank / NBFC",
                                      style: AppTextStyle.ts14SB(
                                        color: AppColor.brownYellowText,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " is approved, clicking ",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.brownYellowText,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Final Approval ",
                                      style: AppTextStyle.ts14SB(
                                        color: AppColor.brownYellowText,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "will remove all other pending entries.",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.brownYellowText,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          " Only the approved Institution / Bank / NBFC will be retained as a separate entry.",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.brownYellowText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            verticalSpacing(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomButton(
                                  text: "Finalize Approval",
                                  onPressed: () {
                                    _termSheetCubit.finalizeTermSheetApproval(
                                      context,
                                      termSheetId: termSheetView.termSheetId,
                                      projectId: termSheetView.projectId,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
          if (showCloseButton &&
              (termSheetView.closingRemark.isEmpty) &&
              (termSheetView.closingDate == null))
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: "Closed",
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.closeTermSheet,
                        extra: {
                          "termSheetId": termSheetView.termSheetId,
                          "projectId": termSheetView.projectId,
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
