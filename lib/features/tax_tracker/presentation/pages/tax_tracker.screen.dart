import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/company_setup/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/cubit/tax_tracker_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_date_function.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TaxTrackerScreen extends StatefulWidget {
  const TaxTrackerScreen({super.key});

  @override
  State<TaxTrackerScreen> createState() => _TaxTrackerScreenState();
}

class _TaxTrackerScreenState extends State<TaxTrackerScreen> {
  // CUBIT
  late TaxTrackerCubit _taxTrackerCubit;
  late EmployeeMasterCubit _employeeMasterCubit;

  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _searchC,
      _filterByNoticeTitleC,
      _filterByAuthorityC,
      _filterByFinancialYearC,
      _filterByGovernmentComplianceC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // FILTER COUNT
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedCompany = [];

  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

  final ValueNotifier<Map<String, dynamic>?> _selectedNoticeStatus =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _taxTrackerCubit = context.read<TaxTrackerCubit>();
    _employeeMasterCubit = context.read<EmployeeMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.taxTracker] ??
        AuthorizationModel();
    initialiseControllers();
    _onScroll();
    _taxTrackerCubit.getTaxTrackerList(context, 1);
  }

  void initialiseControllers() {
    _searchC = TextEditingController();
    _filterByNoticeTitleC = TextEditingController();
    _filterByAuthorityC = TextEditingController();
    _filterByFinancialYearC = TextEditingController();
    _filterByGovernmentComplianceC = TextEditingController();
  }

  @override
  void dispose() {
    _searchC.dispose();
    _filterByNoticeTitleC.dispose();
    _filterByAuthorityC.dispose();
    _filterByFinancialYearC.dispose();
    _filterByGovernmentComplianceC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _filterCount.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    super.dispose();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_taxTrackerCubit.state.isLoading! &&
          _taxTrackerCubit.state.taxTrackerList.length <
              _taxTrackerCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _taxTrackerCubit.getTaxTrackerList(
            context,
            _taxTrackerCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // FETCH COMPANIES
  Future<Map<String, dynamic>> _fetchCompany(
    int pageNumber, {
    String? value,
  }) async {
    const pageSize = 15;

    //  SEARCH MODE
    if (value != null) {
      await _employeeMasterCubit.getCompanies(
        context,
        pageNumber,
        pageSize,
        searchQuery: value,
      );

      final companyList = _employeeMasterCubit.state.companyNameList;
      final totalCount = _employeeMasterCubit.state.companyNameTotalCount;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final comp in companyList) {
        uniqueFiltered[comp.companyId] = {
          "zAttributesId": comp.companyId,
          "DisplayName": comp.companyName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    //  NORMAL PAGINATION MODE
    final totalCount = _employeeMasterCubit.state.companyNameTotalCount;
    final currentLoadedCount =
        _employeeMasterCubit.state.companyNameList.length;

    // LOAD NEXT PAGE
    if (currentLoadedCount < totalCount) {
      await _employeeMasterCubit.getCompanies(context, pageNumber, pageSize);
    }

    final updatedList = _employeeMasterCubit.state.companyNameList;

    final Map<int, Map<String, dynamic>> uniqueCompanies = {};

    for (final comp in updatedList) {
      uniqueCompanies[comp.companyId] = {
        "zAttributesId": comp.companyId,
        "DisplayName": comp.companyName,
      };
    }

    return {
      "itemList": uniqueCompanies.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueCompanies.length,
    };
  }

  Future<void> _showBottomSheetToFilterTaxTracker(BuildContext context) async {
    final state = _taxTrackerCubit.state;
    String? selectedDirection =
        state.currentSortColumn == "Notice Title"
            ? state.currentSortDirection
            : null;
    _searchC.text = state.searchText;
    _filterByNoticeTitleC.text = state.searchText;
    _filterByAuthorityC.text = state.filterByAuthority;
    _filterByFinancialYearC.text = state.filterByFinancialYear;
    _filterByGovernmentComplianceC.text = state.filterByGovernmentCompliance;
    _startDateNotifier.value = state.filterByFromDate;
    _endDateNotifier.value = state.filterByToDate;
    final String initialName = _searchC.text;
    final String initialNoticeTitle = _filterByNoticeTitleC.text;
    final String initialAuthority = _filterByAuthorityC.text;
    final String initialFinancialYear = _filterByFinancialYearC.text;
    final initialCompany = state.filterByCompany;
    final String initialGovermentCompliance =
        _filterByGovernmentComplianceC.text;
    final initialCallStatus = state.filterCallStatus;
    final String? initialDirection = selectedDirection;
    final DateTime? initialFromDate = _startDateNotifier.value;
    final DateTime? initialToDate = _endDateNotifier.value;
    if (initialCallStatus.isNotEmpty) {
      _selectedNoticeStatus.value = callStatus.firstWhere(
        (e) => e['DisplayName'] == initialCallStatus,
        orElse: () => callStatus.first,
      );
    }
    _selectedCompany = [];

    if (state.filterByCompany != 0) {
      final selected =
          _employeeMasterCubit.state.companyNameList
              .where((company) => company.companyId == state.filterByCompany)
              .toList();

      if (selected.isNotEmpty) {
        _selectedCompany = [
          {
            "zAttributesId": selected.first.companyId,
            "DisplayName": selected.first.companyName,
          },
        ];
      }
    }
    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      final int currentCompanyId =
          _selectedCompany.isNotEmpty
              ? int.tryParse(
                    _selectedCompany.first['zAttributesId'].toString(),
                  ) ??
                  0
              : 0;

      final currentCallStatus =
          _selectedNoticeStatus.value?['DisplayName'] ?? '';

      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialNoticeTitle) ||
            (_filterByNoticeTitleC.text.trim() != initialName) ||
            (_filterByAuthorityC.text.trim() != initialAuthority) ||
            (_filterByFinancialYearC.text.trim() != initialFinancialYear) ||
            (currentCompanyId != initialCompany) ||
            (_filterByGovernmentComplianceC.text.trim() !=
                initialGovermentCompliance) ||
            (selectedDirection != initialDirection) ||
            (_startDateNotifier.value != initialFromDate) ||
            (_endDateNotifier.value != initialToDate) ||
            (currentCallStatus != initialCallStatus);

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Tax Tracker",
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
                Text("Sort By Notice Title", style: AppTextStyle.ts14M()),
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
                CustomMultipleSelectPopup(
                  title: "Company Name",
                  isMultiSelect: false,
                  hintText: "All Companies",
                  initialValue: _selectedCompany,
                  dataFetchCallBack: _fetchCompany,
                  dataList: [],
                  onSelected: (value) {
                    _selectedCompany = value;
                    updateApplyState(innerState);
                  },
                ),
                CustomTextField(
                  title: "Notice Title",
                  hint: "Enter Notice Title",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Authority",
                  hint: "Enter Authority",
                  textController: _filterByAuthorityC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Financial Year",
                  hint: "Enter Financial Year",
                  textController: _filterByFinancialYearC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Government Compliance",
                  hint: "Enter Government Compliance",
                  textController: _filterByGovernmentComplianceC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _startDateNotifier,
                        builder: (context, startDate, child) {
                          return CustomDatePicker(
                            title: "From Date",
                            initialDate: startDate,
                            setValue: (value) {
                              _startDateNotifier.value = value;

                              updateApplyState(innerState);
                            },
                            validator: (value) => null,
                          );
                        },
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _endDateNotifier,
                        builder: (context, endDate, child) {
                          return ValueListenableBuilder<DateTime?>(
                            valueListenable: _startDateNotifier,
                            builder: (context, startDate, child) {
                              return CustomDatePicker(
                                title: "To Date",
                                isRequired: false,
                                initialDate: endDate,
                                setValue: (value) {
                                  _endDateNotifier.value = value;

                                  updateApplyState(innerState);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: _selectedNoticeStatus,
                  builder: (context, value, child) {
                    return CustomDropDownWidget(
                      title: "Notice Status",
                      hintText: "Select Notice Status",
                      initialValue: value,
                      dataList: taxTrackerNoticeStatus,
                      onSelected: (value) {
                        _selectedNoticeStatus.value = value;
                        updateApplyState(innerState);
                      },
                      onValueClear: () {
                        _selectedNoticeStatus.value = null;
                        updateApplyState(innerState);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _searchC.clear();
        _filterByNoticeTitleC.clear();
        _filterByAuthorityC.clear();
        _filterByFinancialYearC.clear();
        _filterByGovernmentComplianceC.clear();
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _selectedNoticeStatus.value = null;
        _taxTrackerCubit.applyTaxTrackerFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        _taxTrackerCubit.applyTaxTrackerFilterAndSort(
          context: context,
          noticeTitle: _searchC.text.trim(),
          authority: _filterByAuthorityC.text.trim(),
          financialYear: _filterByFinancialYearC.text.trim(),
          company:
              _selectedCompany.isNotEmpty
                  ? _selectedCompany.first['zAttributesId'] as int
                  : 0,
          governmentCompliance: _filterByGovernmentComplianceC.text.trim(),
          sortColumn: selectedDirection != null ? "Notice Title" : null,
          sortDirection: selectedDirection,
          filterByFromDate: _startDateNotifier.value,
          filterByToDate: _endDateNotifier.value,
          callLogStatus: _selectedNoticeStatus.value?['DisplayName'] ?? "",
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterByNoticeTitleC.clear();
      _filterByAuthorityC.clear();
      _filterByFinancialYearC.clear();
      _filterByGovernmentComplianceC.clear();
      _startDateNotifier.value = null;
      _endDateNotifier.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaxTrackerCubit, TaxTrackerState>(
      listener: (context, state) {
        _filterCount.value = _taxTrackerCubit.updateTaxTrackerFilterCount(
          state,
        );
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Tax Tracker",
          authorization: _routeAuthorizationModel,
          searchHintText: "Search by Notice Title",
          textController: _searchC,
          onSearchSubmit: (value) {
            _taxTrackerCubit.searchTaxTracker(context, value);
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterTaxTracker(context);
          },
          filterCountNotifier: _filterCount,
          onAddCallback: () {
            goRouter.pushNamed(AppRoutes.addTaxTracker);
          },
          onExportCallback: (value) {},
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _searchC.clear();
            _taxTrackerCubit.searchTaxTracker(context, "");
          },
          child: BlocBuilder<TaxTrackerCubit, TaxTrackerState>(
            builder: (context, state) {
              if (state.isLoading == true && state.taxTrackerList.isEmpty) {
                return Center(child: loader());
              }
              if (state.taxTrackerList.isEmpty) {
                return Center(
                  child: noDataWidget(message: "No Tax Tracker Data Found"),
                );
              }
              return ListView.builder(
                controller: scrollController,
                itemCount: state.taxTrackerList.length + 1,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.sp,
                  vertical: 12.sp,
                ),
                itemBuilder: (context, index) {
                  if (index == state.taxTrackerList.length) {
                    return state.taxTrackerList.length <
                            state.totalNumberOfRecord
                        ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  final taxTracker = state.taxTrackerList[index];
                  final hasRequestType = taxTracker
                      .taxTrackerDocumentDetailsData
                      .any(
                        (document) => document.requestType.trim().isNotEmpty,
                      );
                  return SectionCard(
                    headerBackgroundColor: Color(0xFFF3F7FF),
                    title: GestureDetector(
                      onTap: () {
                        goRouter.pushNamed(AppRoutes.viewTaxTrackerMain);
                      },
                      child: Text(
                        taxTracker.noticeType,
                        style: AppTextStyle.ts14SB(color: AppColor.primary),
                      ),
                    ),
                    suffix: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomIconButton.edit(
                          onPressed: () {
                            goRouter.pushNamed(
                              AppRoutes.addTaxTracker,
                              queryParameters: {
                                "taxTrackerModel": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(taxTracker.toJson()),
                                  ),
                                ),
                                'index': index.toString(),
                              },
                            );
                          },
                        ),
                        horizontalSpacing(),
                        CustomIconButton.add(
                          onPressed: () {
                            goRouter.pushNamed(
                              AppRoutes.addRequestsTaxTracker,
                              queryParameters: {
                                "taxTracker": Uri.encodeComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(taxTracker.toJson()),
                                  ),
                                ),
                              },
                            );
                          },
                        ),
                        horizontalSpacing(),
                        CustomIconButton.delete(
                          isDisabled: hasRequestType,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Company Name",
                                value: taxTracker.companyName,
                              ),
                              horizontalSpacing(),
                              buildColumnTitleValue(
                                title: "Notice Status",
                                value: taxTracker.noticeStatus,
                                customValueWidget: taxTrackerNoticeStatusWidget(
                                  taxTracker.noticeStatus,
                                ),
                              ),
                            ],
                          ),
                          verticalSpacing(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Government Compliance",
                                value: taxTracker.governmentCompliance,
                              ),
                            ],
                          ),
                          verticalSpacing(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Authority Type",
                                value: taxTracker.authority,
                              ),
                              horizontalSpacing(),
                              buildColumnTitleValue(
                                title: "Financial Year",
                                value: taxTracker.financialYear,
                              ),
                            ],
                          ),
                          verticalSpacing(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Notice Date",
                                value: formatDateTimeAsDDMMMYYYY(
                                  taxTracker.noticeDate,
                                ),
                              ),
                              horizontalSpacing(),
                              buildColumnTitleValue(
                                title: "Reply Due Date",
                                value: formatDateTimeAsDDMMMYYYY(
                                  taxTracker.dueDate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
