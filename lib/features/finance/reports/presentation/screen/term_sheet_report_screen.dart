import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/reports/presentation/cubit/term_sheet_report_cubit.dart';
import 'package:k3h_erp_app/features/finance/reports/presentation/cubit/term_sheet_report_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/expansion_tile/custom_expansion_tile.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TermSheetReportScreen extends StatefulWidget {
  const TermSheetReportScreen({super.key});
  @override
  State<TermSheetReportScreen> createState() => _TermSheetReportScreenState();
}

class _TermSheetReportScreenState extends State<TermSheetReportScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late TermSheetReportCubit _termSheetReportCubit;
  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;
  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _filterCompanyName,
      _filterInstitutionName;
  final ValueNotifier<Map<String, dynamic>?> _selectedStatusNotifier =
      ValueNotifier(null);
  final ValueNotifier<int> _filterCount = ValueNotifier(0);
  @override
  void initState() {
    super.initState();
    _termSheetReportCubit = context.read<TermSheetReportCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.termSheetReport]!;
    _initializeTextEditingController();
    _onScroll();
    _termSheetReportCubit.getTermSheetReportList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _filterCompanyName.dispose();
    _filterInstitutionName.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _filterCount.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterCompanyName = TextEditingController();
    _filterInstitutionName = TextEditingController();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_termSheetReportCubit.state.isLoading! &&
          _termSheetReportCubit.state.termSheetReportList.length <
              _termSheetReportCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _termSheetReportCubit.getTermSheetReportList(
            context,
            _termSheetReportCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterTermSheetReport(
    BuildContext context,
  ) async {
    final state = _termSheetReportCubit.state;
    _filterCompanyName.text = state.filterByCompanyName;
    _filterInstitutionName.text = state.filterByInstitutionName;
    _searchC.text = state.searchText;
    String? selectedDirection =
        state.currentSortColumn == "Name Of Institution / Bank / NBFC"
            ? state.currentSortDirection
            : null;
    final String? initialDirection = selectedDirection;
    final String initialProjectName = _searchC.text;
    final String initialCompanyName = _filterCompanyName.text;
    final String initialInstitutionName = _filterInstitutionName.text;
    final String initialStatus = state.filterByStatus;
    if (initialStatus.isNotEmpty) {
      _selectedStatusNotifier.value = termSheetApprovalStatus.firstWhere(
        (e) => e['DisplayName'] == initialStatus,
        orElse: () => termSheetApprovalStatus.first,
      );
    }
    bool manualClose = false;
    bool applied = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    void updateApplyState(StateSetter innerState) {
      final currentStatus =
          (_selectedStatusNotifier.value?['zAttributesId'] == -1)
              ? ''
              : _selectedStatusNotifier.value?['DisplayName'] ?? '';
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialProjectName) ||
            (_filterCompanyName.text.trim() != initialCompanyName) ||
            (_filterInstitutionName.text.trim() != initialInstitutionName) ||
            (currentStatus != initialStatus) ||
            (selectedDirection != initialDirection);

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Term Sheet Report",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sort By Name Of Institution / Bank / NBFC",
                  style: AppTextStyle.ts14M(),
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                  title: "Project Name",
                  hint: "Enter Project Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Company Name",
                  hint: "Enter Company Name",
                  textController: _filterCompanyName,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                ValueListenableBuilder(
                  valueListenable: _selectedStatusNotifier,
                  builder: (context, selectedStatus, _) {
                    return CustomDropDownWidget(
                      title: "Status",
                      hintText: "Select Status",
                      initialValue: selectedStatus,
                      dataList: termSheetApprovalStatus,
                      onSelected: (v) {
                        _selectedStatusNotifier.value = v;
                        updateApplyState(innerState);
                      },
                      onValueClear: () {
                        _selectedStatusNotifier.value = null;
                        updateApplyState(innerState);
                      },
                    );
                  },
                ),
                CustomTextField(
                  title: "Name of Institution / Bank / NBFC",
                  hint: "Enter Name of Institution / Bank / NBFC",
                  textController: _filterInstitutionName,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _searchC.clear();
        _filterCompanyName.clear();
        _filterInstitutionName.clear();
        _selectedStatusNotifier.value = null;
        _termSheetReportCubit.applyTermSheetReportFilter(
          context: context,
          isClear: true,
        );
      },
      onApply: () {
        applied = true;
        _termSheetReportCubit.applyTermSheetReportFilter(
          context: context,
          projectName: _searchC.text.trim(),
          companyName: _filterCompanyName.text.trim(),
          institutionName: _filterInstitutionName.text.trim(),
          status:
              _selectedStatusNotifier.value != null
                  ? _selectedStatusNotifier.value!['DisplayName']
                  : '',
          sortColumn:
              selectedDirection != null
                  ? "Name Of Institution / Bank / NBFC"
                  : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    // If bottom sheet closes without applying
    if (!applied && manualClose) {
      _searchC.clear();
      _filterCompanyName.clear();
      _filterInstitutionName.clear();
      _selectedStatusNotifier.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TermSheetReportCubit, TermSheetReportState>(
      listener: (context, state) {
        _filterCount.value = _termSheetReportCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          authorization: _routeAuthorizationModel,
          screenTitle: "Term Sheet Report",
          searchHintText: "Search by Project Name",
          textController: _searchC,
          onSearchSubmit: (value) {
            _termSheetReportCubit.searchTermSheetReport(context, value);
          },
          onExportCallback: (value) {
            _termSheetReportCubit.exportExcelPdf(context, value);
          },
          isFilterOn: true,
          filterCountNotifier: _filterCount,
          onFilterTap: () {
            _showBottomSheetToFilterTermSheetReport(context);
          },
        ),
        body: BlocBuilder<TermSheetReportCubit, TermSheetReportState>(
          builder: (context, state) {
            if ((state.isLoading ?? false) &&
                state.termSheetReportList.isEmpty) {
              return Center(child: loader());
            }
            if (state.termSheetReportList.isEmpty) {
              return Center(
                child: noDataWidget(message: "No Term Sheet Report Data Found"),
              );
            }
            return ListView.separated(
              controller: scrollController,
              itemCount: state.termSheetReportList.length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (context, index) => verticalSpacing(height: 5),
              itemBuilder: (context, index) {
                final termSheetReport = state.termSheetReportList[index];
                final amount =
                    termSheetReport.balanceAsOnDateAmount.toIndianCurrency();
                final isLargeAmount = amount.length > 12;
                return CustomExpandableCard(
                  padding: EdgeInsets.zero,
                  decoration: _tileDecoration(),
                  headerPadding: const EdgeInsets.all(16),
                  header: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Expanded(
                            child: Text(
                              termSheetReport.companyName,
                              style: AppTextStyle.ts16SB(),
                            ),
                          ),
                          termSheetReportStatusWidget(
                            termSheetReport.type,
                            textStyle: AppTextStyle.ts10M(),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Project Name',
                              style: AppTextStyle.ts12R(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          Text(" : "),
                          Expanded(
                            child: Text(
                              termSheetReport.projectName,
                              style: AppTextStyle.ts14M(
                                color: Color(0xFF1C2B4A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Bank Name',
                              style: AppTextStyle.ts12R(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          Text(" : "),
                          Expanded(
                            child: Text(
                              termSheetReport.nameOfInstitutionBankNBFC,
                              style: AppTextStyle.ts14M(
                                color: Color(0xFF1C2B4A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Approval Status',
                              style: AppTextStyle.ts12R(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          Text(" : "),
                          approvalStatusWidget(termSheetReport.approvalStatus),
                        ],
                      ),
                    ],
                  ),
                  body: Container(
                    color: AppColor.lightBluebg.withValues(alpha: 0.4),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          _sectionTitle(
                            'LOAN DETAILS',
                            const Color(0xFF1A73E8),
                          ),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: _infoTile(
                                    label: 'LOAN TAKEN BY',
                                    value: termSheetReport.loanTakenBy,
                                  ),
                                ),
                                Expanded(
                                  child: _infoTile(
                                    label: 'SANCTION DATE',
                                    value: formatDateTimeAsDDMMMYYYY(
                                      termSheetReport.sanctionDate,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _sectionTitle('AMOUNT', const Color(0xFF0D9488)),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: _tileDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 14,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _amountItem(
                                        label: 'SANCTION',
                                        value:
                                            termSheetReport.facilityAmount
                                                .toIndianCurrency(),
                                        valueColor: const Color(0xFF0D9488),
                                      ),
                                    ),
                                    Expanded(
                                      child: _amountItem(
                                        label: 'DISBURSED',
                                        value:
                                            termSheetReport.totalDisbursedAmount
                                                .toIndianCurrency(),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _amountItem(
                                        label: 'BALANCE\nDISBURSEMENT',
                                        value:
                                            termSheetReport
                                                .balanceDisbursementAmount
                                                .toIndianCurrency(),
                                      ),
                                    ),
                                    Expanded(
                                      child: _amountItem(
                                        label: 'REPAYMENT',
                                        value:
                                            termSheetReport
                                                .totalRepayLedgerAmount
                                                .toIndianCurrency(),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 1, color: AppColor.grey50),
                                if (isLargeAmount)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 6,
                                    children: [
                                      Text(
                                        'BALANCE AS ON DATE',
                                        style: AppTextStyle.ts12SB(
                                          color: AppColor.black.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        amount,
                                        style: AppTextStyle.ts16SB(
                                          color: const Color(0xFFE8590C),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'BALANCE AS ON\nDATE',
                                          style: AppTextStyle.ts12SB(
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            amount,
                                            style: AppTextStyle.ts16SB(
                                              color: const Color(0xFFE8590C),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          _sectionTitle('LOAN STATUS', const Color(0xFF6366F1)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Expanded(
                                child: _infoTile(
                                  label: 'RATE OF INTEREST',
                                  value:
                                      '${termSheetReport.rateOfInterestInPercentage}%',
                                ),
                              ),
                              Expanded(
                                child: _infoTile(
                                  label: 'CLOSING DATE',
                                  value: formatDateTimeAsDDMMMYYYY(
                                    termSheetReport.closingDate,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _tileDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFE6E8EE)),
  );
  Widget _sectionTitle(String title, Color dotColor) => Row(
    spacing: 8,
    children: [
      Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      ),
      Text(title, style: AppTextStyle.ts12SB(color: dotColor)),
    ],
  );
  Widget _infoTile({required String label, required String value}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: _tileDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          label,
          style: AppTextStyle.ts12SB(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        Text(value.trim().isEmpty ? '—' : value, style: AppTextStyle.ts14SB()),
      ],
    ),
  );
  Widget _amountItem({
    required String label,
    required String value,
    Color? valueColor,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) => Column(
    crossAxisAlignment: crossAxisAlignment,
    spacing: 4,
    children: [
      Text(
        label,
        textAlign:
            crossAxisAlignment == CrossAxisAlignment.end
                ? TextAlign.end
                : TextAlign.start,
        style: AppTextStyle.ts12SB(
          color: AppColor.black.withValues(alpha: 0.5),
        ),
      ),
      Text(value, style: AppTextStyle.ts14SB(color: valueColor)),
    ],
  );
}
