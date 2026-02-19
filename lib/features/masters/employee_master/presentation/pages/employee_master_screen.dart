// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class EmployeeMasterScreen extends StatefulWidget {
  const EmployeeMasterScreen({super.key});

  @override
  State<EmployeeMasterScreen> createState() =>
      _EmployeeMasterMobileScreenState();
}

class _EmployeeMasterMobileScreenState extends State<EmployeeMasterScreen> {
  // CUBIT
  late EmployeeMasterCubit _employeeMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController _scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _filterReportPersonName,
      _filterCompanyName,
      _filterEmployeeCode,
      _filterDepartmentC,
      _filterDesignationC,
      _filterMobileNumber,
      _filterBranchName;

  @override
  void initState() {
    super.initState();
    _employeeMasterCubit = context.read<EmployeeMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.employeeMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _employeeMasterCubit.getEmployeeMasterList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _filterReportPersonName.dispose();
    _filterCompanyName.dispose();
    _filterEmployeeCode.dispose();
    _filterDepartmentC.dispose();
    _filterDesignationC.dispose();
    _filterMobileNumber.dispose();
    _filterBranchName.dispose();
    _scrollController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterReportPersonName = TextEditingController();
    _filterCompanyName = TextEditingController();
    _filterEmployeeCode = TextEditingController();
    _filterDepartmentC = TextEditingController();
    _filterDesignationC = TextEditingController();
    _filterMobileNumber = TextEditingController();
    _filterBranchName = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_employeeMasterCubit.state.isLoading! &&
          _employeeMasterCubit.state.employeeMasterList.length <
              _employeeMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _employeeMasterCubit.getEmployeeMasterList(
            context,
            _employeeMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // EMPLOYEE FILTER
  Future<void> _showBottomSheetToFilterEmployeeMaster(
    BuildContext context,
  ) async {
    final state = _employeeMasterCubit.state;

    _filterReportPersonName.text = state.filterReportPersonName;
    _filterCompanyName.text = state.filterCompanyName;
    _filterDepartmentC.text = state.filterDepartmentName;
    _filterEmployeeCode.text = state.filterEmployeeCode;
    _filterDesignationC.text = state.filterDesignationName;
    _filterMobileNumber.text = state.filterMobileNumber;
    _filterBranchName.text = state.filterBranchName;

    String? selectedDirection =
        state.currentSortColumn == "Full Name"
            ? state.currentSortDirection
            : null;

    final String initialReportPersonName = _filterReportPersonName.text;
    final String initialCompName = _filterCompanyName.text;
    final String initialEmpCode = _filterEmployeeCode.text;
    final String initialDept = _filterDepartmentC.text;
    final String initialDesig = _filterDesignationC.text;
    final String initialMobileNumber = _filterMobileNumber.text;
    final String initialBranchName = _filterBranchName.text;
    final String? initialDirection = selectedDirection;

    DateTime? filterDOBFromDate = state.filterDOBFrom;
    DateTime? filterDOBToDate = state.filterDOBTo;
    final DateTime? initialDOBFrom = state.filterDOBFrom;
    final DateTime? initialDOBTo = state.filterDOBTo;

    String selectedProbation = state.filterIsProbation;
    String selectedIdCardIssued = state.filterIdCardIssue;
    final String initialProbation = state.filterIsProbation;
    final String initialIdCardIssued = state.filterIdCardIssue;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;
    final filterFormKey = GlobalKey<FormState>();

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterReportPersonName.text.trim() != initialReportPersonName) ||
            (_filterCompanyName.text.trim() != initialCompName) ||
            (_filterEmployeeCode.text.trim() != initialEmpCode) ||
            (_filterDepartmentC.text.trim() != initialDept) ||
            (_filterDesignationC.text.trim() != initialDesig) ||
            (_filterMobileNumber.text.trim() != initialMobileNumber) ||
            (_filterBranchName.text.trim() != initialBranchName) ||
            (selectedDirection != initialDirection) ||
            (selectedProbation != initialProbation) ||
            (selectedIdCardIssued != initialIdCardIssued) ||
            (filterDOBFromDate != initialDOBFrom) ||
            (filterDOBToDate != initialDOBTo);
        // Disable Apply when only one of From/To is set (both or neither required)
        final bool onlyOneSet =
            (filterDOBFromDate != null && filterDOBToDate == null) ||
            (filterDOBToDate != null && filterDOBFromDate == null);
        // Disable Apply when From > To (invalid range)
        final bool invalidRange =
            filterDOBFromDate != null &&
            filterDOBToDate != null &&
            filterDOBFromDate!.isAfter(
              DateTime(
                filterDOBToDate!.year,
                filterDOBToDate!.month,
                filterDOBToDate!.day,
              ),
            );
        final bool dobInvalid = onlyOneSet || invalidRange;
        applyEnabled.value = manualClose && !dobInvalid;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Employee",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return Form(
            key: filterFormKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sort By Employee Name", style: AppTextStyle.ts14M()),
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
                    title: "Employee Code",
                    hint: "Enter Employee Code",
                    textController: _filterEmployeeCode,
                    onChangeFunction: (_) => updateApplyState(innerState),
                  ),
                  verticalSpacing(height: 5),
                  CustomTextField(
                    title: "Company Name",
                    hint: "Enter Company Name",
                    textController: _filterCompanyName,
                    onChangeFunction: (_) => updateApplyState(innerState),
                  ),
                  verticalSpacing(height: 5),
                  CustomTextField(
                    title: "Reporting Person Name",
                    hint: "Enter Reporting Person Name",
                    textController: _filterReportPersonName,
                    onChangeFunction: (_) => updateApplyState(innerState),
                  ),
                  verticalSpacing(height: 5),
                  CustomTextField(
                    title: "Branch Name",
                    hint: "Enter Branch Name",
                    textController: _filterBranchName,
                    onChangeFunction: (_) => updateApplyState(innerState),
                  ),
                  verticalSpacing(height: 5),
                  CustomTextField(
                    title: "Department",
                    hint: "Enter Department",
                    textController: _filterDepartmentC,
                    onChangeFunction: (_) => updateApplyState(innerState),
                  ),
                  verticalSpacing(height: 5),
                  CustomTextField(
                    title: "Designation",
                    hint: "Enter Designation",
                    textController: _filterDesignationC,
                    onChangeFunction: (_) => updateApplyState(innerState),
                  ),
                  verticalSpacing(height: 5),
                  CustomTextField(
                    title: "Mobile Number",
                    hint: "Enter Mobile Number",
                    textController: _filterMobileNumber,
                    onChangeFunction: (_) => updateApplyState(innerState),
                  ),
                  verticalSpacing(height: 5),
                  Text("Employee On Probation?", style: AppTextStyle.ts14M()),
                  verticalSpacing(height: 6),
                  Row(
                    children: [
                      Radio<String>(
                        value: "",
                        groupValue: selectedProbation,
                        onChanged: (value) {
                          innerState(() {
                            selectedProbation = value ?? "";
                            updateApplyState(innerState);
                          });
                        },
                        activeColor: AppColor.primary,
                      ),
                      Text("Both", style: AppTextStyle.ts12R()),
                      horizontalSpacing(width: 16),
                      Radio<String>(
                        value: "1",
                        groupValue: selectedProbation,
                        onChanged: (value) {
                          innerState(() {
                            selectedProbation = value ?? "";
                            updateApplyState(innerState);
                          });
                        },
                        activeColor: AppColor.primary,
                      ),
                      Text("Yes", style: AppTextStyle.ts12R()),
                      horizontalSpacing(width: 16),
                      Radio<String>(
                        value: "0",
                        groupValue: selectedProbation,
                        onChanged: (value) {
                          innerState(() {
                            selectedProbation = value ?? "";
                            updateApplyState(innerState);
                          });
                        },
                        activeColor: AppColor.primary,
                      ),
                      Text("No", style: AppTextStyle.ts12R()),
                    ],
                  ),
                  verticalSpacing(height: 5),
                  Text("Id Card Issued?", style: AppTextStyle.ts14M()),
                  verticalSpacing(height: 6),
                  Row(
                    children: [
                      Radio<String>(
                        value: "",
                        groupValue: selectedIdCardIssued,
                        onChanged: (value) {
                          innerState(() {
                            selectedIdCardIssued = value ?? "";
                            updateApplyState(innerState);
                          });
                        },
                        activeColor: AppColor.primary,
                      ),
                      Text("Both", style: AppTextStyle.ts12R()),
                      horizontalSpacing(width: 16),
                      Radio<String>(
                        value: "1",
                        groupValue: selectedIdCardIssued,
                        onChanged: (value) {
                          innerState(() {
                            selectedIdCardIssued = value ?? "";
                            updateApplyState(innerState);
                          });
                        },
                        activeColor: AppColor.primary,
                      ),
                      Text("Yes", style: AppTextStyle.ts12R()),
                      horizontalSpacing(width: 16),
                      Radio<String>(
                        value: "0",
                        groupValue: selectedIdCardIssued,
                        onChanged: (value) {
                          innerState(() {
                            selectedIdCardIssued = value ?? "";
                            updateApplyState(innerState);
                          });
                        },
                        activeColor: AppColor.primary,
                      ),
                      Text("No", style: AppTextStyle.ts12R()),
                    ],
                  ),
                  verticalSpacing(height: 12),
                  CustomDatePicker(
                    title: "Date of Birth (From)",
                    initialDate: filterDOBFromDate,
                    setValue: (value) {
                      innerState(() {
                        filterDOBFromDate = value;
                        updateApplyState(innerState);
                      });
                    },
                  ),
                  if (filterDOBFromDate != null && filterDOBToDate == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Please select To date also',
                        style: AppTextStyle.ts12R().copyWith(
                          color: AppColor.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (filterDOBToDate != null && filterDOBFromDate == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Please select From date also',
                        style: AppTextStyle.ts12R().copyWith(
                          color: AppColor.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (filterDOBFromDate != null &&
                      filterDOBToDate != null &&
                      filterDOBFromDate!.isAfter(
                        DateTime(
                          filterDOBToDate!.year,
                          filterDOBToDate!.month,
                          filterDOBToDate!.day,
                        ),
                      ))
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Invalid Date range',
                        style: AppTextStyle.ts12R().copyWith(
                          color: AppColor.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  verticalSpacing(height: 12),
                  CustomDatePicker(
                    title: "Date of Birth (To)",
                    initialDate: filterDOBToDate,
                    setValue: (value) {
                      innerState(() {
                        filterDOBToDate = value;
                        updateApplyState(innerState);
                      });
                    },
                    validator: (value) {
                      if (filterDOBFromDate != null && value == null) {
                        return 'Date of Birth (To) is required when Date of Birth (From) is entered';
                      }
                      if (filterDOBFromDate != null &&
                          value != null &&
                          filterDOBFromDate!.isAfter(
                            DateTime(value.year, value.month, value.day),
                          )) {
                        return 'Invalid Date range';
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(),
                ],
              ),
            ),
          );
        },
      ),
      onClear: () {
        _filterReportPersonName.clear();
        _filterCompanyName.clear();
        _filterEmployeeCode.clear();
        _filterDepartmentC.clear();
        _filterDesignationC.clear();
        _filterMobileNumber.clear();
        _filterBranchName.clear();
        _employeeMasterCubit.applyFilterAndSort(
          context: context,
          employeeCode: "",
          companyName: "",
          reportingPersonName: "",
          departmentName: "",
          designationName: "",
          mobileNumber: "",
          branchName: "",
          filterDOBFrom: null,
          filterDOBTo: null,
          filterIsProbation: "",
          filterIdCardIssue: "",
          sortColumn: "Created Date",
          sortDirection: "DESC",
        );
      },
      onApply: () {
        if (filterFormKey.currentState?.validate() ?? false) {
          applied = true;
          _employeeMasterCubit.applyFilterAndSort(
            context: context,
            employeeCode: _filterEmployeeCode.text,
            companyName: _filterCompanyName.text,
            reportingPersonName: _filterReportPersonName.text,
            departmentName: _filterDepartmentC.text,
            designationName: _filterDesignationC.text,
            mobileNumber: _filterMobileNumber.text,
            branchName: _filterBranchName.text,
            filterDOBFrom: filterDOBFromDate,
            filterDOBTo: filterDOBToDate,
            filterIsProbation: selectedProbation,
            filterIdCardIssue: selectedIdCardIssued,
            sortColumn: selectedDirection != null ? "Full Name" : null,
            sortDirection: selectedDirection,
          );
        }
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterReportPersonName.clear();
      _filterCompanyName.clear();
      _filterEmployeeCode.clear();
      _filterDepartmentC.clear();
      _filterDesignationC.clear();
      _filterMobileNumber.clear();
      _filterBranchName.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onSearchSubmit: (value) {
          _employeeMasterCubit.searchEmployee(context, value);
        },
        searchHintText: "Search by Employee Name",
        textController: _searchC,
        screenTitle: 'Employee Master',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          if(_employeeMasterCubit.state.totalNumberOfRecord==0){
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _employeeMasterCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addUpdateEmployee);
          if (context.mounted) {
            _employeeMasterCubit.getEmployeeMasterList(context, 1);
          }
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterEmployeeMaster(context);
        },
      ),
      body: SafeArea(
        child: BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.employeeMasterList.isEmpty) {
              return Center(child: loader());
            }
            if (state.employeeMasterList.isEmpty) {
              return Center(child: noDataWidget());
            }

            final listView = ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              controller: _scrollController,
              itemCount:
                  _employeeMasterCubit.state.employeeMasterList.length + 1,
              itemBuilder: (context, index) {
                if (index ==
                    _employeeMasterCubit.state.employeeMasterList.length) {
                  return state.employeeMasterList.length <
                          state.totalNumberOfRecord
                      ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var employee = state.employeeMasterList[index];
                return Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 10),
                  clipBehavior: Clip.hardEdge,
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 10,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.employeeViewDetails,
                                  queryParameters: {
                                    "employee": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(employee),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: AppColor.primary),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        employee.fullName,
                                        style: AppTextStyle.ts16M(
                                          color: AppColor.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              CustomIconButton.edit(
                                onPressed: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.addUpdateEmployee,
                                    queryParameters: {
                                      "employee": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(employee),
                                        ),
                                      ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      verticalSpacing(),
                      Row(
                        children: [
                          // TITLE
                          SizedBox(
                            width: 130,
                            child: Text(
                              "Employee Code",
                              style: AppTextStyle.ts14R(color: AppColor.grey),
                            ),
                          ),

                          // COLON
                          SizedBox(
                            width: 20,
                            child: Text(
                              ":",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColor.grey),
                            ),
                          ),

                          // VALUE
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColor.purple.withValues(alpha: .15),
                              ),
                              child: Text(
                                employee.employeeCode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.ts14R(
                                  color: AppColor.purple,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      verticalSpacing(),
                      buildRowTitleValue(
                        title: "Designation",
                        value: employee.designation,
                      ),
                      buildRowTitleValue(
                        title: "Department",
                        value: employee.department,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                "Contact Number",
                                style: AppTextStyle.ts14R(color: AppColor.grey),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                              child: Text(
                                ":",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColor.grey),
                              ),
                            ),
                            CustomClickToContactText(
                              value: employee.personalMobileNumber,
                            ),
                          ],
                        ),
                      ),

                      buildRowTitleValue(
                        title: "Reporting Person",
                        value: employee.reportPersonName,
                      ),
                    ],
                  ),
                );
              },
            );

            return Stack(
              children: [
                listView,
                if (state.isLoading ?? false)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.transparent,
                        child: Center(child: loader()),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
