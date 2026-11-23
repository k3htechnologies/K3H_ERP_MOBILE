import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_report/client_loan_report/presentation/cubit/client_loan_report_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ClientLoanReportScreen extends StatefulWidget {
  const ClientLoanReportScreen({super.key});

  @override
  State<ClientLoanReportScreen> createState() => _ClientLoanReportScreenState();
}

class _ClientLoanReportScreenState extends State<ClientLoanReportScreen> {
  // CUBIT
  late ClientLoanReportCubit _clientLoanReportCubit;
  // TEXT EDITORS
  late TextEditingController _searchC, _filterByApplicantNameC;

  late ProjectModel _project;

  late AuthorizationModel _routeAuthorizationModel;

  // FILTER COUNT
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _clientLoanReportCubit = context.read<ClientLoanReportCubit>();
    _initializeControllers();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.clientLoanReport] ??
        AuthorizationModel();
    _project = getProject();
    _clientLoanReportCubit.getClientLoanReportList(
      context,
      pageNumber: 1,
      projectId: _project.projectId,
    );
  }

  @override
  void dispose() {
    _searchC.dispose();
    _filterByApplicantNameC.dispose();
    _filterCount.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _searchC = TextEditingController();
    _filterByApplicantNameC = TextEditingController();
  }

  Future<void> _showBottomSheetToFilterClientLoanReport(
    BuildContext context,
  ) async {
    final state = _clientLoanReportCubit.state;
    String? selectedDirection =
        state.currentSortColumn == "Applicant Name"
            ? state.currentSortDirection
            : null;
    _searchC.text = state.searchText;
    _filterByApplicantNameC.text = state.searchText;

    final String initialName = _searchC.text;
    final String initialEmployeeName = _filterByApplicantNameC.text;

    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialEmployeeName) ||
            (_filterByApplicantNameC.text.trim() != initialName) ||
            (selectedDirection != initialDirection);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Client Loan Report",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Applicant Name", style: AppTextStyle.ts14M()),
                verticalSpacing(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => selectDirection("ASC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "ASC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("A-Z", style: AppTextStyle.ts12R()),
                      ),
                    ),
                    horizontalSpacing(),
                    GestureDetector(
                      onTap: () => selectDirection("DESC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "DESC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(height: 20),

                CustomTextField(
                  title: "Applicant Name",
                  hint: "Enter Applicant Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _searchC.clear();
        _filterByApplicantNameC.clear();

        _clientLoanReportCubit.applyDarAllocationFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        _clientLoanReportCubit.applyDarAllocationFilterAndSort(
          context: context,
          applicantName: _searchC.text.trim(),

          sortColumn: selectedDirection != null ? "Applicant Name" : null,
          sortDirection: selectedDirection,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterByApplicantNameC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientLoanReportCubit, ClientLoanReportState>(
      listener: (context, state) {
        _filterCount.value = _clientLoanReportCubit
            .updateDarAllocationFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Client Loan Report",
          authorization: _routeAuthorizationModel,
          onProjectChangeCallback: (value) {
            _project = value;
            _searchC.clear();
            _filterByApplicantNameC.clear();
            _clientLoanReportCubit.resetAndFetchForProject(
              context,
              _project.projectId,
            );
            _clientLoanReportCubit.getClientLoanReportList(
              context,
              projectId: _project.projectId,
              pageNumber: 1,
            );
          },
          searchHintText: "Search By Applicant Name",
          onSearchSubmit: (value) {
            _clientLoanReportCubit.searchClientLoanReport(
              context,
              value,
              _project.projectId,
            );
          },
          textController: _searchC,
          onExportCallback: (value) {
            _clientLoanReportCubit.exportExcelPdf(context, value);
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterClientLoanReport(context);
          },
          filterCountNotifier: _filterCount,
        ),
        body: BlocBuilder<ClientLoanReportCubit, ClientLoanReportState>(
          builder: (context, state) {
            if (state.isLoading == true &&
                (state.clientLoanReportList).isEmpty) {
              return Center(child: loader());
            }
            if (state.clientLoanReportList.isEmpty) {
              return Center(
                child: noDataWidget(message: "No Client Loan Report Found"),
              );
            }
            return ListView.builder(
              itemCount: state.clientLoanReportList.length,
              padding: EdgeInsets.all(20.sp),
              itemBuilder: (context, index) {
                final clienLoanReport = state.clientLoanReportList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 20.sp),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.sp,
                    vertical: 16.sp,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 4.sp, color: AppColor.primary),
                    ),
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              clienLoanReport.applicantName,
                              style: AppTextStyle.ts16M(
                                color: AppColor.darkBlue900,
                              ),
                            ),
                          ),
                          clientLoanReportStatusWidget(
                            clienLoanReport.bankStatusClosedActive,
                          ),
                        ],
                      ),
                      verticalSpacing(height: 12.sp),
                      Divider(color: AppColor.dividerColor),
                      verticalSpacing(height: 12.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10.sp),
                              decoration: BoxDecoration(
                                color: AppColor.lightBlue.withValues(
                                  alpha: 0.60,
                                ),
                                borderRadius: BorderRadius.circular(12.sp),
                                border: Border.all(
                                  width: 1.sp,
                                  color: AppColor.primary.withValues(
                                    alpha: 0.20,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sanction Amount",
                                    style: AppTextStyle.ts12SB(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                  Text(
                                    clienLoanReport.loanSanctionAmount
                                        .toIndianCurrency(),
                                    style: AppTextStyle.ts14SB(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10.sp),
                              decoration: BoxDecoration(
                                color: Color(0xffF8FAFC),
                                borderRadius: BorderRadius.circular(12.sp),
                                border: Border.all(
                                  width: 1.sp,
                                  color: AppColor.dividerColor.withValues(
                                    alpha: 0.80,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Agreement Value",
                                    style: AppTextStyle.ts12SB(
                                      color: Color(0xff64748B),
                                    ),
                                  ),
                                  Text(
                                    clienLoanReport.agreementValue
                                        .toIndianCurrency(),
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.darkBlue900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      verticalSpacing(height: 12.sp),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10.sp),
                              decoration: BoxDecoration(
                                color: Color(0xffF8FAFC),
                                borderRadius: BorderRadius.circular(12.sp),
                                border: Border.all(
                                  width: 1.sp,
                                  color: AppColor.dividerColor.withValues(
                                    alpha: 0.80,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sanction date",
                                    style: AppTextStyle.ts12SB(
                                      color: Color(0xff64748B),
                                    ),
                                  ),
                                  Text(
                                    formatDateTimeAsDDMMMYYYY(
                                      clienLoanReport.loanSanctionDate,
                                    ),
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.darkBlue900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10.sp),
                              decoration: BoxDecoration(
                                color: Color(0xffF8FAFC),
                                borderRadius: BorderRadius.circular(12.sp),
                                border: Border.all(
                                  width: 1.sp,
                                  color: AppColor.dividerColor.withValues(
                                    alpha: 0.80,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Applicant Number",
                                    style: AppTextStyle.ts12SB(
                                      color: Color(0xff64748B),
                                    ),
                                  ),
                                  Text(
                                    "${clienLoanReport.applicantMobileNumberCountryCode} ${clienLoanReport.applicantMobileNumber}",
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.darkBlue900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      verticalSpacing(height: 12.sp),
                      Divider(color: AppColor.dividerColor),
                      // verticalSpacing(height: 12.sp),
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          iconColor: AppColor.primary,
                          collapsedIconColor: AppColor.primary,
                          title: Text(
                            "View Details",
                            style: AppTextStyle.ts12M(color: AppColor.primary),
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 16.sp),
                                  padding: EdgeInsets.all(12.sp),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.sp),
                                    border: Border.all(
                                      width: 0.5.sp,
                                      color: Color(0xff94A3B8),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Unit & Property Details",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.darkBlue900,
                                        ),
                                      ),
                                      Divider(color: AppColor.dividerColor),
                                      verticalSpacing(height: 12.sp),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildColumnTitleValue(
                                            title: "Building & Wing",
                                            value:
                                                "${clienLoanReport.buildingNumber} (${clienLoanReport.wing.isEmpty ? "-" : clienLoanReport.wing})",
                                          ),
                                          horizontalSpacing(),
                                          buildColumnTitleValue(
                                            title: "Floor & Unit",
                                            value:
                                                "${clienLoanReport.floor} • ${clienLoanReport.flat}",
                                          ),
                                        ],
                                      ),
                                      verticalSpacing(height: 9.sp),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildColumnTitleValue(
                                            title: "RERA Carpet Area",
                                            value:
                                                "${clienLoanReport.reraCarpetAreaSqFt.toString()} SqFt",
                                          ),
                                          horizontalSpacing(),
                                          buildColumnTitleValue(
                                            title: "Configuration",
                                            value: "",
                                            customValueWidget: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 2.sp,
                                                horizontal: 8.sp,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0xffF1F5F9),
                                                border: Border.all(
                                                  width: 1.sp,
                                                  color: Color(0xffE2E8F0),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6.sp),
                                              ),
                                              child: Text(
                                                "${clienLoanReport.flatConfiguration} • ${clienLoanReport.flatType}",
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(12.sp),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.sp),
                                    border: Border.all(
                                      width: 0.5.sp,
                                      color: Color(0xff94A3B8),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Bank Loan Details",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.darkBlue900,
                                        ),
                                      ),
                                      Divider(color: AppColor.dividerColor),
                                      verticalSpacing(height: 12.sp),
                                      buildColumnTitleValue(
                                        title: "Bank Name",
                                        value: clienLoanReport.bankName,
                                        removeExpanded: true,
                                      ),
                                      verticalSpacing(height: 9.sp),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildColumnTitleValue(
                                            title: "Loan Account No.",
                                            value:
                                                clienLoanReport
                                                    .loanAccountNumber,
                                            customValueWidget: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 2.sp,
                                                horizontal: 8.sp,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0xffF1F5F9),
                                                border: Border.all(
                                                  width: 1.sp,
                                                  color: Color(0xffE2E8F0),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6.sp),
                                              ),
                                              child: Text(
                                                clienLoanReport
                                                    .loanAccountNumber,
                                              ),
                                            ),
                                          ),
                                          horizontalSpacing(),
                                          buildColumnTitleValue(
                                            title: "Branch Name",
                                            value:
                                                clienLoanReport.bankBranchName,
                                          ),
                                        ],
                                      ),
                                      verticalSpacing(height: 12.sp),
                                      buildColumnTitleValue(
                                        title: "Bank Address",
                                        value: clienLoanReport.address,
                                        removeExpanded: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // CustomExpandableCard(
                      //   header: Text(
                      //     "View Details",
                      //     style: AppTextStyle.ts12M(color: AppColor.primary),
                      //   ),
                      //   body: Column(),
                      // ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
