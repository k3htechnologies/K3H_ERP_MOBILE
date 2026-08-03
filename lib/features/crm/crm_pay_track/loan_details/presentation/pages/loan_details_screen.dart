import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/cubit/files_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/cubit/loan_details_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/cubit/loan_details_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LoanDetailsScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final String? approvalStatus;
  final String? bookingApprovalStatus;
  const LoanDetailsScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    required this.approvalStatus,
    required this.bookingApprovalStatus,
  });

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen>
    with SingleTickerProviderStateMixin {
  late FilesCubit _filesCubit;
  late TabController _tabController;
  late LoanDetailsCubit _loanDetailsCubit;
  late ValueNotifier<Map<int, bool>> closeAccountNotifier;
  late AuthorizationModel _bankLoanAuthorization;

  @override
  void initState() {
    super.initState();
    _bankLoanAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.bankLoans] ??
        AuthorizationModel();
    closeAccountNotifier = ValueNotifier({});
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loanDetailsCubit = context.read<LoanDetailsCubit>();
    _filesCubit = context.read<FilesCubit>();
    _loanDetailsCubit.getBankLoanDetailsList(
      context,
      50,
      1,
      widget.projectId,
      widget.bookingId,
    );
    _filesCubit.getFilesList(
      context: context,
      pageNumber: 1,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
      fileType: "",
    );
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() async {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          await _loanDetailsCubit.getBankLoanDetailsList(
            context,
            50,
            1,
            widget.projectId,
            widget.bookingId,
          );
          break;

        case 1:
          break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    closeAccountNotifier.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpacing(),
        ChipStyleTabBar(
          controller: _tabController,
          tabs: ['Details', 'Documents'],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [_buildDetailsTab(), _buildDocumentsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    return BlocBuilder<LoanDetailsCubit, LoanDetailsState>(
      builder: (context, state) {
        final hasActiveBank = state.bankDetailsList.any(
          (e) => e.bankStatusClosedActive.toLowerCase() == "active",
        );
        final bookingStatus = widget.bookingApprovalStatus?.toUpperCase() ?? "";

        final canShowAddBankButton =
            !hasActiveBank &&
            _bankLoanAuthorization.isAction &&
            widget.approvalStatus?.toUpperCase() == "APPROVED" &&
            !["CANCEL", "REFUND"].contains(bookingStatus);
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!hasActiveBank)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: commonCardDecoration(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "No Active Bank Found",
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                      horizontalSpacing(),
                      if (canShowAddBankButton)
                        Align(
                          alignment: Alignment.centerRight,
                          child: CustomButton(
                            text: "Add Bank Details ",
                            isDisable: !_bankLoanAuthorization.isAction,
                            onPressed: () {
                              context
                                  .read<PaymentCubit>()
                                  .getPaymentScheduleList(
                                    context,
                                    widget.projectId,
                                    widget.bookingId,
                                  );

                              goRouter.pushNamed(
                                AppRoutes.addActiveBank,
                                queryParameters: {
                                  'bookingId': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      widget.bookingId.toString(),
                                    ),
                                  ),

                                  'projectId': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      widget.projectId.toString(),
                                    ),
                                  ),
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.bankDetailsList.length,
                  shrinkWrap: false,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final bankDetail = state.bankDetailsList[index];

                    final status =
                        bankDetail.bankStatusClosedActive.toLowerCase();

                    final title =
                        status == "active"
                            ? "Active Bank"
                            : status == "closed"
                            ? "Closed Bank"
                            : bankDetail.bankStatusClosedActive;
                    final bookingStatus =
                        widget.bookingApprovalStatus?.toUpperCase() ?? "";

                    final canShowAccountOpenOrClose =
                        _bankLoanAuthorization.isAction &&
                        widget.approvalStatus?.toUpperCase() == "APPROVED" &&
                        !["CANCEL", "REFUND"].contains(bookingStatus) &&
                        bankDetail.noOfBankDocument > 0 &&
                        status != "closed";
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      decoration: commonCardDecoration(),
                      child: Material(
                        color: Colors.transparent,
                        child: ExpansionTile(
                          childrenPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          iconColor: AppColor.black,
                          collapsedIconColor: AppColor.black,
                          shape: const Border(),
                          collapsedShape: const Border(),
                          title:
                              status == 'active'
                                  ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: AppTextStyle.ts14M(),
                                        ),
                                      ),
                                      bankDetail.noOfBankDocument == 0
                                          ? SizedBox.shrink()
                                          : horizontalSpacing(),
                                      bankDetail.noOfBankDocument == 0
                                          ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              CustomIconButton.edit(
                                                onPressed: () {
                                                  goRouter.pushNamed(
                                                    AppRoutes.addActiveBank,
                                                    queryParameters: {
                                                      'bookingId':
                                                          Uri.encodeComponent(
                                                            EncryptionManager.encryptData(
                                                              widget.bookingId
                                                                  .toString(),
                                                            ),
                                                          ),

                                                      'projectId':
                                                          Uri.encodeComponent(
                                                            EncryptionManager.encryptData(
                                                              widget.projectId
                                                                  .toString(),
                                                            ),
                                                          ),

                                                      'document':
                                                          Uri.encodeComponent(
                                                            EncryptionManager.encryptData(
                                                              jsonEncode(
                                                                bankDetail
                                                                    .toJson(),
                                                              ),
                                                            ),
                                                          ),

                                                      'index': index.toString(),
                                                    },
                                                  );
                                                },
                                              ),
                                              horizontalSpacing(),
                                              CustomIconButton.delete(
                                                onPressed: () {
                                                  _loanDetailsCubit
                                                      .deleteBankDetails(
                                                        index,
                                                        bankDetail
                                                            .bookingLoanDetailsId,
                                                        bankDetail.uniquekey,
                                                        widget.projectId,
                                                        widget.bookingId,
                                                        context,
                                                      );
                                                },
                                              ),
                                            ],
                                          )
                                          : SizedBox.shrink(),
                                    ],
                                  )
                                  : Text(title, style: AppTextStyle.ts14M()),
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    status == 'active'
                                        ? AppColor.lightGreyBackground
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  width: 0.8,
                                  color:
                                      status == 'active'
                                          ? AppColor.black.withValues(
                                            alpha: 0.1,
                                          )
                                          : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 10.0,
                                children: [
                                  buildColumnTitleValueNormal(
                                    title: "Bank Name",
                                    value: bankDetail.bankName,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: buildColumnTitleValueNormal(
                                          title: "Branch Name",
                                          value: bankDetail.bankBranchName,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: buildColumnTitleValueNormal(
                                          title: "Account Number",
                                          value: bankDetail.loanAccountNumber,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: buildColumnTitleValueNormal(
                                          title: "Loan Sanction Amount",
                                          value:
                                              bankDetail.loanSanctionAmount
                                                  .toIndianCurrency(),
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: buildColumnTitleValueNormal(
                                          title: "Loan Sanction Date",
                                          value: formatDateTimeAsDDMMMYYYY(
                                            bankDetail.loanSanctionDate!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: buildColumnTitleValueNormal(
                                          title: "Address",
                                          value: bankDetail.address,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: buildColumnTitleValueNormal(
                                          title: "No of Bank Documents",
                                          value:
                                              bankDetail.noOfBankDocument
                                                  .toString(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: buildColumnTitleValueNormal(
                                          title: "Created By",
                                          value: bankDetail.createdBy,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: buildColumnTitleValueNormal(
                                          title: "Created Date",
                                          value: formatDate(
                                            bankDetail.createdDate,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: buildColumnTitleValueNormal(
                                          title: "Modified By",
                                          value: bankDetail.modifiedBy,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: buildColumnTitleValueNormal(
                                          title: "Modified Date",
                                          value:
                                              bankDetail.modifiedDate != null
                                                  ? formatDate(
                                                    bankDetail.modifiedDate!,
                                                  )
                                                  : '-',
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (canShowAccountOpenOrClose)
                                    ValueListenableBuilder<Map<int, bool>>(
                                      valueListenable: closeAccountNotifier,
                                      builder: (context, selectedMap, child) {
                                        final isChecked =
                                            selectedMap[bankDetail
                                                .bookingLoanDetailsId] ??
                                            false;

                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: CustomCheckBox(
                                                isSelected: isChecked,
                                                title:
                                                    "Do you want to close this account",
                                                onChanged: (value) {
                                                  final updatedMap =
                                                      Map<int, bool>.from(
                                                        selectedMap,
                                                      );

                                                  updatedMap[bankDetail
                                                          .bookingLoanDetailsId] =
                                                      !isChecked;

                                                  closeAccountNotifier.value =
                                                      updatedMap;
                                                },
                                              ),
                                            ),

                                            if (isChecked)
                                              CustomButton(
                                                text: "Close Account",
                                                onPressed: () {
                                                  _loanDetailsCubit.closeAccount(
                                                    context: context,
                                                    bookingLoanDetailsId:
                                                        bankDetail
                                                            .bookingLoanDetailsId,
                                                    uniqueKey:
                                                        bankDetail.uniquekey,
                                                    projectId: widget.projectId,
                                                    bookingId: widget.bookingId,
                                                  );
                                                },
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildDocumentsTab() {
    return BlocBuilder<LoanDetailsCubit, LoanDetailsState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.bankDetailsList.isEmpty) {
          return Center(
            child: noDataWidget(message: "No Bank Loan Found", iconSize: 180),
          );
        }
        final isApproved = widget.approvalStatus?.toLowerCase() == "approved";
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.bankDetailsList.length,
          itemBuilder: (context, index) {
            final document = state.bankDetailsList[index];
            return Container(
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.only(bottom: 10.0),
              decoration: commonCardDecoration(),
              child: Column(
                spacing: 10.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          document.bankName,
                          style: AppTextStyle.ts14M(),
                        ),
                      ),
                      horizontalSpacing(),
                      document.bankStatusClosedActive.toLowerCase() == "closed"
                          ? SizedBox.shrink()
                          : CustomIconButton.add(
                            onPressed: () {
                              goRouter.pushNamed(
                                AppRoutes.addBankLoanDocument,
                                queryParameters: {
                                  'bookingId': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      widget.bookingId.toString(),
                                    ),
                                  ),

                                  'projectId': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      widget.projectId.toString(),
                                    ),
                                  ),

                                  'bookingLoanDetailsId': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      document.bookingLoanDetailsId.toString(),
                                    ),
                                  ),
                                },
                              );
                            },
                          ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Account Number",
                          value: document.loanAccountNumber.toString(),
                        ),
                      ),
                      horizontalSpacing(width: 20.0),
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Loan Sanction Amount",
                          value: document.loanSanctionAmount.toIndianCurrency(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Status",
                          value: document.bankStatusClosedActive.toString(),
                        ),
                      ),
                      horizontalSpacing(width: 20.0),
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Document Count",
                          value: document.noOfBankDocument.toString(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Branch Name",
                          value: document.bankBranchName,
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 6.0),
                    childrenPadding: EdgeInsets.zero,
                    backgroundColor: AppColor.white,
                    collapsedBackgroundColor: AppColor.white,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    iconColor: AppColor.black,
                    collapsedIconColor: AppColor.black,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    onExpansionChanged: (expanded) async {
                      if (expanded) {
                        await _loanDetailsCubit.getBankDocumentList(
                          context: context,
                          pageNumber: 1,
                          projectId: widget.projectId,
                          bookingId: widget.bookingId,
                          bookingLoanDetailsId: document.bookingLoanDetailsId,
                        );
                      }
                    },
                    title: Text("View Documents", style: AppTextStyle.ts14M()),
                    children: [
                      Builder(
                        builder: (context) {
                          final docs =
                              state.bankDocumentMap[document
                                  .bookingLoanDetailsId] ??
                              [];
                          if (docs.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Center(
                                child: noDataWidget(
                                  message: "No Data Found",
                                  iconSize: 180.0,
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount:
                                (state.bankDocumentMap[document
                                            .bookingLoanDetailsId] ??
                                        [])
                                    .length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, docIndex) {
                              final file =
                                  state.bankDocumentMap[document
                                      .bookingLoanDetailsId]![docIndex];

                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 16.0,
                                ),
                                margin: EdgeInsets.symmetric(vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColor.primary.withValues(
                                      alpha: 0.6,
                                    ),
                                    width: .5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnValue(
                                            value: file.fileName,
                                            customValueWidget: DocumentPreviewText(
                                              title: file.fileName,
                                              text: file.fileName,
                                              fileUrl:
                                                  file.payTrackBookingFilesUrl,
                                            ),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomIconButton.edit(
                                              isDisabled:
                                                  document.bankStatusClosedActive
                                                          .toLowerCase() ==
                                                      "closed" ||
                                                  !isApproved,
                                              onPressed: () {
                                                goRouter.pushNamed(
                                                  AppRoutes.addBankLoanDocument,
                                                  queryParameters: {
                                                    'bookingId':
                                                        Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            widget.bookingId
                                                                .toString(),
                                                          ),
                                                        ),
                                                    'projectId':
                                                        Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            widget.projectId
                                                                .toString(),
                                                          ),
                                                        ),
                                                    'document': Uri.encodeComponent(
                                                      EncryptionManager.encryptData(
                                                        jsonEncode(
                                                          file.toJson(),
                                                        ),
                                                      ),
                                                    ),
                                                    'index':
                                                        docIndex.toString(),
                                                  },
                                                );
                                              },
                                            ),
                                            horizontalSpacing(width: 12),
                                            CustomIconButton.delete(
                                              isDisabled:
                                                  document.bankStatusClosedActive
                                                          .toLowerCase() ==
                                                      "closed" ||
                                                  !isApproved,
                                              onPressed: () {
                                                _loanDetailsCubit
                                                    .deleteBankDocument(
                                                      index,
                                                      document
                                                          .bookingLoanDetailsId,
                                                      file,
                                                      context,
                                                    );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    verticalSpacing(),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Last Modified By",
                                            value:
                                                file.modifiedBy.trim().isEmpty
                                                    ? file.createdBy
                                                    : file.modifiedBy,
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Last Modified Date",
                                            value: formatDate(
                                              file.modifiedDate ??
                                                  file.createdDate,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildColumnValue({
    required String value,
    TextStyle? valueTextStyle,
    Widget? customValueWidget,
  }) {
    return customValueWidget ??
        Text(
          value.isEmpty ? "-" : value,
          style: valueTextStyle ?? AppTextStyle.ts14M(color: AppColor.black),
        );
  }
}
