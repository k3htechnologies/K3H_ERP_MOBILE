import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/presentation/cubit/term_sheet_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TermSheetScreen extends StatefulWidget {
  const TermSheetScreen({super.key});

  @override
  State<TermSheetScreen> createState() => _TermSheetScreenState();
}

class _TermSheetScreenState extends State<TermSheetScreen> {
  late TermSheetCubit _termSheetCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _searchC,
      _filterProjectNameC,
      _filterByCompanyNameC,
      _nameOfInstitutionBankNBFCC;
  final ValueNotifier<Map<String, dynamic>?> _selectedApprovalStatus =
      ValueNotifier(null);
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // FILTER COUNT
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    _termSheetCubit = context.read<TermSheetCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.termSheet]!;
    initialiseControllers();
    _onScroll();
    _termSheetCubit.getTermSheet(context, 1);
    super.initState();
  }

  void initialiseControllers() {
    _searchC = TextEditingController();
    _filterByCompanyNameC = TextEditingController();
    _filterProjectNameC = TextEditingController();
    _nameOfInstitutionBankNBFCC = TextEditingController();
  }

  @override
  void dispose() {
    _searchC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _filterCount.dispose();
    _filterProjectNameC.dispose();
    _filterByCompanyNameC.dispose();
    _nameOfInstitutionBankNBFCC.dispose();
    super.dispose();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_termSheetCubit.state.isLoading ?? false) &&
          _termSheetCubit.state.termSheetList.length <
              _termSheetCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _termSheetCubit.getTermSheet(
            context,
            _termSheetCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showPopupToDeleteTermSheet(
    BuildContext context,
    TermSheetModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Term Sheet ?',
      'Deleting this Term Sheet will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _termSheetCubit.deleteTermSheet(
        context: context,
        termSheet: obj,
        index: index,
      );
    }
  }

  Future<void> _showBottomSheetToFilterTermSheet(BuildContext context) async {
    final state = _termSheetCubit.state;

    _searchC.text = state.searchText;
    _filterProjectNameC.text = state.searchText;
    _filterByCompanyNameC.text = state.filterByCompanyName;
    _nameOfInstitutionBankNBFCC.text = state.filterByInstitutionName;
    final String initialName = _searchC.text;
    final String initialProjectName = _filterProjectNameC.text;
    final String initialCompanyName = _filterByCompanyNameC.text;
    final String initialInstitionName = _nameOfInstitutionBankNBFCC.text;
    final initialApprovalStatus = state.filterByStatus;
    if (initialApprovalStatus.isNotEmpty) {
      _selectedApprovalStatus.value = approvalStatus.firstWhere(
        (e) => e['DisplayName'] == initialApprovalStatus,
        orElse: () => approvalStatus.first,
      );
    }
    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      final currentApprovalStatus =
          _selectedApprovalStatus.value?['DisplayName'] ?? '';

      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialProjectName) ||
            (_filterProjectNameC.text.trim() != initialName) ||
            (_filterByCompanyNameC.text.trim() != initialCompanyName) ||
            (currentApprovalStatus != initialApprovalStatus) ||
            (_nameOfInstitutionBankNBFCC.text.trim() != initialInstitionName);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Term Sheet",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: "Project Name",
                  hint: "Enter Project Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Company Name",
                  hint: "Enter Company Name",
                  textController: _filterByCompanyNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                ValueListenableBuilder(
                  valueListenable: _selectedApprovalStatus,
                  builder: (context, value, child) {
                    return CustomDropDownWidget(
                      title: "Status",
                      hintText: "Call Status",
                      initialValue: value,
                      dataList: approvalStatus,
                      onSelected: (value) {
                        _selectedApprovalStatus.value = value;
                        updateApplyState(innerState);
                      },
                      onValueClear: () {
                        _selectedApprovalStatus.value = null;
                        updateApplyState(innerState);
                      },
                    );
                  },
                ),
                CustomTextField(
                  title: "Name of Institution / Bank / NBFC",
                  hint: "Enter Name of Institution / Bank / NBFC",
                  textController: _nameOfInstitutionBankNBFCC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _searchC.clear();
        _filterProjectNameC.clear();
        _filterByCompanyNameC.clear();
        _selectedApprovalStatus.value = null;
        _nameOfInstitutionBankNBFCC.clear();
        _searchC.clear();
        _termSheetCubit.applyTermSheetFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        _termSheetCubit.applyTermSheetFilterAndSort(
          context: context,
          projectName: _searchC.text.trim(),
          companyName: _filterByCompanyNameC.text.trim(),
          status: _selectedApprovalStatus.value?["DisplayName"] ?? "",
          institutionName: _nameOfInstitutionBankNBFCC.text.trim(),
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterProjectNameC.clear();
      _filterByCompanyNameC.clear();
      _nameOfInstitutionBankNBFCC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TermSheetCubit, TermSheetState>(
      listener: (context, state) {
        _filterCount.value = _termSheetCubit.updateTermSheetFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Term Sheet",
          authorization: _routeAuthorizationModel,
          searchHintText: "Search By Project Name",
          onSearchSubmit: (value) {
            _termSheetCubit.searchTermSheet(context, value);
          },
          textController: _searchC,
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterTermSheet(context);
          },
          onExportCallback: (value) {
            _termSheetCubit.exportExcelPdf(context, value);
          },
          onAddCallback: () {
            _termSheetCubit.clearLocalTermSheetData();
            goRouter.pushNamed(AppRoutes.addTermSheet);
          },
          filterCountNotifier: _filterCount,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _termSheetCubit.getTermSheet(context, 1);
          },
          child: BlocBuilder<TermSheetCubit, TermSheetState>(
            builder: (context, state) {
              if ((state.isLoading ?? false) && state.termSheetList.isEmpty) {
                return Center(child: loader());
              }
              if (state.termSheetList.isEmpty) {
                return Center(
                  child: noDataWidget(
                    message: "No Term Sheet Data found",
                    iconSize: 160.0,
                  ),
                );
              }
              return ListView.builder(
                controller: scrollController,
                itemCount: state.termSheetList.length + 1,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                itemBuilder: (context, index) {
                  if (index == state.termSheetList.length) {
                    return state.termSheetList.length <
                            state.totalNumberOfRecord
                        ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  return termSheetCard(context, state, index);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget termSheetCard(BuildContext context, TermSheetState state, int index) {
    final termSheet = state.termSheetList[index];
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.0,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    goRouter.pushNamed(
                      AppRoutes.viewTermSheet,
                      extra: {
                        "termSheet": termSheet,
                        "termSheetDetailsView": state.termSheetDetailsViewModel,
                      },
                    );
                  },
                  child: Text(
                    termSheet.nameOfInstitutionBankNbfc.isEmpty
                        ? "-"
                        : termSheet.nameOfInstitutionBankNbfc,
                    style: AppTextStyle.ts16SB(color: AppColor.primary),
                  ),
                ),
              ),
              horizontalSpacing(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIconButton.delete(
                      isDisabled:
                          termSheet.approvalStatus.toLowerCase() != "pending",
                      onPressed: () {
                        _showPopupToDeleteTermSheet(context, termSheet, index);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          buildRowTitleValue(
            title: "Project Name",
            value: termSheet.projectName,
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Laon Taken By",
            value: termSheet.loanTakenBy,
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Term Sheet Date",
            value: formatDateTimeAsDDMMMYYYY(termSheet.termSheetDate),
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Facility Amount (₹)",
            value: termSheet.facilityAmount.toIndianCurrency(),
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Rate Of Interest (%)",
            value: "${termSheet.rateOfInterestInPercentage} %",
            singleLine: false,
          ),
        ],
      ),
    );
  }
}
